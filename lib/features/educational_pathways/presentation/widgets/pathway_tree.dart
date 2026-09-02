import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/models/educational_pathway_model.dart';
import '../../data/models/pathway_level_model.dart';
import '../../data/models/pathway_stage_model.dart';
import 'pathway_node_row.dart';
import 'pathway_level_node.dart';

class PathwayTree extends StatelessWidget {
  const PathwayTree({
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (final PathwayStageModel stage in pathway.stages) ...<Widget>[
          PathwayNodeRow(
            label: stage.name,
            indent: 40.w,
            isExpanded: expandedNodeIds.contains(stage.id),
            onTap: () => onToggle(stage.id),
          ),

          if (expandedNodeIds.contains(stage.id))
            for (final PathwayLevelModel level in stage.levels)
              PathwayLevelNode(
                level: level,
                isExpanded: expandedNodeIds.contains(level.id),
                onToggle: onToggle,
              ),
        ],
      ],
    );
  }
}
