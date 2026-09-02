import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NotificationUnreadDot extends StatelessWidget {
  const NotificationUnreadDot({super.key});

  @override
  Widget build(BuildContext context) => Container(
    width: 8.w,
    height: 8.w,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.error,
      shape: BoxShape.circle,
    ),
  );
}
