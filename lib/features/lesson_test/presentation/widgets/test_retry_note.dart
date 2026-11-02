import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/localization/lang_keys.dart';
import '../../../../core/themes/app_theme.dart';

class TestRetryNote extends StatelessWidget {
  const TestRetryNote({
    super.key,
    this.messageKey,
    this.nextAttemptAt,
    this.attemptsLeft,
  });

  final String? messageKey;
  final DateTime? nextAttemptAt;
  final int? attemptsLeft;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: colors.primaryContainer.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.info_outline, size: 18.w, color: colors.onSurfaceVariant),

          SizedBox(width: 8.w),

          Expanded(
            child: Text(
              _message(context),
              textAlign: TextAlign.center,
              style: AppTheme.styles(context).labelMedium,
            ),
          ),
        ],
      ),
    );
  }

  String _message(BuildContext context) {
    final String? key = messageKey;
    if (key != null) return key.tr();

    final DateTime? next = nextAttemptAt;
    if (next != null && next.isAfter(DateTime.now())) {
      return '${LangKeys.quizNextAttemptAt.tr()}: ${_dateTime(context, next)}';
    }

    final int? left = attemptsLeft;
    if (left == null) return LangKeys.quizAttemptsUnlimited.tr();
    if (left <= 0) return LangKeys.quizNoAttemptsLeft.tr();

    return '${LangKeys.quizAttemptsLeft.tr()}: $left';
  }

  String _dateTime(BuildContext context, DateTime value) {
    final MaterialLocalizations localizations = MaterialLocalizations.of(
      context,
    );

    return '${localizations.formatMediumDate(value)} '
        '${localizations.formatTimeOfDay(TimeOfDay.fromDateTime(value), alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context))}';
  }
}
