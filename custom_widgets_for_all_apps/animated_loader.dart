/// Modern loading indicators: five indeterminate styles, one determinate ring,
/// and a blocking overlay.
///
/// Drop-in and self-contained: pure Flutter, no packages and no
/// project-relative imports, so this file can be copied into any app as-is.
/// Colours fall back to the ambient [ColorScheme], so it looks native in any
/// theme without being coupled to one. Pairs with the other
/// `animated_*.dart` widgets in this folder.
///
/// ```dart
/// const AnimatedLoader()
/// ```
///
/// With a localized caption, for an initial page load:
///
/// ```dart
/// AnimatedLoader(
///   style: AnimatedLoaderStyle.dots,
///   label: context.translate(LangKeys.loading),
/// )
/// ```
///
/// Determinate — an upload or download that reports real bytes:
///
/// ```dart
/// AnimatedLoader(progress: state.uploadProgress) // 0.0 .. 1.0
/// ```
///
/// Blocking a form while it submits:
///
/// ```dart
/// AnimatedLoaderOverlay(
///   loading: state.isSubmitting,
///   message: context.translate(LangKeys.pleaseWait),
///   child: MyForm(),
/// )
/// ```
///
/// ## Which style to use
///
/// | Situation | Style |
/// |---|---|
/// | Page or section load | [AnimatedLoaderStyle.ring], [AnimatedLoaderStyle.dots] |
/// | Inside a button or a row | [AnimatedLoaderStyle.ring] at `size: 18` |
/// | Media / audio / streaming | [AnimatedLoaderStyle.bars] |
/// | Live or waiting-for-data | [AnimatedLoaderStyle.pulse] |
/// | Splash and branded screens | [AnimatedLoaderStyle.orbit] |
/// | Upload, download, sync | pass [AnimatedLoader.progress] |
///
/// ## Notes
///
/// * **Progress is never faked.** Pass [AnimatedLoader.progress] only when the
///   API actually reports it; leave it `null` and the loader stays
///   indeterminate. A non-null value renders a determinate ring whatever
///   [AnimatedLoader.style] says, because a fraction only reads as an arc.
/// * **Every loop is seamless.** Motion is driven by whole turns and by sine
///   waves over a single repeating controller, so nothing stutters at the point
///   where the cycle restarts — the usual giveaway of a cheap-looking spinner.
/// * **[AnimatedLoader.size] is the height.** The width follows the style, so
///   `dots` and `bars` get the room they need instead of being squeezed into a
///   square.
/// * The ticker is stopped whenever the loader is static — a determinate arc,
///   or reduced motion — so an idle indicator costs no frames.
/// * Honours the platform "reduce motion" setting: the loader renders in a
///   static resting pose and nothing animates.
/// * Prefer a skeleton (`animated_skeleton.dart`) for lists and detail pages,
///   and an inline loader inside the button for a single action. A spinner in
///   the middle of an empty screen is the last resort, not the default.
library;

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// The shape of the indeterminate animation.
enum AnimatedLoaderStyle {
  /// A gradient arc sweeping around a faint track. The safest default.
  ring,

  /// Three dots rising and fading in sequence.
  dots,

  /// Four bars rising and falling, like an equaliser.
  bars,

  /// A core dot with halos radiating outwards.
  pulse,

  /// Two dots orbiting a faint track at different speeds.
  orbit,
}

/// An animated loading indicator. See the library docs above for usage.
class AnimatedLoader extends StatefulWidget {
  const AnimatedLoader({
    super.key,
    this.style = AnimatedLoaderStyle.ring,
    this.size = 40,
    this.color,
    this.trackColor,
    this.strokeWidth,
    this.duration = const Duration(milliseconds: 1200),
    this.progress,
    this.label,
    this.labelStyle,
    this.labelSpacing = 12,
    this.semanticsLabel,
    this.respectReducedMotion = true,
  });

  /// Which indeterminate animation to draw. Ignored when [progress] is set.
  final AnimatedLoaderStyle style;

  /// Height of the indicator, in logical pixels. The width is derived from
  /// [style] — see the library docs.
  final double size;

  /// Foreground colour. Defaults to [ColorScheme.primary].
  final Color? color;

  /// The unfilled track behind [AnimatedLoaderStyle.ring] and
  /// [AnimatedLoaderStyle.orbit]. Defaults to [color] at 16% opacity.
  final Color? trackColor;

  /// Thickness of the ring, and the scale reference for the orbiting dots.
  /// Defaults to a ninth of [size].
  final double? strokeWidth;

  /// Length of one full animation cycle.
  final Duration duration;

  /// Real completion between `0.0` and `1.0`, or `null` for indeterminate.
  ///
  /// Only pass a value the backend actually reported. See the library docs.
  final double? progress;

  /// Optional caption under the indicator. Pass an already-translated string.
  final String? label;

  /// Style for [label]. Defaults to [TextTheme.bodySmall] in
  /// [ColorScheme.onSurfaceVariant].
  final TextStyle? labelStyle;

  /// Gap between the indicator and [label].
  final double labelSpacing;

  /// Screen-reader description. Pass an already-translated string; when
  /// [progress] is set the percentage is announced automatically.
  final String? semanticsLabel;

  /// When true (the default), the platform "reduce motion" setting freezes the
  /// animation instead of looping it.
  final bool respectReducedMotion;

  @override
  State<AnimatedLoader> createState() => _AnimatedLoaderState();
}

class _AnimatedLoaderState extends State<AnimatedLoader>
    with SingleTickerProviderStateMixin {
  // Smoothing applied between two reported progress values, so a determinate
  // arc glides to the new figure instead of snapping to it.
  static const Duration _progressSettle = Duration(milliseconds: 240);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _positive(widget.duration),
  );

  bool _reducedMotion = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reducedMotion =
        widget.respectReducedMotion && MediaQuery.disableAnimationsOf(context);
    _sync();
  }

  @override
  void didUpdateWidget(AnimatedLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.duration = _positive(widget.duration);
    _sync();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Runs the loop only while it would actually be visible: a determinate arc
  /// and a frozen loader both sit still, and a stopped ticker costs nothing.
  void _sync() {
    if (_reducedMotion || widget.progress != null) {
      if (_controller.isAnimating) _controller.stop();
      _controller.value = 0;
      return;
    }

    if (!_controller.isAnimating) _controller.repeat();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final Color color = widget.color ?? scheme.primary;
    final Color track = widget.trackColor ?? color.withValues(alpha: 0.16);

    final double height = math.max(widget.size, 1);
    // Never thicker than the radius it has to fit inside, and never so thin it
    // disappears — in that order, so an absurdly small size degrades quietly
    // instead of asserting.
    final double stroke = math.min(
      math.max(widget.strokeWidth ?? height / 9, 0.5),
      height / 2,
    );
    final double? progress = widget.progress?.clamp(0.0, 1.0);

    // A determinate value is always a ring, so it keeps the square footprint.
    final double aspect = progress == null ? _aspectFor(widget.style) : 1;

    Widget result = SizedBox(
      width: height * aspect,
      height: height,
      child: progress == null
          ? AnimatedBuilder(
              animation: _controller,
              builder: (BuildContext context, Widget? child) => CustomPaint(
                painter: _painterFor(_controller.value, color, track, stroke),
              ),
            )
          : TweenAnimationBuilder<double>(
              tween: Tween<double>(end: progress),
              duration: _reducedMotion ? Duration.zero : _progressSettle,
              curve: Curves.easeOut,
              builder: (BuildContext context, double value, Widget? child) =>
                  CustomPaint(
                    painter: _RingPainter(
                      t: 0,
                      color: color,
                      stroke: stroke,
                      track: track,
                      progress: value,
                    ),
                  ),
            ),
    );

    final String? label = widget.label;

    if (label != null) {
      result = Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          result,
          SizedBox(height: widget.labelSpacing),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style:
                widget.labelStyle ??
                theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
        ],
      );
    }

    return Semantics(
      container: true,
      label: widget.semanticsLabel,
      value: progress == null ? null : '${(progress * 100).round()}%',
      child: result,
    );
  }

  CustomPainter _painterFor(double t, Color color, Color track, double stroke) {
    return switch (widget.style) {
      AnimatedLoaderStyle.ring => _RingPainter(
        t: t,
        color: color,
        stroke: stroke,
        track: track,
      ),
      AnimatedLoaderStyle.dots => _DotsPainter(
        t: t,
        color: color,
        stroke: stroke,
      ),
      AnimatedLoaderStyle.bars => _BarsPainter(
        t: t,
        color: color,
        stroke: stroke,
      ),
      AnimatedLoaderStyle.pulse => _PulsePainter(
        t: t,
        color: color,
        stroke: stroke,
      ),
      AnimatedLoaderStyle.orbit => _OrbitPainter(
        t: t,
        color: color,
        stroke: stroke,
        track: track,
      ),
    };
  }
}

/// Width as a multiple of the height, per style.
double _aspectFor(AnimatedLoaderStyle style) => switch (style) {
  AnimatedLoaderStyle.ring ||
  AnimatedLoaderStyle.pulse ||
  AnimatedLoaderStyle.orbit => 1,
  AnimatedLoaderStyle.dots => 1.75,
  AnimatedLoaderStyle.bars => 1,
};

Duration _positive(Duration duration) =>
    duration > Duration.zero ? duration : const Duration(milliseconds: 1);

/// `0..1` eased by a sine wave, phase-shifted by [shift] turns.
///
/// A whole number of cycles over the controller's `0..1` range means the value
/// returns to exactly where it started, which is what keeps the loops seamless.
double _wave(double t, [double shift = 0]) =>
    (math.sin((t + shift) * 2 * math.pi) + 1) / 2;

abstract class _LoaderPainter extends CustomPainter {
  const _LoaderPainter({
    required this.t,
    required this.color,
    required this.stroke,
  });

  /// Cycle position, `0..1`.
  final double t;
  final Color color;
  final double stroke;

  @override
  bool shouldRepaint(covariant _LoaderPainter oldDelegate) =>
      oldDelegate.t != t ||
      oldDelegate.color != color ||
      oldDelegate.stroke != stroke;
}

class _RingPainter extends _LoaderPainter {
  const _RingPainter({
    required super.t,
    required super.color,
    required super.stroke,
    required this.track,
    this.progress,
  });

  final Color track;

  /// `null` for the sweeping indeterminate arc.
  final double? progress;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double radius = (size.shortestSide - stroke) / 2;
    if (radius <= 0) return;

    final Rect arc = Rect.fromCircle(center: center, radius: radius);

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = track,
    );

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    final double? value = progress;

    if (value != null) {
      if (value <= 0) return;

      // Twelve o'clock is the only start angle that reads as "progress".
      canvas.drawArc(
        arc,
        -math.pi / 2,
        value * 2 * math.pi,
        false,
        paint..color = color,
      );
      return;
    }

    // The arc both rotates (one whole turn per cycle) and breathes in length,
    // which is what separates a premium spinner from a rigid rotating dash.
    final double start = -math.pi / 2 + (t * 2 * math.pi);
    final double sweep = (0.55 + (_wave(t) * 0.35)) * 2 * math.pi;

    canvas.drawArc(
      arc,
      start,
      sweep,
      false,
      paint
        // Fading the tail out gives the arc a direction, so the eye reads it as
        // travelling rather than merely spinning.
        ..shader = SweepGradient(
          endAngle: sweep,
          colors: <Color>[color.withValues(alpha: 0), color],
          transform: GradientRotation(start),
        ).createShader(arc),
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      super.shouldRepaint(oldDelegate) ||
      oldDelegate.track != track ||
      oldDelegate.progress != progress;
}

class _DotsPainter extends _LoaderPainter {
  const _DotsPainter({
    required super.t,
    required super.color,
    required super.stroke,
  });

  static const int _count = 3;

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.height * 0.17;
    if (radius <= 0) return;

    final double gap = radius * 1.6;
    final double span = (_count * 2 * radius) + ((_count - 1) * gap);
    final double startX = ((size.width - span) / 2) + radius;
    final double centerY = size.height / 2;
    final Paint paint = Paint();

    for (int i = 0; i < _count; i++) {
      // Each dot trails the one before it by a fifth of a turn.
      final double v = _wave(t, -i * 0.2);

      canvas.drawCircle(
        Offset(
          startX + (i * ((2 * radius) + gap)),
          centerY - (v * radius * 0.85),
        ),
        radius * (0.68 + (v * 0.32)),
        paint..color = color.withValues(alpha: 0.4 + (v * 0.6)),
      );
    }
  }
}

class _BarsPainter extends _LoaderPainter {
  const _BarsPainter({
    required super.t,
    required super.color,
    required super.stroke,
  });

  static const int _count = 4;

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.height * 0.14;
    if (width <= 0) return;

    final double gap = width * 0.9;
    final double span = (_count * width) + ((_count - 1) * gap);
    final double startX = (size.width - span) / 2;
    final double centerY = size.height / 2;
    final Radius radius = Radius.circular(width / 2);
    final Paint paint = Paint()..color = color;

    for (int i = 0; i < _count; i++) {
      final double v = _wave(t, -i * 0.12);
      final double height = size.height * (0.3 + (v * 0.7));

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            startX + (i * (width + gap)),
            centerY - (height / 2),
            width,
            height,
          ),
          radius,
        ),
        paint,
      );
    }
  }
}

class _PulsePainter extends _LoaderPainter {
  const _PulsePainter({
    required super.t,
    required super.color,
    required super.stroke,
  });

  static const int _halos = 2;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double maxRadius = size.shortestSide / 2;
    if (maxRadius <= 0) return;

    final Paint paint = Paint();

    for (int i = 0; i < _halos; i++) {
      final double p = (t + (i / _halos)) % 1;

      canvas.drawCircle(
        center,
        maxRadius * (0.3 + (p * 0.7)),
        // sin(p * pi) is zero at both ends of the travel, so a halo fades in
        // and out completely and never pops at the wrap-around.
        paint..color = color.withValues(alpha: math.sin(p * math.pi) * 0.32),
      );
    }

    canvas.drawCircle(
      center,
      maxRadius * (0.2 + (_wave(t) * 0.08)),
      paint..color = color,
    );
  }
}

class _OrbitPainter extends _LoaderPainter {
  const _OrbitPainter({
    required super.t,
    required super.color,
    required super.stroke,
    required this.track,
  });

  final Color track;

  // Speed in whole turns per cycle, orbit radius, dot scale, dot opacity.
  // Whole-number speeds keep both dots in phase at the loop boundary.
  static const List<(double, double, double, double)> _dots =
      <(double, double, double, double)>[(1, 1, 1, 1), (2, 0.58, 0.62, 0.55)];

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double radius = (size.shortestSide - stroke) / 2;
    if (radius <= 0) return;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke * 0.4
        ..color = track,
    );

    final Paint paint = Paint();

    for (final (double speed, double orbit, double scale, double alpha)
        in _dots) {
      final double angle = -math.pi / 2 + (t * speed * 2 * math.pi);

      canvas.drawCircle(
        center + Offset(math.cos(angle), math.sin(angle)) * (radius * orbit),
        stroke * scale,
        paint..color = color.withValues(alpha: alpha),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _OrbitPainter oldDelegate) =>
      super.shouldRepaint(oldDelegate) || oldDelegate.track != track;
}

/// Dims a subtree and blocks it while a blocking operation is in flight.
///
/// Reach for this only when the whole screen genuinely cannot be used yet — a
/// form being submitted, a payment being confirmed, a first load that has
/// nothing to show. For anything smaller, keep the screen usable: an inline
/// loader in the button, or a skeleton in the section that is loading.
///
/// ```dart
/// AnimatedLoaderOverlay(
///   loading: state.isSubmitting,
///   message: context.translate(LangKeys.pleaseWait),
///   child: MyForm(),
/// )
/// ```
class AnimatedLoaderOverlay extends StatelessWidget {
  const AnimatedLoaderOverlay({
    required this.loading,
    required this.child,
    super.key,
    this.style = AnimatedLoaderStyle.ring,
    this.message,
    this.progress,
    this.color,
    this.barrierColor,
    this.blur = 0,
    this.showPanel = true,
    this.duration = const Duration(milliseconds: 200),
  });

  /// Whether the barrier is shown. Drive it from your Cubit state.
  final bool loading;

  /// The screen being covered.
  final Widget child;

  /// Indicator style, forwarded to [AnimatedLoader.style].
  final AnimatedLoaderStyle style;

  /// Optional caption. Pass an already-translated string.
  final String? message;

  /// Real completion, forwarded to [AnimatedLoader.progress].
  final double? progress;

  /// Indicator colour. Defaults to [ColorScheme.primary].
  final Color? color;

  /// Scrim colour. Defaults to [ColorScheme.scrim] at 45%.
  final Color? barrierColor;

  /// Gaussian blur applied to the content behind the scrim. `0` disables it —
  /// a blur costs a full-subtree pass every frame, so turn it on deliberately.
  final double blur;

  /// Whether the indicator sits on a raised surface. Set `false` for a bare
  /// indicator on the scrim.
  final bool showPanel;

  /// Fade duration of the barrier.
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        // While the barrier is up the content behind it is unreachable, so it
        // should be unreachable for a screen reader too.
        ExcludeSemantics(excluding: loading, child: child),
        Positioned.fill(
          child: AnimatedSwitcher(
            duration: duration,
            // Swapped out entirely rather than faded to zero opacity, so an
            // idle screen pays nothing for the scrim or the blur.
            child: loading
                ? _Barrier(
                    key: const ValueKey<String>('loading'),
                    style: style,
                    message: message,
                    progress: progress,
                    color: color,
                    barrierColor: barrierColor,
                    blur: blur,
                    showPanel: showPanel,
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}

class _Barrier extends StatelessWidget {
  const _Barrier({
    required this.style,
    required this.message,
    required this.progress,
    required this.color,
    required this.barrierColor,
    required this.blur,
    required this.showPanel,
    super.key,
  });

  final AnimatedLoaderStyle style;
  final String? message;
  final double? progress;
  final Color? color;
  final Color? barrierColor;
  final double blur;
  final bool showPanel;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    Widget content = AnimatedLoader(
      style: style,
      color: color,
      progress: progress,
      label: message,
      semanticsLabel: message,
    );

    if (showPanel) {
      content = DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: scheme.shadow.withValues(alpha: 0.16),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: content,
        ),
      );
    }

    Widget barrier = ColoredBox(
      color: barrierColor ?? scheme.scrim.withValues(alpha: 0.45),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 260),
          child: content,
        ),
      ),
    );

    if (blur > 0) {
      barrier = BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: barrier,
      );
    }

    return AbsorbPointer(child: barrier);
  }
}
