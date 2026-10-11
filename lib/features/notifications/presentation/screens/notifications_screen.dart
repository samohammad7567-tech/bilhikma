import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/drawer/presentation/refactor/app_drawer.dart';
import '../../../../core/widgets/app_section_scaffold.dart';
import '../cubit/notifications_cubit.dart';
import '../refactor/notifications_body.dart';
import '../../../../core/widgets/app_toast.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key, this.showBack = true});
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<NotificationsCubit>.value(
      value: getIt<NotificationsCubit>(),
      child: BlocListener<NotificationsCubit, NotificationsState>(
        listenWhen: (NotificationsState previous, NotificationsState current) =>
            current.errorKey != null && current.notifications.isNotEmpty,
        listener: _showRefreshError,
        child: AppSectionScaffold(
          title: context.tr('notifications'),
          showBack: showBack,
          showMenu: true,
          // Only when pushed: as a tab the shell already hosts the drawer,
          // and a second one would just shadow it.
          drawer: showBack ? const AppDrawer() : null,
          child: const NotificationsBody(),
        ),
      ),
    );
  }

  void _showRefreshError(BuildContext context, NotificationsState state) {
    final String? errorKey = state.errorKey;
    if (errorKey == null) return;

    AppToast.error(context, errorKey.tr());
  }
}
