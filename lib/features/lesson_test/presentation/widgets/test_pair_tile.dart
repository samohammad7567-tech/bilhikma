import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/themes/app_theme.dart';
import 'test_audio_button.dart';
import 'test_html_text.dart';
import 'test_media_image.dart';
import 'test_pair_badge.dart';

class TestPairTile extends StatelessWidget {
  const TestPairTile({
    required this.text,
    required this.isSelected,
    required this.onTap,
    super.key,
    this.badge,
    this.isMuted = false,
    this.imageUrl,
    this.audioUrl,
  });

  final String text;

  final bool isSelected;

  final bool isMuted;

  final int? badge;

  final VoidCallback onTap;

  final String? imageUrl;
  final String? audioUrl;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final int? badge = this.badge;
    final String? image = _present(imageUrl);
    final String? audio = _present(audioUrl);
    final bool hasText = text.trim().isNotEmpty;

    return Material(
      color: isMuted
          ? colors.surfaceContainerHighest
          : colors.tertiaryContainer,
      borderRadius: BorderRadius.circular(10.r),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: isSelected ? colors.secondary : Colors.transparent,
              width: 1.6.w,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (image != null) ...<Widget>[
                _image(image),
                SizedBox(width: 8.w),
              ],

              Expanded(
                child: hasText
                    ? TestHtmlText(
                        text,
                        style: AppTheme.styles(
                          context,
                        ).cardBlurb.copyWith(color: colors.onSurface),
                      )
                    : const SizedBox.shrink(),
              ),

              if (audio != null) ...<Widget>[
                SizedBox(width: 4.w),
                TestAudioButton(url: audio, dense: true),
              ],

              if (badge != null) ...<Widget>[
                SizedBox(width: 8.w),
                TestPairBadge(value: badge),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _image(String url) => Padding(
    padding: EdgeInsets.symmetric(vertical: 2.h),
    child: SizedBox(
      width: 48.w,
      height: 48.w,
      child: TestMediaImage(
        url: url,
        radius: 10,
        padding: EdgeInsets.all(3.w),
        elevated: false,
      ),
    ),
  );

  String? _present(String? value) {
    final String text = value?.trim() ?? '';
    return text.isEmpty ? null : text;
  }
}
