import 'package:flutter/material.dart';

import '../../../../core/widgets/app_confirm_dialog.dart';

class ClearDownloadsDialog {
  ClearDownloadsDialog._();

  static Future<bool> show(BuildContext context) => AppConfirmDialog.show(
    context,
    titleKey: 'clear_all_downloads',
    messageKey: 'clear_downloads_confirm',
    confirmKey: 'clear_all',
  );
}
