import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/themes/app_colors.dart';
import '../../data/models/pathway_term_model.dart';
import 'pathway_node_row.dart';

class PathwayTerms extends StatelessWidget {
  const PathwayTerms({required this.terms, super.key});

  final List<PathwayTermModel> terms;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(start: 68.w),
      child: Container(
        decoration: const BoxDecoration(
          border: BorderDirectional(start: BorderSide(color: AppColors.sand)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            for (final PathwayTermModel term in terms)
              PathwayNodeRow(label: term.name, indent: 12.w),
          ],
        ),
      ),
    );
  }
}
