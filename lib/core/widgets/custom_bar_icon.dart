import 'package:flutter/material.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class CustomBarIcon extends StatelessWidget {
  const CustomBarIcon({
    required this.child,
    super.key,
    this.onTap,
    this.size,
    this.padding,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double? size;
  final double? padding;

  @override
  Widget build(BuildContext context) {
    final double diameter = size ?? 44;

    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      shape: const CircleBorder(),
      elevation: (2).r(context),
      shadowColor: Colors.black.withValues(alpha: 0.15),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: diameter,
          height: diameter,
          child: Padding(
            padding: EdgeInsets.all(padding ?? 12),
            child: child,
          ),
        ),
      ),
    );
  }
}
