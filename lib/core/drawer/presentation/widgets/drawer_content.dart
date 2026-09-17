import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'drawer_menu_list.dart';
import '../../../enums/drawer_destination_enum.dart';
import '../../../widgets/custom_button.dart';
import '../refactor/drawer_navigation.dart';
import 'drawer_head.dart';

class DrawerContent extends StatelessWidget {
  const DrawerContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const DrawerHead(),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(top: 12.h),
            child: DrawerMenuList(
              onDestinationTap: (DrawerDestination destination) =>
                  DrawerNavigation.open(context, destination),
            ),
          ),
        ),

        SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
            child: CustomButton(
              onPressed: () => DrawerNavigation.logout(context),
              text: 'logout'.tr(),
              width: double.infinity,
              height: 48.h,
              threeRadius: 10.r,
              lastRadius: 10.r,
              backgroundColor: Theme.of(context).colorScheme.secondary,
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }
}
