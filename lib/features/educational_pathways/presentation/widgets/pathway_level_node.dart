import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/models/pathway_level_model.dart';
import 'pathway_node_row.dart';
import 'pathway_terms.dart';

class PathwayLevelNode extends StatelessWidget {
  const PathwayLevelNode({
    required this.level,
    required this.isExpanded,
    required this.onToggle,
    super.key,
  });

  final PathwayLevelModel level;
  final bool isExpanded;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        PathwayNodeRow(
          label: level.name,
          indent: 60.w,
          isExpanded: isExpanded,
          onTap: () => onToggle(level.id),
        ),

        if (isExpanded && level.terms.isNotEmpty)
          PathwayTerms(terms: level.terms),
      ],
    );
  }
}
