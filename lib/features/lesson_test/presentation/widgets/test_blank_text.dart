import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../refactor/test_blank_segments.dart';
import '../../../../core/themes/app_theme.dart';
import 'test_blank_chip.dart';

class TestBlankText extends StatelessWidget {
  const TestBlankText({
    required this.segments,
    required this.valueOf,
    required this.onBlankTap,
    super.key,
    this.selectedBlankId,
  });

  final List<TestBlankSegment> segments;

  final String? Function(String blankId) valueOf;

  final ValueChanged<String> onBlankTap;
  final String? selectedBlankId;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4.w,
      runSpacing: 10.h,
      children: TestBlankSegments.asWords(segments)
          .map((TestBlankSegment segment) {
            final String? blankId = segment.blankId;

            if (blankId == null) {
              return Text(
                segment.text,
                style: AppTheme.styles(context).bodyMedium,
              );
            }

            return TestBlankChip(
              value: valueOf(blankId),
              isSelected: selectedBlankId == blankId,
              onTap: () => onBlankTap(blankId),
            );
          })
          .toList(growable: false),
    );
  }
}
