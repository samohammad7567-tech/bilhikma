import 'package:flutter/material.dart';
import '../../../../core/themes/app_theme.dart';

class TestQuestionPrompt extends StatelessWidget {
  const TestQuestionPrompt({required this.prompt, super.key});

  final String prompt;

  @override
  Widget build(BuildContext context) => Text(
    prompt,
    textAlign: TextAlign.center,
    style: AppTheme.styles(context).labelStrong,
  );
}
