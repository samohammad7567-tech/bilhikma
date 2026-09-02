import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/themes/app_theme.dart';

class PathwayNodeRow extends StatelessWidget {
  const PathwayNodeRow({
    required this.label,
    required this.indent,
    super.key,
    this.isExpanded = false,
    this.onTap,
  });

  final String label;
  final double indent;
  final bool isExpanded;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final VoidCallback? onTap = this.onTap;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(indent, 8.h, 12.w, 8.h),
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.start,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: onTap == null
                      ? AppTheme.styles(context).rowValue
                      : AppTheme.styles(context).rowTitle,
                ),
              ),

              if (onTap != null) ...<Widget>[
                SizedBox(width: 6.w),

                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    size: 20.w,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
