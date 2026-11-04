import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/themes/app_theme.dart';
import '../../../../core/widgets/app_network_image.dart';
import 'test_audio_button.dart';
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
                    ? _imageFirst(image, colors)
                    : Text(
                        label,
                        textAlign: TextAlign.start,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
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
                _thumbnail(image, colors),
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

  Widget _imageFirst(String url, ColorScheme colors) => ClipRRect(
    borderRadius: BorderRadius.circular(8.r),
    child: SizedBox(
      width: double.infinity,
      height: 120.h,
      child: ColoredBox(
        color: colors.surface,
        child: AppNetworkImage(
          url: url,
          fit: BoxFit.contain,
          errorWidget: Icon(
            Icons.broken_image_outlined,
            size: 28.r,
            color: colors.onSurfaceVariant,
          ),
        ),
      ),
    ),
  );

  Widget _thumbnail(String url, ColorScheme colors) => ClipRRect(
    borderRadius: BorderRadius.circular(8.r),
    child: SizedBox(
      width: 56.w,
      height: 56.w,
      child: AppNetworkImage(
        url: url,
        fit: BoxFit.cover,
        errorWidget: Icon(
          Icons.broken_image_outlined,
          size: 24.r,
          color: colors.onSurfaceVariant,
        ),
      ),
    ),
  );

  String? _present(String? value) {
    final String text = value?.trim() ?? '';
    return text.isEmpty ? null : text;
  }
}
