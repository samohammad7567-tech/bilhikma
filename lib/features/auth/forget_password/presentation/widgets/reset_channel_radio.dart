import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ResetChannelRadio extends StatelessWidget {
  const ResetChannelRadio({required this.isSelected, super.key});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Container(
      width: 20.w,
      height: 20.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: colors.tertiary, width: 1.6),
      ),
      child: isSelected
          ? Container(
              width: 10.w,
              height: 10.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.tertiary,
              ),
            )
          : null,
    );
  }
}
