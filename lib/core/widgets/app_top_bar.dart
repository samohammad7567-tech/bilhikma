import 'package:flutter/material.dart';

import '../themes/app_theme.dart';
import '../utils/my_screen_size.dart';
import 'app_top_bar_back_button.dart';
import '../utils/screen_scale.dart';

class AppTopBar extends StatelessWidget {
  const AppTopBar({
    required this.title,
    super.key,
    this.onBack,
    this.leading,
    this.trailing,
  });

  final String title;
  final VoidCallback? onBack;
  final Widget? leading;

  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final VoidCallback? onBack = this.onBack;
    final Widget? start =
        leading ??
        (onBack == null ? null : AppTopBarBackButton(onPressed: onBack));

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: 48),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MyScreenSize.value(
                context,
                compact: 16,
                medium: 24,
                expanded: 32,
              ),
              vertical: (4).h(context),
            ),
            child: Text(
              title,
              textAlign: TextAlign.center,

              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.styles(context).screenTitle,
            ),
          ),

          if (start != null)
            Align(alignment: AlignmentDirectional.centerStart, child: start),

          if (trailing != null)
            Align(alignment: AlignmentDirectional.centerEnd, child: trailing),
        ],
      ),
    );
  }
}
