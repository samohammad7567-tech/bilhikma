import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../utils/lesson_view_data.dart';
import '../enums/lesson_category_enum.dart';
import '../themes/app_theme.dart';
import 'app_icon.dart';

class LessonCategoryChip extends StatelessWidget {
  const LessonCategoryChip({
    required this.category,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final LessonCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final Color foreground = isSelected ? colors.onSecondary : colors.outline;

    return Material(
      color: isSelected ? colors.secondary : Colors.transparent,
      shape: StadiumBorder(
        side: isSelected
            ? BorderSide.none
            : BorderSide(color: colors.outline, width: 1.2.w),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              AppIcon(asset: category.icon, size: 18.w, color: foreground),

              SizedBox(width: 8.w),

              Text(
                category.label.tr(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.styles(
                  context,
                ).labelMedium.copyWith(color: foreground),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
