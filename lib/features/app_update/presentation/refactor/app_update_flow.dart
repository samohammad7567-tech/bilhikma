import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/app_logger.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../data/models/app_version_model.dart';
import '../cubit/app_update_cubit.dart';
import '../widgets/app_update_dialog.dart';

/// The hand-off between the splash and the rest of the app.
///
/// `AppUpdateGate` already owns the blocking statuses; this is the half that
/// has to happen at a specific moment — the optional offer, which is shown
/// once the splash is done rather than over it, so the splash's own timer
/// cannot pull the dialog away mid-read.
class AppUpdateFlow {
  AppUpdateFlow._();

  /// How long the hand-off is willing to wait for a verdict that has not
  /// arrived yet.
  ///
  /// The check starts with the splash and normally answers long before it ends.
  /// This cap is for the case where it does not: a check still in flight is
  /// abandoned rather than allowed to hold the launch open, because a slow
  /// network must cost the user nothing. The verdict is simply missed for this
  /// launch, and the next one asks again.
  static const Duration maxWait = Duration(seconds: 4);

  /// Returns whether the caller may navigate on into the app.
  ///
  /// False means something else now owns the screen — the blocking screen, or
  /// the browser the user was just handed.
  static Future<bool> resolve(BuildContext context) async {
    final AppUpdateCubit cubit = context.read<AppUpdateCubit>();

    await _awaitVerdict(cubit);

    if (!context.mounted) return false;

    return switch (cubit.state) {
      // The gate is already showing the dead-end screen; do not navigate over it.
      AppUpdateBlocked() => false,
      AppUpdateOptional(version: final AppVersionModel version) => _offerUpdate(
        context,
        cubit,
        version,
      ),
      // ok, "later", a failed check, or a check that never answered.
      _ => true,
    };
  }

  static Future<void> _awaitVerdict(AppUpdateCubit cubit) async {
    try {
      await cubit.settled.timeout(maxWait);
    } on TimeoutException {
      AppLogger.warning(
        'Version check had not answered after ${maxWait.inSeconds}s — '
        'continuing without a verdict',
        name: 'app_update',
      );
    }
  }

  /// The optional offer always ends with the user inside the app: it is an
  /// offer, not a gate. Tapping update sends them to the download and lets the
  /// app continue behind it, so coming back from the browser does not leave
  /// them stranded on a splash screen.
  static Future<bool> _offerUpdate(
    BuildContext context,
    AppUpdateCubit cubit,
    AppVersionModel version,
  ) async {
    final bool wantsUpdate = await AppUpdateDialog.show(context, version);

    if (!wantsUpdate) {
      cubit.dismissOptional();
      return true;
    }

    final bool opened = await cubit.openStore();

    cubit.dismissOptional();

    if (!opened && context.mounted) {
      AppToast.error(context, 'update_store_open_failed'.tr());
    }

    return true;
  }
}
