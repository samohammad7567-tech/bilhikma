import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/themes/app_theme.dart';
import 'test_audio_button.dart';
import 'test_html_text.dart';
import 'test_media_image.dart';
import 'test_option_indicator.dart';

class TestOptionTile extends StatelessWidget {
  const TestOptionTile({
    required this.label,
    required this.isSelected,
    required this.isMultiSelect,
    required this.onTap,
    super.key,
    this.imageUrl,
    this.audioUrl,
  });

  final String label;
  final bool isSelected;

  final bool isMultiSelect;

  final VoidCallback onTap;

  final String? imageUrl;
  final String? audioUrl;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final Color background = isSelected
        ? colors.secondary
        : colors.tertiaryContainer;
    final Color foreground = isSelected ? colors.onSecondary : colors.onSurface;

    final String? image = _present(imageUrl);
    final String? audio = _present(audioUrl);
    final bool showImageFirst = image != null && label.trim().isEmpty;

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(10.r),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
          child: Row(
            children: <Widget>[
              TestOptionIndicator(
                isSelected: isSelected,
                isMultiSelect: isMultiSelect,
                color: foreground,
              ),
              SizedBox(width: 15.w),
              Expanded(
                child: showImageFirst
                    ? _imageFirst(image)
                    : TestHtmlText(
                        label,
                        maxLines: 3,
                        style: AppTheme.styles(context).optionLabel.copyWith(
                          color: foreground,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w600,
                        ),
                      ),
              ),
              if (image != null && !showImageFirst) ...<Widget>[
                SizedBox(width: 10.w),
                _thumbnail(image),
              ],
              if (audio != null) ...<Widget>[
                SizedBox(width: 6.w),
                TestAudioButton(url: audio),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _imageFirst(String url) => Padding(
    padding: EdgeInsets.symmetric(vertical: 6.h),
    child: SizedBox(
      width: double.infinity,
      height: 120.h,
      child: TestMediaImage(
        url: url,
        radius: 14,
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      ),
    ),
  );

  Widget _thumbnail(String url) => SizedBox(
    width: 56.w,
    height: 56.w,
    child: TestMediaImage(
      url: url,
      radius: 10,
      padding: EdgeInsets.all(3.w),
      elevated: false,
    ),
  );

  String? _present(String? value) {
    final String text = value?.trim() ?? '';
    return text.isEmpty ? null : text;
  }
}
