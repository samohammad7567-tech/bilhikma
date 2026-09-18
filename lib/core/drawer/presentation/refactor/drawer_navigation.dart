import 'package:flutter/material.dart';

import '../../../di/service_locator.dart';
import '../../../enums/drawer_destination_enum.dart';
import '../../../routing/app_routes.dart';
import '../../../services/device_session_service.dart';
import '../widgets/logout_confirm_dialog.dart';

class DrawerNavigation {
  DrawerNavigation._();
  static void open(BuildContext context, DrawerDestination destination) {
    Scaffold.of(context).closeDrawer();

    switch (destination) {
      case DrawerDestination.saved:
        getIt<GlobalKey<NavigatorState>>().currentState?.pushNamed(
          AppRoutes.archive,
        );
      case DrawerDestination.pictures:
        getIt<GlobalKey<NavigatorState>>().currentState?.pushNamed(
          AppRoutes.pictures,
        );

      case DrawerDestination.search:
        getIt<GlobalKey<NavigatorState>>().currentState?.pushNamed(
          AppRoutes.search,
        );
      case DrawerDestination.settings:
        getIt<GlobalKey<NavigatorState>>().currentState?.pushNamed(
          AppRoutes.settings,
        );

      case DrawerDestination.account:
        getIt<GlobalKey<NavigatorState>>().currentState?.pushNamed(
          AppRoutes.profile,
        );
      case DrawerDestination.learningPaths:
        getIt<GlobalKey<NavigatorState>>().currentState?.pushNamed(
          AppRoutes.educationalPathways,
        );
    }
  }

  static Future<void> logout(BuildContext context) async {
    final ScaffoldState scaffold = Scaffold.of(context);

    final bool isConfirmed = await LogoutConfirmDialog.show(context);
    if (!isConfirmed) return;

    if (scaffold.mounted) scaffold.closeDrawer();
    DeviceSessionService.logout();

    getIt<GlobalKey<NavigatorState>>().currentState?.pushNamedAndRemoveUntil(
      AppRoutes.login,
      (Route<dynamic> route) => false,
    );
  }
}
