import 'package:flutter/material.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class SearchSubmitButton extends StatelessWidget {
  const SearchSubmitButton({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.surfaceContainerHighest,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(
          width: (48).w(context),
          height: (48).h(context),
          child: Icon(Icons.search, size: (22).r(context), color: colors.secondary),
        ),
      ),
    );
  }
}
