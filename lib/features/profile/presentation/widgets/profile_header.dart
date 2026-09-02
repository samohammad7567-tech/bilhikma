import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/widgets/app_circle_avatar.dart';
import '../../../../core/themes/app_theme.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({required this.name, super.key});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        AppCircleAvatar(size: 96.w),

        SizedBox(height: 14.h),

        Text(
          name,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTheme.styles(context).sectionTitle,
        ),
      ],
    );
  }
}
