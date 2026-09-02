import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../themes/app_theme.dart';

class AppEmptyView extends StatelessWidget {
  const AppEmptyView({
    required this.icon,
    required this.messageKey,
    super.key,
    this.padding,
  });

  final IconData icon;
  final String messageKey;

  final EdgeInsetsGeometry? padding;

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
    return Padding(
      padding:
          padding ?? EdgeInsets.symmetric(horizontal: 24.w, vertical: 48.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 44.w, color: Theme.of(context).colorScheme.outline),

          SizedBox(height: 12.h),

          Text(
            messageKey.tr(),
            textAlign: TextAlign.center,
            style: AppTheme.styles(context).bodyMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
