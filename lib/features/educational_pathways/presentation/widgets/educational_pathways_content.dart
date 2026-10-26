import 'section_title.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/app_fade_slide_in.dart';
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

    return RefreshIndicator(
      onRefresh: cubit.loadPathways,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        children: <Widget>[
          if (state.hasActivePathway) ...<Widget>[
            const SectionTitle(labelKey: 'app_pathway_content'),

            SizedBox(height: 12.h),

            AppFadeSlideIn(child: ActivePathwayCard(active: state.active)),

            SizedBox(height: 24.h),
          ],

          const SectionTitle(labelKey: 'my_learning_paths'),

          SizedBox(height: 12.h),

          if (pathways.isEmpty)
            const AppEmptyView(
              icon: Icons.school_outlined,
              messageKey: 'no_educational_pathways',
            ),

          for (int index = 0; index < pathways.length; index++) ...<Widget>[
            AppFadeSlideIn(
              index: index + 1,
              child: PathwayCard(
                pathway: pathways[index],
                expandedNodeIds: state.expandedNodeIds,
                onToggle: cubit.toggleNode,
              ),
            ),

            SizedBox(height: 16.h),
          ],
        ],
      ),
    );
  }
}
