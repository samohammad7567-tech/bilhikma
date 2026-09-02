import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/widgets/ornamented_card.dart';
import '../../data/models/active_pathway_model.dart';
import '../refactor/pathway_view_data.dart';
import 'pathway_info_row.dart';

class ActivePathwayCard extends StatelessWidget {
  const ActivePathwayCard({required this.active, super.key});

  final ActivePathwayModel active;

  @override
  Widget build(BuildContext context) {
    return OrnamentedCard(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
      radius: 14.r,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          PathwayInfoRow(
            asset: AppAssets.assetsInstitution,
            label: 'educational_institution'.tr(),
            values: PathwayViewData.infoValues(<String>[
              active.institutionName,
            ]),
          ),

          SizedBox(height: 14.h),

          PathwayInfoRow(
            asset: AppAssets.assetsEducationalPath,
            label: 'academic_path'.tr(),
            values: PathwayViewData.infoValues(<String>[
              active.levelName,
              active.termName,
            ]),
          ),
        ],
      ),
    );
  }
}
