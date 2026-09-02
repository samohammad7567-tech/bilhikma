import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/models/notification_model.dart';
import '../../../../core/themes/app_theme.dart';

class NotificationCardText extends StatelessWidget {
  const NotificationCardText({required this.notification, super.key});

  final NotificationModel notification;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          notification.title,
          textAlign: TextAlign.start,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTheme.styles(context).cardTitle,
        ),

        SizedBox(height: 4.h),

        Text(
          notification.message,
          textAlign: TextAlign.start,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTheme.styles(context).cardSubtitle,
        ),
      ],
    );
  }
}
