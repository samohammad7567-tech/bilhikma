import 'section_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../data/models/educational_pathway_model.dart';
import '../cubit/educational_pathways_cubit.dart';
import 'active_pathway_card.dart';
import 'pathway_card.dart';

class EducationalPathwaysContent extends StatelessWidget {
  const EducationalPathwaysContent({
    required this.state,
    required this.cubit,
    super.key,
  });

  final EducationalPathwaysState state;
  final EducationalPathwaysCubit cubit;

  @override
  Widget build(BuildContext context) {
    final List<EducationalPathwayModel> pathways = state.visiblePathways;

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: <Widget>[
        if (state.hasActivePathway) ...<Widget>[
          const SectionTitle(labelKey: 'app_pathway_content'),

          SizedBox(height: 12.h),

          ActivePathwayCard(active: state.active),

          SizedBox(height: 24.h),
        ],

        const SectionTitle(labelKey: 'my_learning_paths'),

        SizedBox(height: 12.h),

        if (pathways.isEmpty)
          const AppEmptyView(
            icon: Icons.school_outlined,
            messageKey: 'no_educational_pathways',
          ),

        for (final EducationalPathwayModel pathway in pathways) ...<Widget>[
          PathwayCard(
            pathway: pathway,
            expandedNodeIds: state.expandedNodeIds,
            onToggle: cubit.toggleNode,
          ),

          SizedBox(height: 16.h),
        ],
      ],
    );
  }
}
