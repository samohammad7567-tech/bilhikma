import 'package:flutter/material.dart';

class LiveSessionCardDot extends StatelessWidget {
  const LiveSessionCardDot({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onPrimaryContainer,
        shape: BoxShape.circle,
      ),
    );
  }
}
