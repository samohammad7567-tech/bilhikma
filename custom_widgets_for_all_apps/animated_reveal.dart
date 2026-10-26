/// The one entrance motion a screen reuses: a fade with a small slide, and an
/// optional stagger down a run of items.
///
/// Drop-in and self-contained: pure Flutter, no packages, no theme lookups and
/// no project-relative imports, so this file can be copied into any app as-is.
/// Pairs with the other
/// `animated_*.dart` widgets in this folder.
///
/// One section arriving:
///
/// ```dart
/// AnimatedReveal(child: ProfileHeader())
/// ```
///
/// A run of items, each trailing the one before it:
///
/// ```dart
/// ListView.builder(
///   itemCount: lessons.length,
///   itemBuilder: (BuildContext context, int index) => AnimatedReveal(
///     index: index,
///     child: LessonCard(lessons[index]),
///   ),
/// )
/// ```
///
/// A fixed column of sections, staggered without threading indices by hand:
///
/// ```dart
/// Column(
///   children: AnimatedReveal.list(<Widget>[
///     BalanceCard(),
///     QuickActions(),
///     RecentActivity(),
///   ]),
/// )
/// ```
///
/// Sliding in from the leading edge instead of up — right in Arabic, left in
/// English:
///
/// ```dart
/// AnimatedReveal(from: RevealFrom.start, child: ChatBubble(message))
/// ```
///
/// ## Notes
///
/// * **No timers.** The delay is folded into an [Interval] on a single tween,
///   so there is nothing to cancel when an item is scrolled off and disposed
///   mid-flight — the usual source of "setState called after dispose" in
///   hand-rolled staggers.
/// * **The stagger is capped.** Past [AnimatedReveal.maxStaggerIndex] the delay
///   stops growing, so item 400 in a long list does not wait seven seconds to
///   appear. Keep the cap at roughly what fills one screen.
/// * **It animates once, on first build.** Re-parenting or rebuilding does not
///   replay it. To replay deliberately — a tab switch, a refresh — change the
///   [Key] of the subtree.
/// * **Direction-aware.** [RevealFrom.start] and [RevealFrom.end] follow the
///   ambient [Directionality]; [RevealFrom.top] and [RevealFrom.bottom] do not.
/// * Keep the travel short. Anything past ~20 logical pixels reads as the UI
///   sliding about rather than settling in.
/// * Honours the platform "reduce motion" setting: the child is rendered
///   immediately and nothing animates.
library;

import 'package:flutter/material.dart';

/// The edge the child travels in from.
enum RevealFrom {
  /// Fade only, no travel.
  none,

  /// Rises into place — the safest default.
  bottom,

  /// Drops into place. Suits banners and anything anchored to the top.
  top,

  /// Slides in from the leading edge: the right in Arabic, the left in
  /// English.
  start,

  /// Slides in from the trailing edge: the left in Arabic, the right in
  /// English.
  end,
}

/// Fades and slides [child] in once, on first build.
class AnimatedReveal extends StatelessWidget {
  const AnimatedReveal({
    required this.child,
    super.key,
    this.index = 0,
    this.maxStaggerIndex = 8,
    this.from = RevealFrom.bottom,
    this.distance = 14,
    this.scaleFrom = 1,
    this.duration = const Duration(milliseconds: 420),
    this.stagger = const Duration(milliseconds: 60),
    this.delay = Duration.zero,
    this.curve = Curves.easeOutCubic,
    this.respectReducedMotion = true,
  });

  /// The widget being revealed.
  final Widget child;

  /// Position in the run, which sets how long this item waits.
  final int index;

  /// Cap on [index]. Beyond it the delay stops growing.
  final int maxStaggerIndex;

  /// Edge the child travels in from.
  final RevealFrom from;

  /// Travel distance in logical pixels. Ignored for [RevealFrom.none].
  final double distance;

  /// Starting scale, for a subtle pop. `1` disables it; `0.96` is plenty.
  final double scaleFrom;

  /// Length of one item's animation, excluding its stagger delay.
  final Duration duration;

  /// Delay added per [index] step.
  final Duration stagger;

  /// Delay before the whole thing starts — for content that should land after
  /// a page transition has settled.
  final Duration delay;

  /// Easing. Decelerating curves look right for an entrance.
  final Curve curve;

  /// When true (the default), the platform "reduce motion" setting renders the
  /// child immediately instead of animating it in.
  final bool respectReducedMotion;

  /// Wraps each of [children] in an [AnimatedReveal] carrying its index, for a
  /// fixed run where threading indices by hand would just be noise.
  ///
  /// ```dart
  /// Column(children: AnimatedReveal.list(sections))
  /// ```
  static List<Widget> list(
    List<Widget> children, {
    RevealFrom from = RevealFrom.bottom,
    int maxStaggerIndex = 8,
    double distance = 14,
    double scaleFrom = 1,
    Duration duration = const Duration(milliseconds: 420),
    Duration stagger = const Duration(milliseconds: 60),
    Duration delay = Duration.zero,
  }) {
    return <Widget>[
      for (int i = 0; i < children.length; i++)
        AnimatedReveal(
          index: i,
          from: from,
          maxStaggerIndex: maxStaggerIndex,
          distance: distance,
          scaleFrom: scaleFrom,
          duration: duration,
          stagger: stagger,
          delay: delay,
          child: children[i],
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (respectReducedMotion && MediaQuery.disableAnimationsOf(context)) {
      return child;
    }

    final Duration lead = delay + (stagger * index.clamp(0, maxStaggerIndex));
    final Duration total = duration + lead;

    // A zero-length animation has no interval to sit inside, and Interval
    // asserts on begin >= end.
    if (total <= Duration.zero) return child;

    final double start = lead.inMicroseconds / total.inMicroseconds;
    if (start >= 1) return child;

    final TextDirection direction = Directionality.of(context);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: total,
      // The wait is part of the curve rather than a timer: the tween runs for
      // the whole window and simply holds at zero until this item's turn.
      curve: Interval(start, 1, curve: curve),
      // Passed as `child` so the subtree is not rebuilt on every frame — only
      // the transforms above it.
      child: child,
      builder: (BuildContext context, double t, Widget? child) =>
          _transform(t, direction, child ?? const SizedBox.shrink()),
    );
  }

  Widget _transform(double t, TextDirection direction, Widget child) {
    Widget result = child;

    if (scaleFrom != 1) {
      result = Transform.scale(
        scale: scaleFrom + ((1 - scaleFrom) * t),
        child: result,
      );
    }

    final Offset offset = _offset(t, direction);

    if (offset != Offset.zero) {
      result = Transform.translate(offset: offset, child: result);
    }

    return Opacity(opacity: t.clamp(0.0, 1.0), child: result);
  }

  Offset _offset(double t, TextDirection direction) {
    final double travel = (1 - t) * distance;
    final bool isRtl = direction == TextDirection.rtl;

    return switch (from) {
      RevealFrom.none => Offset.zero,
      RevealFrom.bottom => Offset(0, travel),
      RevealFrom.top => Offset(0, -travel),
      RevealFrom.start => Offset(isRtl ? travel : -travel, 0),
      RevealFrom.end => Offset(isRtl ? -travel : travel, 0),
    };
  }
}
