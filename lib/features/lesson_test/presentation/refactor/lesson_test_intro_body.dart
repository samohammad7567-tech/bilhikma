import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/localization/lang_keys.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../../core/widgets/app_circle_avatar.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../data/models/lesson_test_model.dart';
import '../cubit/lesson_test_cubit.dart';
import '../widgets/quiz_start_dialog.dart';
import '../widgets/test_html_text.dart';
import '../widgets/test_intro_card.dart';
import '../widgets/test_intro_note.dart';
import 'test_intro_details.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

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
    final bool resuming = quiz.hasOpenAttempt;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SizedBox(height: (40).h(context)),
        AppCircleAvatar(size: (70).r(context)),
        SizedBox(height: (20).h(context)),
        TestHtmlText(
          quiz.title,
          textAlign: TextAlign.center,
          maxLines: 2,
          style: AppTheme.styles(context).sectionTitle,
        ),
        SizedBox(height: (18).h(context)),
        TestIntroCard(rows: testIntroRows(quiz)),

        if (quiz.instructions != null &&
            quiz.instructions!.trim().isNotEmpty) ...[
          SizedBox(height: (16).h(context)),
          TestIntroNote(
            icon: Icons.info_outline,
            text:
                '${LangKeys.quizInstructions.tr()}: ${quiz.instructions!.trim()}',
          ),
        ],

        if (resuming) ...[
          SizedBox(height: (12).h(context)),
          TestIntroNote(
            icon: Icons.play_circle_outline,
            text: LangKeys.quizResumeNote.tr(),
          ),
        ],

        if (quiz.hasPassed) ...[
          SizedBox(height: (12).h(context)),
          TestIntroNote(
            icon: Icons.verified_outlined,
            text: LangKeys.quizPassed.tr(),
          ),
        ],

        if (!resuming && !quiz.hasAttemptsLeft) ...[
          SizedBox(height: (12).h(context)),
          TestIntroNote(
            icon: Icons.block_outlined,
            text: LangKeys.quizNoAttemptsLeft.tr(),
            color: colors.error,
          ),
        ],

        if (!resuming && quiz.isInCooldown && quiz.nextAttemptAt != null) ...[
          SizedBox(height: (12).h(context)),
          TestIntroNote(
            icon: Icons.schedule,
            text:
                '${LangKeys.quizNextAttemptAt.tr()}: '
                '${testIntroDateTime(context, quiz.nextAttemptAt!)}',
          ),
        ],

        if (state.errorKey != null) ...[
          SizedBox(height: (12).h(context)),
          TestIntroNote(
            icon: Icons.error_outline,
            text: state.errorMessage?.trim().isNotEmpty == true
                ? state.errorMessage!
                : state.errorKey!.tr(),
            color: colors.error,
          ),
        ],

        SizedBox(height: (30).h(context)),
        CustomButton(
          onPressed: state.canStart
              ? () => _confirmStart(context, resuming: resuming)
              : () {},
          text: resuming
              ? LangKeys.quizContinueTest.tr()
              : LangKeys.startTest.tr(),
          width: double.infinity,
          height: (48).h(context),
          threeRadius: 8,
          lastRadius: 8,
          isLoading: state.isStarting,
          backgroundColor: state.canStart
              ? colors.secondary
              : colors.surfaceContainerHighest,
          textColor: state.canStart ? colors.onSecondary : colors.outline,
          elevation: (0).r(context),
        ),
      ],
    );
  }

  Future<void> _confirmStart(
    BuildContext context, {
    required bool resuming,
  }) async {
    final bool isReady = await QuizStartDialog.show(
      context,
      resuming: resuming,
    );
    if (!isReady || !context.mounted) return;

    onStart();
  }
}
