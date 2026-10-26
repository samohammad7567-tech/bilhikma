import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../themes/app_theme.dart';
import 'app_top_bar_back_button.dart';

class AppTopBar extends StatelessWidget {
  const AppTopBar({
    required this.title,
    super.key,
    this.onBack,
    this.leading,
    this.trailing,
    this.secondaryLeading,
  });

  final String title;
  final VoidCallback? onBack;
  final Widget? leading;

  final Widget? trailing;

  /// A second start-side action, placed after [leading] (or after the back
  /// button). Lets a screen show both back and the drawer toggle without the
  /// toggle drifting to the end side, which reads as the wrong side in RTL.
  final Widget? secondaryLeading;

  @override
  Widget build(BuildContext context) {
    final VoidCallback? onBack = this.onBack;
    final Widget? secondary = secondaryLeading;

    final Widget? primary =
        leading ??
        (onBack == null ? null : AppTopBarBackButton(onPressed: onBack));

    final Widget? start = primary == null
        ? secondary
        : secondary == null
        ? primary
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              primary,
              SizedBox(width: 8.w),
              secondary,
            ],
          );

    // One icon keeps the title centred, as before; two widen the start inset
    // so the title clears them.
    final double startInset = primary != null && secondary != null
        ? 104.w
        : 56.w;

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: 48.h),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsetsDirectional.only(
              start: startInset,
              end: 56.w,
              top: 4.h,
              bottom: 4.h,
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
