import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'drawer_brand_header.dart';
import 'drawer_profile_card.dart';
import '../../../enums/drawer_destination_enum.dart';
import '../refactor/drawer_navigation.dart';

class DrawerHead extends StatelessWidget {
  const DrawerHead({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(bottom: 34.h),
          child: const DrawerBrandHeader(),
        ),

        PositionedDirectional(
          start: 14.w,
          end: 14.w,
          bottom: 0,
          child: DrawerProfileCard(
            onTap: () =>
                DrawerNavigation.open(context, DrawerDestination.account),
          ),
        ),
      ],
    );
  }
}
