import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/enums/content_type_enum.dart';
import '../../../../core/utils/lesson_view_data.dart';
import '../../../../core/themes/app_theme.dart';

class LessonMediaTab extends StatelessWidget {
  const LessonMediaTab({
    required this.mediaType,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final ContentType mediaType;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final Color foreground = isSelected
        ? colors.onSecondary
        : colors.onTertiaryContainer;

    return Material(
      color: isSelected ? colors.secondary : Colors.transparent,
      borderRadius: BorderRadius.circular(8.r),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 10.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(mediaType.icon, size: 18.w, color: foreground),

              SizedBox(width: 6.w),

              Flexible(
                child: Text(
                  mediaType.filterLabel.tr(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.styles(
                    context,
                  ).labelMedium.copyWith(color: foreground),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
