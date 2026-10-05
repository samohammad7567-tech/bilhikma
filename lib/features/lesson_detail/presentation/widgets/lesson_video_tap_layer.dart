import 'package:flutter/material.dart';

import 'lesson_video_rewind_hint.dart';

/// Full-surface gesture layer: a single tap toggles the controls, a double tap
/// on the leading half rewinds, and one on the trailing half is refused.
///
/// Stays hit-testable while the controls are faded out, so a tap always brings
/// them back.
class LessonVideoTapLayer extends StatefulWidget {
  const LessonVideoTapLayer({
    required this.onTap,
    required this.onRewind,
    required this.onRefuseSkip,
    super.key,
  });

  final VoidCallback onTap;
  final VoidCallback onRewind;
  final VoidCallback onRefuseSkip;

  @override
  State<LessonVideoTapLayer> createState() => _LessonVideoTapLayerState();
}

class _LessonVideoTapLayerState extends State<LessonVideoTapLayer> {
  bool _showRewindHint = false;

  void _rewind() {
    widget.onRewind();

    setState(() => _showRewindHint = true);
    Future<void>.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _showRewindHint = false);
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
            onDoubleTap: widget.onRefuseSkip,
          ),
        ),
      ],
    );
  }
}
