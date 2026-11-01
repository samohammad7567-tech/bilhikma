import 'package:flutter/material.dart';

class _ShimmerControllerScope extends InheritedWidget {
  const _ShimmerControllerScope({
    required this.controller,
    required super.child,
  });

  final AnimationController controller;

  static AnimationController? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_ShimmerControllerScope>()
        ?.controller;
  }

  @override
  bool updateShouldNotify(_ShimmerControllerScope oldWidget) =>
      oldWidget.controller != controller;
}

class AppShimmer extends StatefulWidget {
  const AppShimmer({required this.child, super.key});

  final Widget child;

  @override
  State<AppShimmer> createState() => _AppShimmerState();
}

class _AppShimmerState extends State<AppShimmer>
    with SingleTickerProviderStateMixin {
  AnimationController? _localController;
  bool _ownsController = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final AnimationController? shared = _ShimmerControllerScope.of(context);
    if (shared != null) {
      _ownsController = false;
      _localController = shared;
      return;
    }

    if (_localController == null) {
      _localController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1400),
      );
      _ownsController = true;
    }

    if (MediaQuery.disableAnimationsOf(context)) {
      _localController!.stop();
      _localController!.value = 0;
      return;
    }

    if (!_localController!.isAnimating) {
      _localController!.repeat();
    }
  }

  @override
  void dispose() {
    if (_ownsController) {
      _localController?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return widget.child;
    }

    final AnimationController? shared = _ShimmerControllerScope.of(context);
    final AnimationController? controller = shared ?? _localController;

    if (controller == null) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, Widget? child) {
        final double shimmerPosition = controller.value * 2 - 1;
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              begin: Alignment(shimmerPosition - 1, 0),
              end: Alignment(shimmerPosition, 0),
              colors: <Color>[
                Colors.transparent,
                Colors.white.withValues(alpha: 0.4),
                Colors.transparent,
              ],
              stops: const <double>[0, 0.5, 1],
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
