import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../refactor/pathway_option.dart';
import '../../../../core/themes/app_theme.dart';

class PathwayDropdownField extends StatelessWidget {
  const PathwayDropdownField({
    required this.label,
    required this.options,
    required this.value,
    required this.onChanged,
    super.key,
    this.isLoading = false,
  });

  final String label;
  final List<PathwayOption> options;
  final String? value;
  final ValueChanged<String?> onChanged;

  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final String? selected = _selectedValue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          label,
          textAlign: TextAlign.start,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTheme.styles(context).rowValue,
        ),

        SizedBox(height: 8.h),

        Container(
          height: 48.h,
          padding: EdgeInsets.symmetric(horizontal: 14.w),
          decoration: BoxDecoration(
            color: colors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selected,
              isExpanded: true,
              borderRadius: BorderRadius.circular(10.r),
              dropdownColor: colors.surfaceContainerLowest,
              icon: isLoading
                  ? SizedBox(
                      width: 16.w,
                      height: 16.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colors.onSurfaceVariant,
                      ),
                    )
                  : Icon(
                      Icons.keyboard_arrow_down,
                      size: 20.w,
                      color: colors.onSurfaceVariant,
                    ),
              hint: Text(
                'select_option'.tr(),
                textAlign: TextAlign.start,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.styles(context).fieldHint,
              ),
              onChanged: options.isEmpty || isLoading ? null : onChanged,
              items: <DropdownMenuItem<String>>[
                for (final PathwayOption option in options)
                  DropdownMenuItem<String>(
                    value: option.id,
                    child: Text(
                      option.label,
                      textAlign: TextAlign.start,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.styles(context).optionLabel,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String? get _selectedValue {
    for (final PathwayOption option in options) {
      if (option.id == value) return option.id;
    }
    return null;
  }
}
