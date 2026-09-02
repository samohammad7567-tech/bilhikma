import 'package:flutter/material.dart';
import '../../../../core/enums/profile_action_enum.dart';
import '../../../../core/routing/app_routes.dart';
import '../cubit/profile_cubit.dart';

class ProfileActionHandler {
  ProfileActionHandler._();

  static Future<void> handle(
    BuildContext context,
    ProfileCubit cubit,
    ProfileAction action,
  ) async {
    switch (action) {
      case ProfileAction.editInformation:
        final Object? changed = await Navigator.of(
          context,
        ).pushNamed(AppRoutes.editProfile, arguments: cubit.state.profile);

        if (changed == true) await cubit.loadProfile();

      case ProfileAction.changePassword:
        await Navigator.of(context).pushNamed(AppRoutes.changePassword);

      case ProfileAction.downloadsLog:
        await Navigator.of(context).pushNamed(AppRoutes.downloadsLog);
    }
  }
}
