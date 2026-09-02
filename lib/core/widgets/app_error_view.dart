import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'custom_button.dart';
import '../themes/app_theme.dart';

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
        padding: EdgeInsets.all(32.w),
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

            SizedBox(height: 20.h),

            CustomButton(
              onPressed: onRetry,
              text: 'retry'.tr(),
              width: double.infinity,
              height: 40.h,
              threeRadius: 8.r,
              lastRadius: 8.r,
              backgroundColor: colors.secondaryContainer,
              elevation: 0,
            ),
          ],
        ),
      ),
    );
  }
}
