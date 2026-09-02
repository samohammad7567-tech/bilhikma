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
  });

  final String title;
  final VoidCallback? onBack;

  /// Occupies the start corner instead of the back button — right in Arabic,
  /// left in English. A screen that offers a drawer puts its menu button here
  /// rather than in [trailing], which resolves to the opposite corner.
  final Widget? leading;

  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    // One corner, one control: an explicit leading widget wins over the back
    // button so the two can never stack on top of each other.
    final VoidCallback? onBack = this.onBack;
    final Widget? start =
        leading ??
        (onBack == null ? null : AppTopBarBackButton(onPressed: onBack));

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: 48.h),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 56.w, vertical: 4.h),
            child: Text(
              title,
              textAlign: TextAlign.center,

              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.styles(context).screenTitle,
            ),
          ),

          if (start != null)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: start,
            ),

          if (trailing != null)
            Align(alignment: AlignmentDirectional.centerEnd, child: trailing),
        ],
      ),
    );
  }
}
