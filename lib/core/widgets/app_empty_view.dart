import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../themes/app_theme.dart';
import '../utils/my_screen_size.dart';
import '../utils/screen_scale.dart';

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
            : MyScreenSize.heightFraction(context, 0.5);

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
          padding ??
          EdgeInsets.symmetric(
            horizontal: (24).w(context),
            vertical: (48).h(context),
          ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            icon,
            size: (44).r(context),
            color: Theme.of(context).colorScheme.outline,
          ),

          SizedBox(height: (12).h(context)),

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
