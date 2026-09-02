import 'package:flutter/material.dart';
import '../refactor/settings_formats.dart';
import '../../../../core/themes/app_theme.dart';
import 'font_size_step_button.dart';

class FontSizeStepper extends StatelessWidget {
  const FontSizeStepper({
    required this.percent,
    required this.onDecrease,
    required this.onIncrease,
    super.key,
  });

  final int percent;
  final VoidCallback? onDecrease;
  final VoidCallback? onIncrease;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        FontSizeStepButton(icon: Icons.remove, onPressed: onDecrease),

        Text(
          SettingsFormats.fontScale(percent),
          maxLines: 1,
          style: AppTheme.styles(context).sectionTitle.copyWith(
            color: Theme.of(context).colorScheme.secondaryContainer,
          ),
        ),

        FontSizeStepButton(icon: Icons.add, onPressed: onIncrease),
      ],
    );
  }
}
