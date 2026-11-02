import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/localization/lang_keys.dart';
import '../../../../core/widgets/app_confirm_dialog.dart';

class QuizLeaveDialog {
  QuizLeaveDialog._();

  static Future<bool> show(BuildContext context) => AppConfirmDialog.show(
    context,
    titleKey: LangKeys.quizLeaveConfirmTitle,
    messageKey: LangKeys.quizLeaveConfirmMessage,
    confirmKey: LangKeys.quizLeaveConfirmAction,
    iconPath: AppAssets.assetsLockIcon,
  );
}
