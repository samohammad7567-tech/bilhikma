import 'package:flutter/material.dart';

import 'drawer_brand_header.dart';
import 'drawer_profile_card.dart';
import '../../../enums/drawer_destination_enum.dart';
import '../refactor/drawer_navigation.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class DrawerHead extends StatelessWidget {
  const DrawerHead({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(bottom: (34).h(context)),
          child: const DrawerBrandHeader(),
        ),

        PositionedDirectional(
          start: (14).w(context),
          end: (14).h(context),
          bottom: (0).h(context),
          child: DrawerProfileCard(
            onTap: () =>
                DrawerNavigation.open(context, DrawerDestination.account),
          ),
        ),
      ],
    );
  }
}
