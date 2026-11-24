import 'package:flutter/material.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class CountBadgeBubble extends StatelessWidget {
  const CountBadgeBubble({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Container(
      constraints: BoxConstraints(minWidth: 18, minHeight: 18),
      padding: EdgeInsets.symmetric(horizontal: (5).w(context)),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.error,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular((20).r(context)),
        border: Border.all(color: colors.surfaceContainerLowest, width: 1.5.w(context)),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.clip,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: colors.onError,
          fontSize: (10).sp(context),
          height: 1.1.h(context),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
