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
          // Title kept out of the scroll view below: a drag that starts on a
          // scrollable belongs to that scrollable, so once the rates overflow
          // there is no part of the sheet left to grab and swipe closed.
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

          // Loose, so the rates keep their natural height while they fit and
          // stay unscrollable — a swipe anywhere then closes the sheet, and
          // only a genuinely overflowing list scrolls instead.
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
