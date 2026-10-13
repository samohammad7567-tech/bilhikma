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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              options.speedSheetTitle,
              style: TextStyle(
                color: options.foregroundColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  for (final MapEntry<String, double> option
                      in options.speedOptions)
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
