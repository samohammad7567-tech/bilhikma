import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppSkeletonBox extends StatefulWidget {
  const AppSkeletonBox({
    required this.height,
    super.key,
    this.width,
    this.radius,
    this.isCircular = false,
  });

  final double height;

  final double? width;

  final double? radius;

  final bool isCircular;

  @override
  State<AppSkeletonBox> createState() => _AppSkeletonBoxState();
}

class _AppSkeletonBoxState extends State<AppSkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
      return;
    }

    if (!_controller.isAnimating) _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color base = Theme.of(context).colorScheme.onSurface;

    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) => Opacity(
        opacity: 0.06 + (_controller.value * 0.06),
        child: child,
      ),
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: base,
          shape: widget.isCircular ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: widget.isCircular
              ? null
              : BorderRadius.circular(widget.radius ?? 8.r),
        ),
      ),
    );
  }
}
