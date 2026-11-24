import 'package:flutter/material.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class LessonDetailInset extends StatelessWidget {
  const LessonDetailInset({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(horizontal: (16).w(context)),
    child: child,
  );
}
