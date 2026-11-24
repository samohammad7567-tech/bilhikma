import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../data/models/educational_pathway_model.dart';
import '../refactor/pathway_view_data.dart';
import 'pathway_info_row.dart';
import 'pathway_tree.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

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
        borderRadius: BorderRadius.circular((14).r(context)),
      ),
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.symmetric(horizontal: (14).w(context), vertical: (16).h(context)),
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

          SizedBox(height: (14).h(context)),

          PathwayInfoRow(
            asset: AppAssets.assetsEducationalPath,
            label: 'academic_path'.tr(),
          ),

          SizedBox(height: (8).h(context)),

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
