import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/app_logger.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../data/models/app_version_model.dart';
import '../cubit/app_update_cubit.dart';
import '../widgets/app_update_dialog.dart';

class AppUpdateFlow {
  AppUpdateFlow._();
  static const Duration maxWait = Duration(seconds: 4);
  static Future<bool> resolve(BuildContext context) async {
    final AppUpdateCubit cubit = context.read<AppUpdateCubit>();

    await _awaitVerdict(cubit);

    if (!context.mounted) return false;

    return switch (cubit.state) {
      AppUpdateBlocked() => false,
      AppUpdateOptional(version: final AppVersionModel version) => _offerUpdate(
        context,
        cubit,
        version,
      ),
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
