import 'package:flutter/material.dart';

import 'my_screen_size.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class CustomBottomSheet {
  const CustomBottomSheet._();
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
        maxHeight: MyScreenSize.heightFraction(context, _maxHeightFactor),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular((25).r(context))),
      ),
      builder: (context) {
        final Color sheetColor =
            backgroundColor ?? Theme.of(context).colorScheme.tertiary;

        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MyScreenSize.keyboardHeight(context),
            ),
            child: Container(
              padding: EdgeInsets.all((16).r(context)),
              decoration: BoxDecoration(
                color: sheetColor,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular((25).r(context)),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.20),
                    blurRadius: (20).r(context),
                    spreadRadius: (0).r(context),
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
