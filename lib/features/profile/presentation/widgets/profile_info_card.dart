import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/enums/profile_field_enum.dart';
import '../../data/models/profile_model.dart';
import 'profile_info_row.dart';

class ProfileInfoCard extends StatelessWidget {
  const ProfileInfoCard({required this.profile, super.key});

  final ProfileModel profile;

  @override
  Widget build(BuildContext context) {
    const List<ProfileField> fields = ProfileField.values;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.sandSoft,
        borderRadius: BorderRadius.circular(12.r),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (int index = 0; index < fields.length; index++) ...<Widget>[
            if (index > 0)
              Divider(
                height: 1.h,
                thickness: 1.h,
                indent: 16.w,
                endIndent: 16.w,
                color: AppColors.sand,
              ),
            ProfileInfoRow(field: fields[index], profile: profile),
          ],
        ],
      ),
    );
  }
}
