import 'dart:async';

/// Broadcasts incoming push events so cubits can refresh their own data
/// without depending on Firebase or on the widget tree.
class PushEventBus {
  PushEventBus._();

  static final PushEventBus instance = PushEventBus._();

  final StreamController<Map<String, dynamic>> _controller =
      StreamController<Map<String, dynamic>>.broadcast();

  /// Emits once for every push the app receives while running, and once for
  /// every push the user taps to open the app.
  Stream<Map<String, dynamic>> get stream => _controller.stream;

  void emit(Map<String, dynamic> data) {
    if (_controller.isClosed) return;

    _controller.add(data);
  }
}
