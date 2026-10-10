import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/routing/notification_destination.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../data/models/notification_model.dart';
import '../cubit/notifications_cubit.dart';
import 'notifications_list.dart';
import '../widgets/notifications_empty_view.dart';

class NotificationsBody extends StatelessWidget {
  const NotificationsBody({super.key});

  void _open(
    BuildContext context,
    NotificationsCubit cubit,
    NotificationModel item,
    NotificationDestination target,
  ) {
    cubit.markRead(item.id);

    Navigator.of(context).pushNamed(target.route, arguments: target.arguments);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationsCubit, NotificationsState>(
      builder: (BuildContext context, NotificationsState state) {
        final NotificationsCubit cubit = context.read<NotificationsCubit>();

        if (state.isFirstLoad) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.hasFailedOutright) {
          return AppErrorView(
            errorKey: state.errorKey,
            onRetry: cubit.loadNotifications,
          );
        }
        return RefreshIndicator(
          onRefresh: cubit.refresh,
          child: state.isEmpty
              ? const NotificationsEmptyView()
              : NotificationsList(
                  notifications: state.notifications,
                  onSeen: cubit.markSeen,
                  onOpen:
                      (
                        NotificationModel item,
                        NotificationDestination target,
                      ) => _open(context, cubit, item, target),
                ),
        );
      },
    );
  }
}
