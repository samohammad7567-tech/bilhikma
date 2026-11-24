import 'package:flutter/material.dart';

import '../../data/models/test_option_model.dart';
import 'test_word_chip.dart';

class TestWordBank extends StatelessWidget {
  const TestWordBank({
    required this.options,
    required this.isUsed,
    required this.onSelect,
    super.key,
  });

  final List<TestOptionModel> options;

  final bool Function(String optionId) isUsed;

  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 10,
      children: options
          .map(
            (TestOptionModel option) => TestWordChip(
              label: option.label,
              isUsed: isUsed(option.id),
              onTap: () => onSelect(option.id),
            ),
          )
          .toList(growable: false),
    );
  }
}
