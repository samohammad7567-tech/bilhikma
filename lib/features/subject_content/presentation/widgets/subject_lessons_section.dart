import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/models/lesson_model.dart';
import '../../../../core/widgets/lesson_card.dart';

class SubjectLessonsSection extends StatelessWidget {
  const SubjectLessonsSection({
    required this.lessons,
    required this.onLessonTap,
    super.key,
  });

  final List<LessonModel> lessons;

  final ValueChanged<LessonModel> onLessonTap;

  @override
  Widget build(BuildContext context) {
    if (lessons.isEmpty) {
      return const AppEmptyView(
        icon: Icons.menu_book_outlined,
        messageKey: 'no_lessons_in_section',
      );
    }

    return Column(
      children: <Widget>[
        for (final LessonModel lesson in lessons)
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
            child: LessonCard(lesson: lesson, onTap: () => onLessonTap(lesson)),
          ),
      ],
    );
  }
}
