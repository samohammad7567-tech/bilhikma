import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/routing/app_routes.dart';
import '../cubit/security_cubit.dart';
import '../../../../core/widgets/app_toast.dart';

class SecurityGuard extends StatelessWidget {
  const SecurityGuard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SecurityCubit>.value(
      value: getIt<SecurityCubit>(),
      child: BlocListener<SecurityCubit, SecurityState>(
        listenWhen: (SecurityState previous, SecurityState current) =>
            previous.status != current.status ||
            previous.eventId != current.eventId,
        listener: _onStateChanged,
        child: child,
      ),
    );
  }

  void _onStateChanged(BuildContext context, SecurityState state) {
    switch (state.status) {
      case SecurityStatus.warned:
        _showWarning(context);
      case SecurityStatus.suspended:
        _showSuspension(context);
      case SecurityStatus.idle:
        break;
    }
  }

  void _showWarning(BuildContext context) {
    AppToast.error(context, 'security_capture_warning'.tr());

    context.read<SecurityCubit>().acknowledgeWarning();
  }

  Future<void> _showSuspension(BuildContext context) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => PopScope(
        canPop: false,
        child: AlertDialog(
          title: Text('security_account_suspended_title'.tr()),
          content: Text('security_account_suspended'.tr()),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('confirm'.tr()),
            ),
          ],
        ),
      ),
    );

    getIt<GlobalKey<NavigatorState>>().currentState?.pushNamedAndRemoveUntil(
      AppRoutes.login,
      (Route<dynamic> route) => false,
    );
  }
}
