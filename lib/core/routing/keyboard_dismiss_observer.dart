import 'package:flutter/material.dart';

class KeyboardDismissObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _dropFocus();

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _dropFocus();

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _dropFocus();

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) =>
      _dropFocus();

  void _dropFocus() {
    final FocusNode? focus = FocusManager.instance.primaryFocus;

    if (focus == null || !focus.hasFocus) return;
    focus.unfocus();
  }
}
