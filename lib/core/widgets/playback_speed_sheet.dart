import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../enums/playback_speed_enum.dart';
import '../themes/app_theme.dart';
import 'sheet_handle.dart';

/// Playback rate picker shared by the lesson audio and video players.
class PlaybackSpeedSheet extends StatelessWidget {
  const PlaybackSpeedSheet({
    required this.current,
    required this.isLessonCompleted,
    required this.onSelected,
    super.key,
  });

  final PlaybackSpeed current;

  /// Fastest rates stay locked until the lesson has been completed once.
  final bool isLessonCompleted;

  final ValueChanged<PlaybackSpeed> onSelected;

  static Future<void> show({
    required BuildContext context,
    required PlaybackSpeed current,
    required bool isLessonCompleted,
    required ValueChanged<PlaybackSpeed> onSelected,
  }) => showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (BuildContext sheetContext) => PlaybackSpeedSheet(
      current: current,
      isLessonCompleted: isLessonCompleted,
      onSelected: (PlaybackSpeed speed) {
        Navigator.of(sheetContext).pop();
        onSelected(speed);
      },
    ),
  );

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final AppTextStyles styles = AppTheme.styles(context);

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SheetHandle(),

                SizedBox(height: 16.h),

                Text(
                  'playback_speed'.tr(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: styles.panelTitle,
                ),

                SizedBox(height: 8.h),

                for (final PlaybackSpeed option in PlaybackSpeed.values)
                  _Option(
                    speed: option,
                    isSelected: option == current,
                    isLocked: option.needsCompletedLesson && !isLessonCompleted,
                    onTap: () => onSelected(option),
                  ),

                if (!isLessonCompleted) ...<Widget>[
                  SizedBox(height: 8.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    child: Text(
                      'playback_speed_locked_note'.tr(),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: styles.cardCaption,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.speed,
    required this.isSelected,
    required this.isLocked,
    required this.onTap,
  });

  final PlaybackSpeed speed;
  final bool isSelected;
  final bool isLocked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final AppTextStyles styles = AppTheme.styles(context);

    final TextStyle style = isSelected
        ? styles.optionLabelSelected
        : styles.optionLabel;

    return ListTile(
      onTap: isLocked ? null : onTap,
      dense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 8.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      title: Text(
        speed.isNormal ? 'playback_speed_normal'.tr() : speed.label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: isLocked
            ? style.copyWith(color: style.color?.withValues(alpha: 0.4))
            : style,
      ),
      trailing: switch ((isLocked, isSelected)) {
        (true, _) => Icon(
          Icons.lock_outline_rounded,
          size: 18.w,
          color: colors.onSurfaceVariant.withValues(alpha: 0.5),
        ),
        (false, true) => Icon(
          Icons.check_rounded,
          size: 20.w,
          color: colors.primary,
        ),
        (false, false) => null,
      },
    );
  }
}
