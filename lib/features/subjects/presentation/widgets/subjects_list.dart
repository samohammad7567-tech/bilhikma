import 'package:flutter/material.dart';

import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/subject_card.dart';
import '../../../../core/models/subject_model.dart';
import '../refactor/subjects_formats.dart';
import '../../../../core/utils/my_screen_size.dart';
import '../../../../core/utils/screen_scale.dart';

class SubjectsList extends StatelessWidget {
  const SubjectsList({required this.subjects, this.onSubjectTap, super.key});

  final List<SubjectModel> subjects;
  final ValueChanged<SubjectModel>? onSubjectTap;

  @override
  Widget build(BuildContext context) {
    if (subjects.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const <Widget>[
          AppEmptyView(
            icon: Icons.menu_book_outlined,
            messageKey: 'no_subjects',
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        16,
        4,
        16,
        MyScreenSize.bottomChromeHeight(context) + 24,
      ),
      itemCount: subjects.length,
      separatorBuilder: (BuildContext context, int index) =>
          SizedBox(height: (12).h(context)),
      itemBuilder: (BuildContext context, int index) {
        final SubjectModel subject = subjects[index];

        return SubjectCard(
          title: subject.name,
          subtitle: SubjectsFormats.lessons(subject.lessonsCount),
          progress: subject.progress,
          order: subject.position,
          onTap: onSubjectTap == null ? null : () => onSubjectTap!(subject),
        );
      },
    );
  }
}
