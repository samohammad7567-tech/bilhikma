import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TestOptionIndicator extends StatelessWidget {
  const TestOptionIndicator({
    required this.isSelected,
    required this.isMultiSelect,
    required this.color,
    super.key,
  });

  final bool isSelected;
  final bool isMultiSelect;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final double side = 20.w;

    return Container(
      width: side,
      height: side,
      decoration: BoxDecoration(
        color: isSelected && isMultiSelect ? color : Colors.transparent,
        border: Border.all(color: color, width: 1.6.w),
        borderRadius: isMultiSelect
            ? BorderRadius.circular(4.r)
            : BorderRadius.circular(side),
      ),
      child: _mark(context, side),
    );
  }

  Widget? _mark(BuildContext context, double side) {
    if (!isSelected) return null;

    if (isMultiSelect) {
      return Icon(
        Icons.check,
        size: side * 0.7,
        color: Theme.of(context).colorScheme.secondary,
      );
    }

    return Center(
      child: Container(
        width: side * 0.45,
        height: side * 0.45,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}
