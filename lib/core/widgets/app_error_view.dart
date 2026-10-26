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
    this.icon = Icons.cloud_off_rounded,
  });
  final String? errorKey;

  final String? message;

  final VoidCallback onRetry;

  /// Shown above the message so the error state reads as a sibling of
  /// [AppEmptyView] rather than a bare line of text.
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double minHeight = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : MediaQuery.sizeOf(context).height * 0.5;

        return ConstrainedBox(
          constraints: BoxConstraints(minHeight: minHeight),
          child: Center(child: _content(context)),
        );
      },
    );
  }

  Widget _content(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.all(32.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 44.w, color: colors.outline),

          SizedBox(height: 12.h),

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
    );
  }
}
