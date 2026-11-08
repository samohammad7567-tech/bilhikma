import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/localization/lang_keys.dart';
import '../../data/models/lesson_test_model.dart';
import '../widgets/test_intro_card.dart';

List<TestIntroRow> testIntroRows(LessonTestModel quiz) => <TestIntroRow>[
  TestIntroRow(
    icon: Icons.format_list_numbered,
    label: LangKeys.questionsCount.tr(),
    value: LangKeys.questionsValue.tr(
      namedArgs: <String, String>{'count': '${quiz.questionCount}'},
    ),
  ),
  if (quiz.hasTimeLimit)
    TestIntroRow(
      icon: Icons.timer_outlined,
      label: LangKeys.testDuration.tr(),
      value: LangKeys.minuteCount.tr(
        namedArgs: <String, String>{'count': '${quiz.timeLimitMinutes}'},
      ),
    ),
  TestIntroRow(
    icon: Icons.flag_outlined,
    label: LangKeys.passThreshold.tr(),
    value: LangKeys.passThresholdNote.tr(
      namedArgs: <String, String>{'percent': '${quiz.passScore}'},
    ),
  ),
  TestIntroRow(
    icon: Icons.replay_outlined,
    label: LangKeys.quizAttemptsLeft.tr(),
    value: quiz.hasUnlimitedAttempts
        ? LangKeys.quizAttemptsUnlimited.tr()
        : '${quiz.attemptsLeft}',
  ),
];

String testIntroDateTime(BuildContext context, DateTime value) {
  final MaterialLocalizations localizations = MaterialLocalizations.of(context);

  return '${localizations.formatMediumDate(value)} '
      '${localizations.formatTimeOfDay(
        TimeOfDay.fromDateTime(value),
        alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
      )}';
}
