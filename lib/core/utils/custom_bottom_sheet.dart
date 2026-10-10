import 'package:flutter/material.dart';

class CustomBottomSheet {
  const CustomBottomSheet._();

  /// Share of the screen a sheet may take, leaving the rest as barrier.
  ///
  /// Left unbounded, a tall sheet — a long option list, a form pushed up by
  /// the keyboard, anything at all in landscape — covers the whole screen.
  /// There is then nothing outside it to tap, and the scroll view below
  /// swallows every downward drag because a gesture that starts on a
  /// scrollable belongs to that scrollable, so the sheet can only be closed
  /// from its own buttons or the system back gesture.
  static const double _maxHeightFactor = 0.85;

  static void showModalBottomSheetContainer({
    required BuildContext context,
    required Widget widget,
    Color? backgroundColor,
    VoidCallback? whenComplete,
  }) {
    showModalBottomSheet<dynamic>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * _maxHeightFactor,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        final Color sheetColor =
            backgroundColor ?? Theme.of(context).colorScheme.tertiary;

        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: sheetColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(25),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.20),
                    blurRadius: 20,
                    spreadRadius: 0,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: widget,
            ),
          ),
        );
      },
    ).whenComplete(whenComplete ?? () {});
  }
}
