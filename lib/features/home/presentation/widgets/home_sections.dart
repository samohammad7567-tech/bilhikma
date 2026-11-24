import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/widgets/subject_card.dart';
import '../../../../core/models/live_session_model.dart';
import '../../data/models/resume_lesson_model.dart';
import '../../../../core/models/subject_model.dart';
import '../cubit/home_cubit.dart';
import 'home_stats_row.dart';
import 'institution_card.dart';
import 'live_session_card.dart';
import 'resume_lesson_card.dart';
import 'section_header.dart';
import '../refactor/home_formats.dart';
import '../../../../core/utils/my_screen_size.dart';
import '../../../../core/utils/screen_scale.dart';

class HomeSections extends StatelessWidget {
  const HomeSections({
    required this.state,
    this.onViewAllSubjects,
    this.onSubjectTap,
    this.onLiveSessionTap,
    this.onResumeLessonTap,
    super.key,
  });

  final HomeState state;
  final VoidCallback? onViewAllSubjects;
  final ValueChanged<SubjectModel>? onSubjectTap;
  final ValueChanged<LiveSessionModel>? onLiveSessionTap;
  final ValueChanged<ResumeLessonModel>? onResumeLessonTap;

  @override
  Widget build(BuildContext context) {
    final LiveSessionModel? live = state.liveSession;
    final ResumeLessonModel? resume = state.resume;
    final String className = state.context?.categoryName ?? '';

    return CustomScrollView(
      slivers: <Widget>[
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: (16).w(context)),
          sliver: SliverList(
            delegate: SliverChildListDelegate(<Widget>[
              InstitutionCard(
                institution: state.context?.entityName ?? '',
                path: state.classPath,
              ),
              SizedBox(height: (14).h(context)),

              HomeStatsRow(
                overallProgress: state.overallProgress,
                lessonsCount: state.lessonsCount,
                subjectsCount: state.subjectsCount,
              ),

              if (live != null) ...<Widget>[
                SizedBox(height: (14).h(context)),
                LiveSessionCard(
                  session: live,
                  onTap: onLiveSessionTap == null ? null : () => onLiveSessionTap!(live),
                ),
              ],

              SizedBox(height: (20).h(context)),

              SectionHeader(
                title: context.tr('study_subjects'),
                subtitle: className,
                onViewAll: onViewAllSubjects,
              ),

              SizedBox(height: (12).h(context)),
            ]),
          ),
        ),

        SliverList.builder(
          itemCount: state.subjects.length,
          itemBuilder: (BuildContext context, int index) {
            final SubjectModel subject = state.subjects[index];

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: (16).w(context), vertical: (12).h(context)),
              child: SubjectCard(
                title: subject.name,
                subtitle: HomeFormats.lessons(subject.lessonsCount),
                progress: subject.progress,
                order: subject.position,
                onTap: onSubjectTap == null ? null : () => onSubjectTap!(subject),
              ),
            );
          },
        ),

        if (resume != null)
          SliverPadding(
            padding: EdgeInsets.fromLTRB((16).w(context), (8).h(context), (16).w(context), (16).h(context)),
            sliver: SliverList(
              delegate: SliverChildListDelegate(<Widget>[
                SectionHeader(title: context.tr('continue_where_you_left_off')),
                SizedBox(height: (12).h(context)),
                ResumeLessonCard(
                  lesson: resume,
                  onTap: onResumeLessonTap == null ? null : () => onResumeLessonTap!(resume),
                ),
              ]),
            ),
          ),

        SliverToBoxAdapter(child: SizedBox(height: MyScreenSize.bottomChromeHeight(context) + 18)),
      ],
    );
  }
}
