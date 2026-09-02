import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/models/live_session_model.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../../core/utils/live_formats.dart';
import '../../../../core/widgets/lesson_meta_item.dart';
import '../../../../core/widgets/ornamented_card.dart';

class LivePlayerSummaryCard extends StatelessWidget {
  const LivePlayerSummaryCard({required this.session, super.key});

  final LiveSessionModel session;

  @override
  Widget build(BuildContext context) {
    final String description = session.description ?? '';

    return OrnamentedCard(
      radius: 14.r,
      padding: EdgeInsets.all(14.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            session.title,
            textAlign: TextAlign.start,
            style: AppTheme.styles(context).cardTitle,
          ),

          if (description.isNotEmpty) ...<Widget>[
            SizedBox(height: 6.h),
            Text(
              description,
              textAlign: TextAlign.start,
              style: AppTheme.styles(context).labelStrong.copyWith(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ],

          if (session.scheduledAt != null) ...<Widget>[
            SizedBox(height: 12.h),
            Row(
              children: <Widget>[
                Flexible(
                  child: LessonMetaItem(
                    icon: Icons.calendar_month_outlined,
                    label: LiveFormats.date(session.scheduledAt!),
                  ),
                ),

                SizedBox(width: 14.w),

                Flexible(
                  child: LessonMetaItem(
                    icon: Icons.access_time,
                    label: LiveFormats.time(session.scheduledAt!),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
