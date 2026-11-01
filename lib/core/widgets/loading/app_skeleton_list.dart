import 'package:flutter/material.dart';

class AppSkeletonList extends StatefulWidget {
  const AppSkeletonList({
    required this.itemCount,
    required this.itemBuilder,
    super.key,
    this.padding,
    this.separatorBuilder,
  });

  final int itemCount;
  final dynamic itemBuilder;
  final EdgeInsetsGeometry? padding;
  final IndexedWidgetBuilder? separatorBuilder;

  @override
  State<AppSkeletonList> createState() => _AppSkeletonListState();
}

class _ControllerScope extends InheritedWidget {
  const _ControllerScope({
    required this.controller,
    required super.child,
  });

  final AnimationController controller;

  static AnimationController of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_ControllerScope>()!.controller;
  }

  @override
  bool updateShouldNotify(_ControllerScope oldWidget) =>
      oldWidget.controller != controller;
}

class _AppSkeletonListState extends State<AppSkeletonList>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
      _controller.value = 0;
      return;
    }
    if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildItem(BuildContext context, int index) {
    final dynamic b = widget.itemBuilder;
    Widget child;
    if (b is Widget Function(BuildContext)) {
      child = (b as Widget Function(BuildContext))(context);
    } else {
      child = (b as Widget Function(BuildContext, int))(context, index);
    }
    return _Mask(child: child);
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      Widget listChild = widget.separatorBuilder == null
          ? ListView.builder(
              padding: widget.padding,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: widget.itemCount,
              itemBuilder: _buildItem,
            )
          : ListView.separated(
              padding: widget.padding,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: widget.itemCount,
              separatorBuilder: widget.separatorBuilder!,
              itemBuilder: _buildItem,
            );
      return listChild;
    }

    Widget listChild = widget.separatorBuilder == null
        ? ListView.builder(
            padding: widget.padding,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: widget.itemCount,
            itemBuilder: _buildItem,
          )
        : ListView.separated(
            padding: widget.padding,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: widget.itemCount,
            separatorBuilder: widget.separatorBuilder!,
            itemBuilder: _buildItem,
          );

    return _ControllerScope(
      controller: _controller,
      child: listChild,
    );
  }
}

class _Mask extends StatelessWidget {
  const _Mask({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return child;
    }
    final AnimationController controller = _ControllerScope.of(context);
    return AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, Widget? c) {
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
          child: c,
        );
      },
      child: child,
    );
  }
}
