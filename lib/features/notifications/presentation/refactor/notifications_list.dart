import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/models/notification_model.dart';
import '../widgets/notification_card.dart';
import '../../../../core/widgets/app_bottom_nav_bar.dart';

class NotificationsList extends StatefulWidget {
  const NotificationsList({
    required this.notifications,
    required this.onSeen,
    super.key,
  });

  final List<NotificationModel> notifications;
  final ValueChanged<int> onSeen;

  @override
  State<NotificationsList> createState() => _NotificationsListState();
}

class _NotificationsListState extends State<NotificationsList> {
  static const double _visibleFraction = 0.6;

  static const Duration _dwell = Duration(milliseconds: 600);

  final Map<int, GlobalKey> _keys = <int, GlobalKey>{};
  final Set<int> _seen = <int>{};
  Timer? _dwellTimer;

  @override
  void initState() {
    super.initState();
    _scheduleScan();
  }

  @override
  void didUpdateWidget(covariant NotificationsList oldWidget) {
    super.didUpdateWidget(oldWidget);

    final Set<int> ids = _ids(widget.notifications);
    final Set<int> previous = _ids(oldWidget.notifications);
    if (ids.length == previous.length && ids.containsAll(previous)) return;

    _keys.removeWhere((int id, GlobalKey key) => !ids.contains(id));
    _seen.removeWhere((int id) => !ids.contains(id));
    _scheduleScan();
  }

  @override
  void dispose() {
    _dwellTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        _scheduleScan();
        return false;
      },
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          16.w,
          4.h,
          16.w,
          AppBottomNavBar.barHeight + 24.h,
        ),
        itemCount: widget.notifications.length,
        separatorBuilder: (BuildContext context, int index) =>
            SizedBox(height: 10.h),
        itemBuilder: (BuildContext context, int index) {
          final NotificationModel item = widget.notifications[index];
          final Widget card = NotificationCard(notification: item);

          if (item.isRead) return card;

          return KeyedSubtree(
            key: _keys.putIfAbsent(item.id, GlobalKey.new),
            child: card,
          );
        },
      ),
    );
  }

  void _scheduleScan() {
    _dwellTimer?.cancel();
    _dwellTimer = Timer(_dwell, _scan);
  }

  void _scan() {
    if (!mounted) return;

    final RenderObject? viewport = context.findRenderObject();
    if (viewport is! RenderBox || !viewport.hasSize) return;

    final double viewportTop = viewport.localToGlobal(Offset.zero).dy;
    final double viewportBottom = viewportTop + viewport.size.height;

    for (final MapEntry<int, GlobalKey> entry in _keys.entries.toList(
      growable: false,
    )) {
      if (_seen.contains(entry.key)) continue;

      final RenderObject? card = entry.value.currentContext?.findRenderObject();
      if (card is! RenderBox || !card.hasSize) continue;

      final double cardTop = card.localToGlobal(Offset.zero).dy;
      final double visible =
          math.min(cardTop + card.size.height, viewportBottom) -
          math.max(cardTop, viewportTop);

      if (visible < card.size.height * _visibleFraction) continue;

      _seen.add(entry.key);
      widget.onSeen(entry.key);
    }
  }

  Set<int> _ids(List<NotificationModel> items) =>
      items.map((NotificationModel item) => item.id).toSet();
}
