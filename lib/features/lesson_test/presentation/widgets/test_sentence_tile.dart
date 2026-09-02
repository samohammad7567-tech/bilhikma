import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/themes/app_theme.dart';

class TestSentenceTile extends StatelessWidget {
  const TestSentenceTile({required this.text, required this.index, super.key});

  final String text;
  final int index;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: colors.tertiaryContainer,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              text,
              textAlign: TextAlign.start,
              style: AppTheme.styles(
                context,
              ).cardBlurb.copyWith(color: colors.onSurface),
            ),
          ),

          SizedBox(width: 8.w),

          ReorderableDragStartListener(
            index: index,
            child: Icon(
              Icons.drag_indicator,
              size: 20.w,
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
