import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'custom_button.dart';
import '../themes/app_theme.dart';

class AppEmptyView extends StatelessWidget {
  const AppEmptyView({
    required this.icon,
    required this.messageKey,
    super.key,
    this.padding,
    this.titleKey,
    this.actionLabelKey,
    this.onAction,
  });

  final IconData icon;
  final String messageKey;

  final EdgeInsetsGeometry? padding;

  /// Optional heading above the message, for an empty state that needs to say
  /// what is missing before explaining it.
  final String? titleKey;

  /// Label of the optional action button. Ignored unless [onAction] is given.
  final String? actionLabelKey;
  final VoidCallback? onAction;

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
    final AppTextStyles styles = AppTheme.styles(context);

    final String? titleKey = this.titleKey;
    final VoidCallback? onAction = this.onAction;

    return Padding(
      padding:
          padding ?? EdgeInsets.symmetric(horizontal: 24.w, vertical: 48.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 44.w, color: colors.outline),

          SizedBox(height: 12.h),

          if (titleKey != null) ...<Widget>[
            Text(
              titleKey.tr(),
              textAlign: TextAlign.center,
              style: styles.sectionTitle,
            ),

            SizedBox(height: 8.h),
          ],

          Text(
            messageKey.tr(),
            textAlign: TextAlign.center,
            style: styles.bodyMedium.copyWith(color: colors.onSurfaceVariant),
          ),

          if (onAction != null) ...<Widget>[
            SizedBox(height: 20.h),

            CustomButton(
              onPressed: onAction,
              text: (actionLabelKey ?? 'retry').tr(),
              width: double.infinity,
              height: 40.h,
              threeRadius: 8.r,
              lastRadius: 8.r,
              backgroundColor: colors.secondaryContainer,
              elevation: 0,
            ),
          ],
        ],
      ),
    );
  }
}
