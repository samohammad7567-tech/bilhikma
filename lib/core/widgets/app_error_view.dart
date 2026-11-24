import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'custom_button.dart';
import '../themes/app_theme.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class AppErrorView extends StatelessWidget {
  const AppErrorView({
    required this.errorKey,
    required this.onRetry,
    super.key,
    this.message,
  });
  final String? errorKey;

  final String? message;

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.all((32).r(context)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              message ?? (errorKey ?? 'something_went_wrong').tr(),
              textAlign: TextAlign.center,
              style: AppTheme.styles(
                context,
              ).bodyLarge.copyWith(color: colors.secondary),
            ),

            SizedBox(height: (20).h(context)),

            CustomButton(
              onPressed: onRetry,
              text: 'retry'.tr(),
              width: double.infinity,
              height: (40).h(context),
              threeRadius: 8,
              lastRadius: 8,
              backgroundColor: colors.secondaryContainer,
              elevation: (0).r(context),
            ),
          ],
        ),
      ),
    );
  }
}
