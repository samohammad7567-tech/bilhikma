import 'package:flutter/material.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class LessonVideoPlaceholder extends StatelessWidget {
  const LessonVideoPlaceholder({
    required this.isPreparing,
    required this.onTap,
    super.key,
  });

  final bool isPreparing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (isPreparing) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return Center(
      child: Material(
        color: Theme.of(
          context,
        ).colorScheme.primaryContainer.withValues(alpha: 0.85),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: (56).w(context),
            height: (56).h(context),
            child: Icon(Icons.play_arrow, size: (30).r(context), color: Colors.white),
          ),
        ),
      ),
    );
  }
}
