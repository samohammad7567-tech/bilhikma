import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/localization/lang_keys.dart';
import '../../../../core/widgets/app_confirm_dialog.dart';

class QuizStartDialog {
  QuizStartDialog._();

  static Future<bool> show(BuildContext context, {bool resuming = false}) =>
      AppConfirmDialog.show(
        context,
        titleKey: resuming
            ? LangKeys.quizResumeConfirmTitle
            : LangKeys.quizStartConfirmTitle,
        messageKey: resuming
            ? LangKeys.quizResumeConfirmMessage
            : LangKeys.quizStartConfirmMessage,
        confirmKey: resuming ? LangKeys.quizContinueTest : LangKeys.startTest,
        iconPath: AppAssets.assetsSleeperTimerIcon,
      );
}
