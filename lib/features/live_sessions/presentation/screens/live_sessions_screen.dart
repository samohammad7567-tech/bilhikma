import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/widgets/app_section_scaffold.dart';
import '../../../../core/drawer/presentation/refactor/app_drawer.dart';
import '../../../../core/models/live_session_model.dart';
import '../cubit/live_sessions_cubit.dart';
import '../refactor/live_sessions_body.dart';
import '../../../../core/widgets/app_toast.dart';

class LiveSessionsScreen extends StatelessWidget {
  const LiveSessionsScreen({
    super.key,
    this.showBack = true,
    this.onBack,
    this.onMenuTap,
  });

  final bool showBack;

  final VoidCallback? onBack;
  final VoidCallback? onMenuTap;

  @override
  Widget build(BuildContext context) {
    final bool hasHostDrawer = Scaffold.maybeOf(context)?.hasDrawer ?? false;

    return BlocProvider<LiveSessionsCubit>(
      create: (_) => getIt<LiveSessionsCubit>(),
      child: BlocListener<LiveSessionsCubit, LiveSessionsState>(
        listenWhen: (LiveSessionsState previous, LiveSessionsState current) =>
            current.messageKey != null ||
            (current.errorKey != null && current.sessions != null),
        listener: _showMessage,
        child: AppSectionScaffold(
          title: context.tr('live_broadcast'),
          showBack: showBack,
          onBack: onBack,
          drawer: hasHostDrawer ? null : const AppDrawer(),
          showMenu: !showBack,
          onMenuTap: onMenuTap,
          child: Builder(
            builder: (BuildContext context) => LiveSessionsBody(
              onWatch: (LiveSessionModel session) => Navigator.of(
                context,
              ).pushNamed(AppRoutes.livePlayer, arguments: session),
              onRemind: (LiveSessionModel session) =>
                  _report(context, 'reminder_saved'),
            ),
          ),
        ),
      ),
    );
  }

  void _report(BuildContext context, String messageKey) =>
      context.read<LiveSessionsCubit>().reportMessage(messageKey);

  void _showMessage(BuildContext context, LiveSessionsState state) {
    final String? key = state.messageKey ?? state.errorKey;
    if (key == null) return;

    if (state.messageKey == null) {
      AppToast.error(context, key.tr());
      return;
    }

    AppToast.show(context, key.tr());
  }
}
