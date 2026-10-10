import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NotificationUnreadDot extends StatelessWidget {
  const NotificationUnreadDot({required this.color, super.key});

  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 8.w,
    height: 8.w,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}
