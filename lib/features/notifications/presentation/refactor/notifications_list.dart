import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/models/notification_model.dart';
import '../widgets/notification_card.dart';
import '../widgets/notification_day_header.dart';
import '../../../../core/widgets/app_bottom_nav_bar.dart';
import 'notification_day_group.dart';
import 'notification_seen_tracker.dart';

class NotificationsList extends StatefulWidget {
  const NotificationsList({
    required this.groups,
    required this.onSeen,
    required this.onOpen,
    required this.openingId,
    super.key,
  });

  final List<NotificationDayGroup> groups;
  final ValueChanged<int> onSeen;
  final ValueChanged<NotificationModel> onOpen;

  final int? openingId;

  @override
  State<NotificationsList> createState() => _NotificationsListState();
}

class _NotificationsListState extends State<NotificationsList> {
  late final NotificationSeenTracker _tracker = NotificationSeenTracker(
    onSeen: widget.onSeen,
  );

  @override
  void initState() {
    super.initState();
    _tracker.schedule(context);
  }

  @override
  void didUpdateWidget(covariant NotificationsList oldWidget) {
    super.didUpdateWidget(oldWidget);

    final Set<int> ids = _ids(widget.groups);
    final Set<int> previous = _ids(oldWidget.groups);
    if (ids.length == previous.length && ids.containsAll(previous)) return;

    _tracker.retain(ids);
    _tracker.schedule(context);
  }

  @override
  void dispose() {
    _tracker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> rows = _rows();

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        _tracker.schedule(context);
        return false;
      },
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          16.w,
          0,
          16.w,
          AppBottomNavBar.barHeight + 24.h,
        ),
        itemCount: rows.length,
        itemBuilder: (BuildContext context, int index) => rows[index],
      ),
    );
  }

  /// Headers and cards flattened into one list, so the day a notification
  /// arrived scrolls away with it.
  List<Widget> _rows() {
    final List<Widget> rows = <Widget>[];

    for (final NotificationDayGroup group in widget.groups) {
      rows.add(NotificationDayHeader(label: group.label));

      for (final NotificationModel item in group.items) {
        rows.add(
          Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: _card(item),
          ),
        );
      }
    }

    return rows;
  }

  Widget _card(NotificationModel item) {
    final Widget card = NotificationCard(
      notification: item,
      isOpening: widget.openingId == item.id,
      onTap: () => widget.onOpen(item),
    );

    // Only unread cards are measured — the rest have nothing left to mark.
    if (item.isRead) return card;

    return KeyedSubtree(key: _tracker.keyFor(item.id), child: card);
  }

  Set<int> _ids(List<NotificationDayGroup> groups) => <int>{
    for (final NotificationDayGroup group in groups)
      ...group.items.map((NotificationModel item) => item.id),
  };
}
