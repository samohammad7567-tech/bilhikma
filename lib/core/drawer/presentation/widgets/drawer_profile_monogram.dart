import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'drawer_profile_initials.dart';

class DrawerProfileMonogram extends StatelessWidget {
  const DrawerProfileMonogram({this.avatarUrl, super.key});

  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final double size = 52.w;

    return ClipOval(
      child: Container(
        width: size,
        height: size,
        color: Theme.of(context).colorScheme.secondaryContainer,
        alignment: Alignment.center,
        child: DrawerProfileInitials(),
      ),
    );
  }
}
