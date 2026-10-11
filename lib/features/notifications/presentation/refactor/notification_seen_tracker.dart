import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Marks notifications read once they have actually been looked at.
///
/// A card counts as seen when most of it has stayed inside the viewport for
/// a moment — flicking straight past it does not count.
class NotificationSeenTracker {
  NotificationSeenTracker({required this.onSeen});

  final ValueChanged<int> onSeen;

  /// Share of a card that must be on screen for it to count.
  static const double _visibleFraction = 0.6;

  static const Duration _dwell = Duration(milliseconds: 600);

  final Map<int, GlobalKey> _keys = <int, GlobalKey>{};
  final Set<int> _seen = <int>{};

  Timer? _timer;

  /// Handle to attach to the card for [id], so it can be measured.
  GlobalKey keyFor(int id) => _keys.putIfAbsent(id, GlobalKey.new);

  /// Forgets cards that are no longer in the list, so a notification that
  /// comes back around is measured again rather than silently skipped.
  void retain(Set<int> ids) {
    _keys.removeWhere((int id, GlobalKey key) => !ids.contains(id));
    _seen.removeWhere((int id) => !ids.contains(id));
  }

  /// Restarts the dwell timer. Called on every scroll tick, so a scan only
  /// runs once the list has settled.
  void schedule(BuildContext context) {
    _timer?.cancel();
    _timer = Timer(_dwell, () => _scan(context));
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
  }

  void _scan(BuildContext context) {
    if (!context.mounted) return;

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
      onSeen(entry.key);
    }
  }
}
