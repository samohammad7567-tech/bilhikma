import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/localization/lang_keys.dart';
import '../../../../core/themes/app_theme.dart';

class QuestionLockedBanner extends StatefulWidget {
  const QuestionLockedBanner({super.key});

  @override
  State<QuestionLockedBanner> createState() => _QuestionLockedBannerState();
}

class _QuestionLockedBannerState extends State<QuestionLockedBanner> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusManager.instance.primaryFocus?.unfocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextStyle label = AppTheme.styles(context).labelStrong;
    final TextStyle hint = AppTheme.styles(context).labelSmall;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: colors.errorContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 2.h),
            child: Icon(
              Icons.lock_clock_outlined,
              size: 18.w,
              color: colors.error,
            ),
          ),

          SizedBox(width: 8.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  LangKeys.quizQuestionTimeUp.tr(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: label.copyWith(color: colors.onErrorContainer),
                ),

                SizedBox(height: 2.h),

                Text(
                  LangKeys.quizQuestionLockedHint.tr(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: hint.copyWith(color: colors.onErrorContainer),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
