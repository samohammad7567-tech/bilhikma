import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/localization/lang_keys.dart';
import '../../../../core/widgets/app_confirm_dialog.dart';

class QuizStartDialog {
  QuizStartDialog._();

  static Future<bool> show(BuildContext context) => AppConfirmDialog.show(
    context,
    titleKey: LangKeys.quizStartConfirmTitle,
    messageKey: LangKeys.quizStartConfirmMessage,
    confirmKey: LangKeys.startTest,
    iconPath: AppAssets.assetsSleeperTimerIcon,
  );
}
