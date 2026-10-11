import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/routing/notification_destination.dart';
import '../../../../core/utils/custom_bottom_sheet.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../data/models/notification_model.dart';
import '../cubit/notifications_cubit.dart';
import 'notifications_list.dart';
import '../widgets/notification_details_sheet.dart';
import '../widgets/notification_filter_tabs.dart';
import '../widgets/notifications_empty_view.dart';

class NotificationsBody extends StatelessWidget {
  const NotificationsBody({super.key});

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

        return Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 4.h),
              child: NotificationFilterTabs(
                filter: state.filter,
                totalCount: state.notifications.length,
                unreadCount: state.unreadCount,
                onSelected: cubit.selectFilter,
              ),
            ),

            Expanded(
              child: RefreshIndicator(
                onRefresh: cubit.refresh,
                child: state.hasNothingToShow
                    ? NotificationsEmptyView(
                        messageKey: state.isUnreadTab
                            ? 'no_unread_notifications'
                            : 'no_notifications',
                      )
                    : NotificationsList(
                        groups: state.groups,
                        openingId: state.openingId,
                        onSeen: cubit.markSeen,
                        onOpen: (NotificationModel item) =>
                            _open(context, cubit, item),
                      ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// A notification that names a screen opens it; one that names none shows
  /// its own content instead, so no card is a dead tap.
  Future<void> _open(
    BuildContext context,
    NotificationsCubit cubit,
    NotificationModel item,
  ) async {
    if (cubit.state.openingId != null) return;

    final NavigatorState navigator = Navigator.of(context);

    final NotificationDestination? target = await cubit.open(item);

    if (!context.mounted) return;

    if (target == null) {
      CustomBottomSheet.showModalBottomSheetContainer(
        context: context,
        widget: NotificationDetailsSheet(notification: item),
      );
      return;
    }

    navigator.pushNamed(target.route, arguments: target.arguments);
  }
}
