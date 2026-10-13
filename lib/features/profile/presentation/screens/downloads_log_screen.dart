import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/widgets/app_section_scaffold.dart';
import '../../../../core/widgets/app_toast.dart';
import '../cubit/downloads_log_cubit.dart';
import '../refactor/downloads_log_actions.dart';
import '../refactor/downloads_log_body.dart';
import '../widgets/downloads_log_delete_all_button.dart';

class DownloadsLogScreen extends StatelessWidget {
  const DownloadsLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DownloadsLogCubit>(
      create: (_) => getIt<DownloadsLogCubit>(),
      child: BlocConsumer<DownloadsLogCubit, DownloadsLogState>(
        listenWhen: (DownloadsLogState previous, DownloadsLogState current) =>
            previous.errorKey != current.errorKey ||
            previous.messageKey != current.messageKey,
        listener: _showMessage,
        buildWhen: (DownloadsLogState previous, DownloadsLogState current) =>
            previous.canDeleteAll != current.canDeleteAll ||
            previous.isDeletingAll != current.isDeletingAll,
        builder: (BuildContext context, DownloadsLogState state) =>
            AppSectionScaffold(
              title: context.tr('downloads_log'),
              trailing: DownloadsLogDeleteAllButton(
                isEnabled: state.canDeleteAll,
                isDeletingAll: state.isDeletingAll,
                onPressed: () => DownloadsLogActions.confirmDeleteAll(
                  context,
                  context.read<DownloadsLogCubit>(),
                ),
              ),
              child: const DownloadsLogBody(),
            ),
      ),
    );
  }

  void _showMessage(BuildContext context, DownloadsLogState state) {
    final String? errorKey = state.errorKey;
    if (errorKey != null) {
      AppToast.error(context, errorKey.tr());
      return;
    }

    final String? messageKey = state.messageKey;
    if (messageKey != null) AppToast.success(context, messageKey.tr());
  }
}
