import 'package:flutter/material.dart';

/// Dark backdrop that follows a vertical drag and pops the route once the drag
/// passes the dismiss threshold (or is flung). Reusable by any full screen
/// media view; set [enabled] to false while the content is zoomed so the drag
/// does not fight panning.
class DragDismissBackdrop extends StatefulWidget {
  const DragDismissBackdrop({
    required this.child,
    super.key,
    this.enabled = true,
  });

  final Widget child;
  final bool enabled;

  @override
  State<DragDismissBackdrop> createState() => _DragDismissBackdropState();
}

class _DragDismissBackdropState extends State<DragDismissBackdrop> {
  static const double _dismissThreshold = 130;
  static const double _dragLimit = 400;
  static const double _flingVelocity = 800;
  static const double _minBackdrop = 0.4;

  double _drag = 0;
  bool _snapping = false;

  void _onDragUpdate(DragUpdateDetails details) {
    if (!widget.enabled) return;

    setState(() {
      _snapping = false;
      _drag = (_drag + details.delta.dy).clamp(-_dragLimit, _dragLimit);
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (!widget.enabled) return;

    final double velocity = details.primaryVelocity ?? 0;
    final bool flung = _drag != 0 && velocity.abs() > _flingVelocity;

    if (_drag.abs() > _dismissThreshold || flung) {
      Navigator.of(context).maybePop();
      return;
    }

    setState(() {
      _snapping = true;
      _drag = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.sizeOf(context).height;
    final double backdrop = (1 - (_drag.abs() / _dragLimit)).clamp(
      _minBackdrop,
      1.0,
    );

    return ColoredBox(
      color: Colors.black.withValues(alpha: backdrop),
      child: GestureDetector(
        onVerticalDragUpdate: _onDragUpdate,
        onVerticalDragEnd: _onDragEnd,
        child: AnimatedSlide(
          offset: Offset(0, _drag / height),
          duration: Duration(milliseconds: _snapping ? 180 : 0),
          curve: Curves.easeOut,
          child: widget.child,
        ),
      ),
    );
  }
}
