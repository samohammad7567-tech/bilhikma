import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../utils/live_formats.dart';
import '../models/live_session_model.dart';
import '../themes/app_theme.dart';
import 'lesson_meta_item.dart';
import 'live_session_action_button.dart';

class LiveSessionDetails extends StatelessWidget {
  const LiveSessionDetails({
    required this.session,
    required this.onWatch,
    required this.onRemind,
    super.key,
  });

  final LiveSessionModel session;
  final VoidCallback onWatch;
  final VoidCallback onRemind;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          session.title,
          textAlign: TextAlign.start,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTheme.styles(context).cardTitle,
        ),

        SizedBox(height: 4.h),

        if ((session.description ?? '').isNotEmpty) ...<Widget>[
          Text(
            session.description!,
            textAlign: TextAlign.start,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.styles(context).labelStrong.copyWith(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),

          SizedBox(height: 10.h),
        ],

        if (session.scheduledAt != null) ...<Widget>[
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

          SizedBox(height: 12.h),
        ],

        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: LiveSessionActionButton(
            isLive: session.isLive,
            onWatch: onWatch,
            onRemind: onRemind,
          ),
        ),
      ],
    );
  }
}
