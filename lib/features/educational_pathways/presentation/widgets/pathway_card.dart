import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_assets.dart';
import '../../data/models/educational_pathway_model.dart';
import '../refactor/pathway_view_data.dart';
import 'pathway_info_row.dart';
import 'pathway_tree.dart';

class PathwayCard extends StatelessWidget {
  const PathwayCard({
    required this.pathway,
    required this.expandedNodeIds,
    required this.onToggle,
    super.key,
  });

  final EducationalPathwayModel pathway;
  final Set<String> expandedNodeIds;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14.r),
      ),
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          PathwayInfoRow(
            asset: AppAssets.assetsInstitution,
            label: 'educational_institution'.tr(),
            values: PathwayViewData.infoValues(<String>[
              pathway.institutionName,
            ]),
          ),

          SizedBox(height: 14.h),

          PathwayInfoRow(
            asset: AppAssets.assetsEducationalPath,
            label: 'academic_path'.tr(),
          ),

          SizedBox(height: 8.h),

          PathwayTree(
            pathway: pathway,
            expandedNodeIds: expandedNodeIds,
            onToggle: onToggle,
          ),
        ],
      ),
    );
  }
}
