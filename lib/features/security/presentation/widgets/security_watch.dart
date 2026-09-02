import 'package:flutter/material.dart';

import '../../../../core/di/service_locator.dart';
import '../cubit/security_cubit.dart';

class SecurityWatch extends StatefulWidget {
  const SecurityWatch({
    required this.screen,
    required this.child,
    super.key,
    this.contentId,
  });

  final String screen;
  final int? contentId;
  final Widget child;

  @override
  State<SecurityWatch> createState() => _SecurityWatchState();
}

class _SecurityWatchState extends State<SecurityWatch> {
  int? _token;

  @override
  void initState() {
    super.initState();
    _watch();
  }

  @override
  void didUpdateWidget(SecurityWatch oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.screen == widget.screen &&
        oldWidget.contentId == widget.contentId) {
      return;
    }

    _unwatch();
    _watch();
  }

  @override
  void dispose() {
    _unwatch();
    super.dispose();
  }

  void _watch() => _token = getIt<SecurityCubit>().watchScreen(
    widget.screen,
    contentId: widget.contentId,
  );

  void _unwatch() {
    final int? token = _token;
    if (token == null) return;

    getIt<SecurityCubit>().unwatchScreen(token);
    _token = null;
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
