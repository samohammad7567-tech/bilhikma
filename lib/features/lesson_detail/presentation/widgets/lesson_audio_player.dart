import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/lesson_detail_formats.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/capped_seek_bar.dart';
import 'lesson_audio_play_button.dart';
import 'lesson_audio_skip_button.dart';

class LessonAudioPlayer extends StatelessWidget {
  const LessonAudioPlayer({
    required this.position,
    required this.duration,
    required this.maxPosition,
    required this.isPlaying,
    required this.onToggle,
    super.key,
    this.isBuffering = false,
    this.onSeek,
  });

  static const Duration _skipStep = Duration(seconds: 10);

  final Duration position;
  final Duration duration;

  final Duration maxPosition;

  final bool isPlaying;
  final bool isBuffering;
  final VoidCallback onToggle;

  final ValueChanged<Duration>? onSeek;

  Duration get _remaining =>
      duration > position ? duration - position : Duration.zero;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final ValueChanged<Duration>? onSeek = this.onSeek;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: colors.tertiaryContainer,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              LessonAudioSkipButton(
                icon: Icons.skip_next,
                onTap: onSeek == null ? null : () => _rewind(onSeek),
              ),

              SizedBox(width: 22.w),

              LessonAudioPlayButton(
                isPlaying: isPlaying,
                isBuffering: isBuffering,
                onToggle: onToggle,
              ),

              SizedBox(width: 22.w),

              LessonAudioSkipButton(
                icon: Icons.skip_previous,
                onTap: onSeek == null ? null : () => _forward(context, onSeek),
              ),
            ],
          ),

          SizedBox(height: 12.h),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Row(
              children: <Widget>[
                Text(
                  LessonDetailFormats.clock(position),
                  maxLines: 1,
                  style: AppTheme.styles(context).cardCaption,
                ),

                const Spacer(),

                Text(
                  LessonDetailFormats.clock(_remaining),
                  maxLines: 1,
                  style: AppTheme.styles(context).cardCaption,
                ),
              ],
            ),
          ),

          Directionality(
            textDirection: TextDirection.ltr,
            child: CappedSeekBar(
              position: position,
              duration: duration,
              maxPosition: maxPosition,
              onSeek: onSeek ?? (_) {},
              onBlocked: () => _refuseSkip(context),
            ),
          ),
        ],
      ),
    );
  }

  void _rewind(ValueChanged<Duration> onSeek) {
    final Duration target = position - _skipStep;
    onSeek(target < Duration.zero ? Duration.zero : target);
  }

  void _forward(BuildContext context, ValueChanged<Duration> onSeek) {
    if (position >= maxPosition) {
      _refuseSkip(context);
      return;
    }

    final Duration target = position + _skipStep;
    onSeek(target > maxPosition ? maxPosition : target);
  }

  void _refuseSkip(BuildContext context) =>
      AppToast.show(context, 'video_no_skip_note'.tr());
}
