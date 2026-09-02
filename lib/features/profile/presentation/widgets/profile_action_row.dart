import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/enums/profile_action_enum.dart';
import '../../../../core/themes/app_theme.dart';

class ProfileActionRow extends StatelessWidget {
  const ProfileActionRow({
    required this.action,
    required this.onTap,
    super.key,
  });

  final ProfileAction action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        child: Row(
          children: <Widget>[
            Container(
              width: 38.w,
              height: 38.w,
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: AppIcon(
                asset: action.imagePath,
                size: 20.w,
                color: colors.onPrimaryContainer,
                padding: EdgeInsets.all(9.w),
              ),
            ),

            SizedBox(width: 12.w),

            Expanded(
              child: Text(
                action.label.tr(),
                textAlign: TextAlign.start,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.styles(context).rowTitle,
              ),
            ),

            Icon(
              Icons.arrow_forward_ios,
              size: 14.w,
              color: colors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
