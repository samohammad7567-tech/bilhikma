import 'package:flutter/material.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/enums/profile_field_enum.dart';
import '../../data/models/profile_model.dart';
import 'profile_info_row.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class ProfileInfoCard extends StatelessWidget {
  const ProfileInfoCard({required this.profile, super.key});

  final ProfileModel profile;

  @override
  Widget build(BuildContext context) {
    const List<ProfileField> fields = ProfileField.values;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.sandSoft,
        borderRadius: BorderRadius.circular((12).r(context)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (int index = 0; index < fields.length; index++) ...<Widget>[
            if (index > 0)
              Divider(
                height: (1).h(context),
                thickness: 1,
                indent: 16,
                endIndent: 16,
                color: AppColors.sand,
              ),
            ProfileInfoRow(field: fields[index], profile: profile),
          ],
        ],
      ),
    );
  }
}
