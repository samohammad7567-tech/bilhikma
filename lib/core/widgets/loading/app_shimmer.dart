import 'package:flutter/material.dart';

import '../../themes/app_motion.dart';

/// Carries one sweep animation down to every [AppShimmer] below it, so a list
/// of skeleton rows runs on a single ticker instead of one per row.
class AppShimmerDriver extends InheritedWidget {
  const AppShimmerDriver({
    required this.sweep,
    required super.child,
    super.key,
  });

  final Animation<double> sweep;

  static Animation<double>? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppShimmerDriver>()?.sweep;

  @override
  bool updateShouldNotify(AppShimmerDriver oldWidget) =>
      sweep != oldWidget.sweep;
}

/// Owns one sweep and hands it to every [AppShimmer] beneath, so a composite
/// skeleton of many blocks still runs on a single ticker.
///
/// Under reduced motion the sweep is held still and no frame is scheduled.
class AppShimmerGroup extends StatefulWidget {
  const AppShimmerGroup({required this.child, super.key});

  final Widget child;

  @override
  State<AppShimmerGroup> createState() => _AppShimmerGroupState();
}

class _AppShimmerGroupState extends State<AppShimmerGroup>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.shimmer,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
      return;
    }

    if (!_controller.isAnimating) _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      AppShimmerDriver(sweep: _controller, child: widget.child);
}

/// Sweeps a soft highlight across whatever skeleton blocks it wraps.
///
/// Uses the sweep from an ancestor [AppShimmerDriver] when there is one, and
/// otherwise owns a controller of its own. Under reduced motion the highlight
/// is painted once and held still, leaving no frame scheduled.
class AppShimmer extends StatefulWidget {
  const AppShimmer({required this.child, super.key});

  final Widget child;

  @override
  State<AppShimmer> createState() => _AppShimmerState();
}

class _AppShimmerState extends State<AppShimmer>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  Animation<double> _sweep = const AlwaysStoppedAnimation<double>(0.5);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final Animation<double>? shared = AppShimmerDriver.maybeOf(context);

    if (shared != null) {
      _disposeController();
      _sweep = shared;
      return;
    }

    final AnimationController controller = _controller ??= AnimationController(
      vsync: this,
      duration: AppMotion.shimmer,
    );
    _sweep = controller;

    if (MediaQuery.disableAnimationsOf(context)) {
      controller.stop();
      return;
    }

    if (!controller.isAnimating) controller.repeat();
  }

  void _disposeController() {
    _controller?.dispose();
    _controller = null;
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;
    final Color highlight = Theme.of(context).colorScheme.surface;

    return AnimatedBuilder(
      animation: _sweep,
      builder: (BuildContext context, Widget? child) => ShaderMask(
        blendMode: BlendMode.srcATop,
        shaderCallback: (Rect bounds) => _shader(bounds, highlight, isRtl),
        child: child,
      ),
      child: widget.child,
    );
  }

  Shader _shader(Rect bounds, Color highlight, bool isRtl) {
    const double band = 0.3;

    // Travels from fully off one edge to fully off the other.
    final double head = -band + _sweep.value * (1 + 2 * band);

    return LinearGradient(
      begin: isRtl ? Alignment.centerRight : Alignment.centerLeft,
      end: isRtl ? Alignment.centerLeft : Alignment.centerRight,
      colors: <Color>[
        highlight.withValues(alpha: 0),
        highlight.withValues(alpha: 0.55),
        highlight.withValues(alpha: 0),
      ],
      stops: <double>[
        (head - band).clamp(0.0, 1.0),
        head.clamp(0.0, 1.0),
        (head + band).clamp(0.0, 1.0),
      ],
    ).createShader(bounds);
  }
}
