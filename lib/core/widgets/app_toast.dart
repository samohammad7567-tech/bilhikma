import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../di/service_locator.dart';
import '../themes/app_theme.dart';
import 'app_bottom_nav_bar.dart';

enum AppToastKind { info, success, error }

class AppToast {
  AppToast._();

  static const Duration defaultDuration = Duration(seconds: 3);

  static OverlayEntry? _current;

  static void show(
    BuildContext context,
    String message, {
    AppToastKind kind = AppToastKind.info,
    Duration duration = defaultDuration,
  }) {
    final OverlayState? overlay =
        getIt<GlobalKey<NavigatorState>>().currentState?.overlay ??
        Navigator.maybeOf(context, rootNavigator: true)?.overlay;
    if (overlay == null) return;

    _current?.remove();
    _current = null;

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (BuildContext overlayContext) => _ToastView(
        message: message,
        kind: kind,
        duration: duration,
        onDismissed: () {
          if (!identical(_current, entry)) return;
          entry.remove();
          _current = null;
        },
      ),
    );

    _current = entry;
    overlay.insert(entry);
  }

  static void success(
    BuildContext context,
    String message, {
    Duration duration = defaultDuration,
  }) => show(context, message, kind: AppToastKind.success, duration: duration);

  static void error(
    BuildContext context,
    String message, {
    Duration duration = defaultDuration,
  }) => show(context, message, kind: AppToastKind.error, duration: duration);

  static void hide() {
    _current?.remove();
    _current = null;
  }
}

class _ToastView extends StatefulWidget {
  const _ToastView({
    required this.message,
    required this.kind,
    required this.duration,
    required this.onDismissed,
  });

  final String message;
  final AppToastKind kind;
  final Duration duration;
  final VoidCallback onDismissed;

  @override
  State<_ToastView> createState() => _ToastViewState();
}

class _ToastViewState extends State<_ToastView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );

  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOut,
    reverseCurve: Curves.easeIn,
  );

  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, 0.6),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller.forward();
    _timer = Timer(widget.duration, _dismiss);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    _timer?.cancel();
    if (!mounted) return;
    await _controller.reverse();
    if (!mounted) return;
    widget.onDismissed();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Positioned(
      left: 16.w,
      right: 16.w,

      bottom: AppBottomNavBar.barHeight + 12.h,
      child: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: _dismiss,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: colors.secondary,
                  borderRadius: BorderRadius.circular(14.r),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Icon(_icon, size: 20.w, color: _accent(colors)),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        widget.message,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.styles(
                          context,
                        ).labelMedium.copyWith(color: colors.onSecondary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData get _icon => switch (widget.kind) {
    AppToastKind.info => Icons.info_outline,
    AppToastKind.success => Icons.check_circle_outline,
    AppToastKind.error => Icons.error_outline,
  };

  Color _accent(ColorScheme colors) => switch (widget.kind) {
    AppToastKind.info => colors.tertiary,
    AppToastKind.success => const Color(0xff9DBF9D),
    AppToastKind.error => const Color(0xffF08C7D),
  };
}
