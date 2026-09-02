import 'package:flutter/material.dart';

import '../video_player_options.dart';

class VideoSpeedSheet extends StatelessWidget {
  const VideoSpeedSheet({
    required this.options,
    required this.currentSpeed,
    required this.onSpeedSelected,
    super.key,
  });

  final FloatingVideoOptions options;
  final double currentSpeed;
  final ValueChanged<double> onSpeedSelected;

  static void show({
    required BuildContext context,
    required FloatingVideoOptions options,
    required double currentSpeed,
    required ValueChanged<double> onSpeedSelected,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: options.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext sheetContext) => VideoSpeedSheet(
        options: options,
        currentSpeed: currentSpeed,
        onSpeedSelected: (double speed) {
          onSpeedSelected(speed);
          Navigator.of(sheetContext).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(height: 12),

            Text(
              options.speedSheetTitle,
              style: TextStyle(
                color: options.foregroundColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            for (final MapEntry<String, double> option in options.speedOptions)
              ListTile(
                title: Text(
                  option.key,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: option.value == currentSpeed
                        ? options.accentColor
                        : options.foregroundColor,
                    fontWeight: option.value == currentSpeed
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                onTap: () => onSpeedSelected(option.value),
              ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
