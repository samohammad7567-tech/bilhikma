import 'package:flutter/material.dart';

import '../../../../core/widgets/lesson_save_icon.dart';

class LessonSaveButton extends StatelessWidget {
  const LessonSaveButton({required this.contentId, super.key});

  final int contentId;

  @override
  Widget build(BuildContext context) =>
      LessonSaveIcon(lessonId: contentId, iconSize: 24, padding: 10);
}
