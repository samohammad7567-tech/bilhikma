import 'package:flutter/material.dart';

import 'lesson_video_rewind_hint.dart';

/// Full-surface gesture layer: a single tap toggles the controls, a double tap
/// on the leading half rewinds, and one on the trailing half skips forward —
/// only as far as the seek cap allows, which [onForward] reports by returning
/// whether the skip was taken.
///
/// Stays hit-testable while the controls are faded out, so a tap always brings
/// them back.
class LessonVideoTapLayer extends StatefulWidget {
  const LessonVideoTapLayer({
    required this.onTap,
    required this.onRewind,
    required this.onForward,
    super.key,
  });

  final VoidCallback onTap;
  final VoidCallback onRewind;

  /// Returns `true` when the forward skip actually happened, `false` when it
  /// was refused — only the former flashes the hint.
  final bool Function() onForward;

  @override
  State<LessonVideoTapLayer> createState() => _LessonVideoTapLayerState();
}

class _LessonVideoTapLayerState extends State<LessonVideoTapLayer> {
  bool _showRewindHint = false;
  bool _showForwardHint = false;

  void _rewind() {
    widget.onRewind();
    _flash(() => _showRewindHint = true, () => _showRewindHint = false);
  }

  void _forward() {
    if (!widget.onForward()) return;

    _flash(() => _showForwardHint = true, () => _showForwardHint = false);
  }

  void _flash(VoidCallback show, VoidCallback hide) {
    setState(show);
    Future<void>.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(hide);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onTap,
            onDoubleTap: _rewind,
            child: LessonVideoRewindHint(visible: _showRewindHint),
          ),
        ),

        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onTap,
            onDoubleTap: _forward,
            child: LessonVideoRewindHint(
              visible: _showForwardHint,
              isForward: true,
            ),
          ),
        ),
      ],
    );
  }
}
