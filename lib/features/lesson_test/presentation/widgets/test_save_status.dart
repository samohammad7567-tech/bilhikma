import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/localization/lang_keys.dart';
import '../../../../core/themes/app_theme.dart';
import '../cubit/lesson_test_cubit.dart';

class TestSaveStatus extends StatelessWidget {
  const TestSaveStatus({required this.saveStatus, super.key});

  final LessonTestSaveStatus saveStatus;

  @override
  Widget build(BuildContext context) {
    final (String? key, Color? color) = switch (saveStatus) {
      LessonTestSaveStatus.saving => (
        LangKeys.quizSaving,
        Theme.of(context).colorScheme.outline,
      ),
      LessonTestSaveStatus.saved => (
        LangKeys.quizSaved,
        Theme.of(context).colorScheme.primary,
      ),
      LessonTestSaveStatus.failed => (
        LangKeys.quizSaveFailed,
        Theme.of(context).colorScheme.error,
      ),
      LessonTestSaveStatus.idle => (null, null),
    };

    if (key == null || color == null) return const SizedBox.shrink();

    return Text(
      key.tr(),
      textAlign: TextAlign.end,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: AppTheme.styles(context).labelSmall.copyWith(color: color),
    );
  }
}
