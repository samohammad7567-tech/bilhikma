import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/localization/lang_keys.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../../core/widgets/app_circle_avatar.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../data/models/lesson_test_model.dart';
import '../cubit/lesson_test_cubit.dart';
import '../widgets/quiz_start_dialog.dart';
import '../widgets/test_intro_card.dart';

class LessonTestIntroBody extends StatelessWidget {
  const LessonTestIntroBody({
    required this.cubit,
    required this.state,
    required this.onStart,
    super.key,
  });

  final LessonTestCubit cubit;
  final LessonTestState state;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final LessonTestModel? quiz = state.quiz;
    if (quiz == null) return const SizedBox.shrink();

    final ColorScheme colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SizedBox(height: 40.h),
        AppCircleAvatar(size: 70.w),
        SizedBox(height: 20.h),
        Text(
          quiz.title,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTheme.styles(context).sectionTitle,
        ),
        SizedBox(height: 18.h),
        TestIntroCard(rows: _rows(quiz)),

        if (quiz.instructions != null &&
            quiz.instructions!.trim().isNotEmpty) ...[
          SizedBox(height: 16.h),
          _Note(
            icon: Icons.info_outline,
            text:
                '${LangKeys.quizInstructions.tr()}: ${quiz.instructions!.trim()}',
          ),
        ],

        if (quiz.hasPassed) ...[
          SizedBox(height: 12.h),
          _Note(icon: Icons.verified_outlined, text: LangKeys.quizPassed.tr()),
        ],

        if (!quiz.hasAttemptsLeft) ...[
          SizedBox(height: 12.h),
          _Note(
            icon: Icons.block_outlined,
            text: LangKeys.quizNoAttemptsLeft.tr(),
            color: colors.error,
          ),
        ],

        if (quiz.isInCooldown && quiz.nextAttemptAt != null) ...[
          SizedBox(height: 12.h),
          _Note(
            icon: Icons.schedule,
            text:
                '${LangKeys.quizNextAttemptAt.tr()}: '
                '${_dateTime(context, quiz.nextAttemptAt!)}',
          ),
        ],

        if (state.errorKey != null) ...[
          SizedBox(height: 12.h),
          _Note(
            icon: Icons.error_outline,
            text: state.errorMessage?.trim().isNotEmpty == true
                ? state.errorMessage!
                : state.errorKey!.tr(),
            color: colors.error,
          ),
        ],

        SizedBox(height: 30.h),
        CustomButton(
          onPressed: state.canStart ? () => _confirmStart(context) : () {},
          text: LangKeys.startTest.tr(),
          width: double.infinity,
          height: 48.h,
          threeRadius: 8.r,
          lastRadius: 8.r,
          isLoading: state.isStarting,
          backgroundColor: state.canStart
              ? colors.secondary
              : colors.surfaceContainerHighest,
          textColor: state.canStart ? colors.onSecondary : colors.outline,
          elevation: 0,
        ),
      ],
    );
  }

  Future<void> _confirmStart(BuildContext context) async {
    final bool isReady = await QuizStartDialog.show(context);
    if (!isReady || !context.mounted) return;

    onStart();
  }

  List<TestIntroRow> _rows(LessonTestModel quiz) => <TestIntroRow>[
    TestIntroRow(
      icon: Icons.format_list_numbered,
      label: 'questions_count'.tr(),
      value: 'questions_value'.tr(
        namedArgs: <String, String>{'count': '${quiz.questionCount}'},
      ),
    ),
    if (quiz.hasTimeLimit)
      TestIntroRow(
        icon: Icons.timer_outlined,
        label: 'test_duration'.tr(),
        value: 'minute_count'.tr(
          namedArgs: <String, String>{'count': '${quiz.timeLimitMinutes}'},
        ),
      ),
    TestIntroRow(
      icon: Icons.flag_outlined,
      label: LangKeys.passThreshold.tr(),
      value: 'pass_threshold_note'.tr(
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

  String _dateTime(BuildContext context, DateTime value) {
    final MaterialLocalizations localizations = MaterialLocalizations.of(
      context,
    );

    return '${localizations.formatMediumDate(value)} '
        '${localizations.formatTimeOfDay(TimeOfDay.fromDateTime(value), alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context))}';
  }
}

class _Note extends StatelessWidget {
  const _Note({required this.icon, required this.text, this.color});

  final IconData icon;
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: (color ?? colors.primary).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 18.w, color: color ?? colors.onSurfaceVariant),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: AppTheme.styles(
                context,
              ).labelMedium.copyWith(color: color ?? colors.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}
