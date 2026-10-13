import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../data/models/download_log_item.dart';
import '../cubit/downloads_log_cubit.dart';
import '../widgets/download_log_tile.dart';
import '../widgets/downloads_log_skeleton.dart';
import 'downloads_log_actions.dart';

class DownloadsLogBody extends StatelessWidget {
  const DownloadsLogBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DownloadsLogCubit, DownloadsLogState>(
      builder: (BuildContext context, DownloadsLogState state) {
        if (state.isFirstLoad) return const DownloadsLogSkeleton();

        if (state.hasFailed) {
          return AppErrorView(
            errorKey: state.errorKey,
            onRetry: context.read<DownloadsLogCubit>().loadDownloads,
          );
        }

        if (state.items.isEmpty) {
          return const AppEmptyView(
            icon: Icons.download_outlined,
            messageKey: 'no_downloads',
          );
        }

        return _DownloadsList(state: state);
      },
    );
  }
}

class _DownloadsList extends StatelessWidget {
  const _DownloadsList({required this.state});

  final DownloadsLogState state;

  @override
  Widget build(BuildContext context) {
    final DownloadsLogCubit cubit = context.read<DownloadsLogCubit>();

    return RefreshIndicator(
      onRefresh: cubit.refresh,
      child: ListView.separated(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: state.items.length,
        separatorBuilder: (_, _) => SizedBox(height: 10.h),
        itemBuilder: (BuildContext context, int index) {
          final DownloadLogItem item = state.items[index];

          return DownloadLogTile(
            item: item,
            isDeleting: state.isDeleting(item.fileName),
            onTap: () => DownloadsLogActions.openItem(context, item),
            onDelete: () =>
                DownloadsLogActions.confirmDelete(context, cubit, item),
          );
        },
      ),
    );
  }
}
