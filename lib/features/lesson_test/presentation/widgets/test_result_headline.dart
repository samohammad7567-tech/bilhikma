import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/models/test_result_model.dart';
import '../../../../core/themes/app_theme.dart';

class TestResultHeadline extends StatelessWidget {
  const TestResultHeadline({required this.result, super.key});

  final TestResultModel result;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final bool passed = result.passed;

    return Column(
      children: <Widget>[
        Text(
          passed ? 'congratulations'.tr() : 'test_failed'.tr(),
          textAlign: TextAlign.center,
          maxLines: 1,
          style: AppTheme.styles(context).statusTitle.copyWith(
            color: passed ? colors.onSurfaceVariant : colors.onSurface,
          ),
        ),

        SizedBox(height: 6.h),

        Text(
          passed
              ? 'test_passed_note'.tr()
              : 'test_failed_note'.tr(
                  namedArgs: <String, String>{
                    'days': '${result.retryAfterDays}',
                  },
                ),
          textAlign: TextAlign.center,
          style: AppTheme.styles(context).labelStrong,
        ),
      ],
    );
  }
}
