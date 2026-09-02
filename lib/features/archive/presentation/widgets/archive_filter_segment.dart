import '../../../../core/widgets/app_icon.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/enums/archive_filter_enum.dart';
import '../../../../core/themes/app_theme.dart';

class ArchiveFilterSegment extends StatelessWidget {
  const ArchiveFilterSegment({
    required this.filter,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final ArchiveFilter filter;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final Color foreground = isSelected
        ? colors.onSecondary
        : colors.primary.withValues(alpha: 0.8);

    return Material(
      color: isSelected ? colors.secondary : Colors.transparent,
      borderRadius: BorderRadius.circular(10.r),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              AppIcon(asset: filter.imagePath, color: foreground, size: 20.w),

              SizedBox(width: 6.w),
              Flexible(
                child: Text(
                  filter.label.tr(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.styles(
                    context,
                  ).labelStrong.copyWith(color: foreground),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
