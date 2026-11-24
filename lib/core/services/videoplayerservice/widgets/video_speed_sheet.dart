import 'package:flutter/material.dart';

import '../video_player_options.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular((20).r(context))),
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
            padding: EdgeInsets.fromLTRB((16).w(context), (12).h(context), (16).w(context), (8).h(context)),
            child: Text(
              options.speedSheetTitle,
              style: TextStyle(
                color: options.foregroundColor,
                fontSize: (16).sp(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: (8).h(context)),
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
