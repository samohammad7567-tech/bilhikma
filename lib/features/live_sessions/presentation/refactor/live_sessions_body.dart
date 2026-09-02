import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/models/live_session_model.dart';
import '../cubit/live_sessions_cubit.dart';
import '../widgets/live_sessions_list.dart';
import '../widgets/live_sessions_empty_view.dart';

class LiveSessionsBody extends StatelessWidget {
  const LiveSessionsBody({
    required this.onWatch,
    required this.onRemind,
    super.key,
  });

  final ValueChanged<LiveSessionModel> onWatch;
  final ValueChanged<LiveSessionModel> onRemind;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LiveSessionsCubit, LiveSessionsState>(
      builder: (BuildContext context, LiveSessionsState state) {
        final LiveSessionsCubit cubit = context.read<LiveSessionsCubit>();

        if (state.isFirstLoad) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.hasFailed) {
          return AppErrorView(
            errorKey: state.errorKey,
            onRetry: cubit.loadSessions,
          );
        }

        return RefreshIndicator(
          onRefresh: cubit.refresh,
          child: state.isEmpty
              ? const LiveSessionsEmptyView()
              : LiveSessionsList(
                  sessions: state.visibleSessions,
                  onWatch: onWatch,
                  onRemind: onRemind,
                ),
        );
      },
    );
  }
}
