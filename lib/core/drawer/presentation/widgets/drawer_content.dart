import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'drawer_menu_list.dart';
import '../../../enums/drawer_destination_enum.dart';
import '../../../widgets/custom_button.dart';
import '../refactor/drawer_navigation.dart';
import 'drawer_head.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class DrawerContent extends StatelessWidget {
  const DrawerContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const DrawerHead(),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(top: (12).h(context)),
            child: DrawerMenuList(
              onDestinationTap: (DrawerDestination destination) =>
                  DrawerNavigation.open(context, destination),
            ),
          ),
        ),

        SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB((16).w(context), (12).h(context), (16).w(context), (16).h(context)),
            child: CustomButton(
              onPressed: () => DrawerNavigation.logout(context),
              text: 'logout'.tr(),
              width: double.infinity,
              height: (48).h(context),
              threeRadius: 10,
              lastRadius: 10,
              backgroundColor: Theme.of(context).colorScheme.secondary,
              elevation: (0).r(context),
            ),
          ),
        ),
      ],
    );
  }
}
