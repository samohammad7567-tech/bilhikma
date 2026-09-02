import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../themes/app_theme.dart';

class LessonMetaItem extends StatelessWidget {
  const LessonMetaItem({
    required this.icon,
    required this.label,
    super.key,
    this.isIconTrailing = false,
  });

  final IconData icon;
  final String label;

  final bool isIconTrailing;

  @override
  Widget build(BuildContext context) {
    final Widget glyph = Icon(
      icon,
      size: 15.w,
      color: Theme.of(context).colorScheme.outline,
    );

    final Widget text = Flexible(
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTheme.styles(context).labelSmall,
      ),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (isIconTrailing) ...<Widget>[text, SizedBox(width: 6.w), glyph],
        if (!isIconTrailing) ...<Widget>[glyph, SizedBox(width: 6.w), text],
      ],
    );
  }
}
