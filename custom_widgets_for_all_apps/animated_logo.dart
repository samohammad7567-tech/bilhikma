/// Smooth, continuous motion for a PNG brand mark.
///
/// Drop-in and self-contained: pure Flutter, no packages, no theme lookups and
/// no project-relative imports, so this file can be copied into any app as-is.
///
/// Designed for transparent PNG logos — the optional drop shadow is built from
/// the image's own alpha channel, so it follows the logo's silhouette instead
/// of drawing a box behind it.
///
/// Simplest use:
///
/// ```dart
/// AnimatedLogo(image: AssetImage('assets/logo.png'), width: 160)
/// ```
///
/// Splash / hero treatment:
///
/// ```dart
/// AnimatedLogo(
///   image: const AssetImage('assets/logo.png'),
///   width: 200,
///   shine: true,
///   shadow: const AnimatedLogoShadow(),
/// )
/// ```
///
/// Static brand mark in an app bar (no motion, still gets the shadow):
///
/// ```dart
/// AnimatedLogo(
///   image: const AssetImage('assets/logo.png'),
///   height: 32,
///   motion: AnimatedLogoMotion.none,
///   entrance: false,
/// )
/// ```
///
/// All motion is driven by a sine wave over a single repeating controller, so
/// the loop is seamless — there is no visible stutter at the point where the
/// cycle restarts, which is the usual giveaway of a cheap-looking logo
/// animation. Motion also starts from the exact pose the entrance animation
/// ends on, so the hand-off is invisible.
///
/// Honours the platform "reduce motion" accessibility setting: when it is on,
/// the logo renders immediately in its resting pose and nothing animates.
library;

import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// How the logo moves once it has settled in.
enum AnimatedLogoMotion {
  /// No continuous motion. The entrance animation still runs unless
  /// `entrance: false` is also passed.
  none,

  /// Rises and falls gently. The safest choice for most brand marks.
  float,

  /// Scales up and down slightly, like a slow breath.
  breathe,

  /// Floats and breathes together — the default, and the most "alive" of the
  /// options without becoming distracting.
  floatAndBreathe,

  /// Tilts slowly from side to side. Suits emblems and badges; avoid it for
  /// logos containing text, where any rotation reads as misalignment.
  sway,
}

/// A soft drop shadow shaped by the logo's own alpha channel.
///
/// Bake the opacity into [color] (the default is black at ~20%).
@immutable
class AnimatedLogoShadow {
  const AnimatedLogoShadow({
    this.color = const Color(0x33000000),
    this.blur = 12,
    this.offset = const Offset(0, 6),
  });

  /// Shadow colour, including its alpha.
  final Color color;

  /// Gaussian blur sigma. Larger values read as the logo floating higher.
  final double blur;

  /// Shadow displacement from the logo.
  final Offset offset;

  @override
  bool operator ==(Object other) =>
      other is AnimatedLogoShadow &&
      other.color == color &&
      other.blur == blur &&
      other.offset == offset;

  @override
  int get hashCode => Object.hash(color, blur, offset);
}

/// An animated brand mark. See the library docs above for usage.
class AnimatedLogo extends StatefulWidget {
  const AnimatedLogo({
    required this.image,
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.motion = AnimatedLogoMotion.floatAndBreathe,
    this.loopDuration = const Duration(milliseconds: 2800),
    this.floatOffset = 6,
    this.breatheScale = 0.03,
    this.swayAngle = 0.015,
    this.entrance = true,
    this.entranceDuration = const Duration(milliseconds: 900),
    this.entranceDelay = Duration.zero,
    this.shine = false,
    this.shineDuration = const Duration(milliseconds: 3200),
    this.shineColor = const Color(0x59FFFFFF),
    this.shadow,
    this.respectReducedMotion = true,
    this.filterQuality = FilterQuality.medium,
    this.semanticLabel,
  }) : assert(floatOffset >= 0, 'floatOffset must not be negative'),
       assert(
         breatheScale >= 0 && breatheScale < 1,
         'breatheScale is a fraction of the logo size, e.g. 0.03 for 3%',
       );

  /// The brand mark. For a PNG asset: `AssetImage('assets/logo.png')`.
  final ImageProvider image;

  /// Logo width. Set one of [width] / [height] and let [fit] preserve the
  /// aspect ratio; setting both can distort the mark.
  final double? width;

  /// Logo height.
  final double? height;

  /// How the image fits [width] / [height]. Defaults to [BoxFit.contain],
  /// which never distorts the logo.
  final BoxFit fit;

  /// Which continuous motion to run. Defaults to
  /// [AnimatedLogoMotion.floatAndBreathe].
  final AnimatedLogoMotion motion;

  /// Duration of one full motion cycle. Slower reads as more premium; below
  /// about 1.5s the motion starts to feel restless.
  final Duration loopDuration;

  /// Peak vertical travel in logical pixels, for the floating motions.
  final double floatOffset;

  /// Peak scale change as a fraction of logo size — `0.03` is ±3%.
  final double breatheScale;

  /// Peak rotation in radians for [AnimatedLogoMotion.sway]. Keep it small;
  /// `0.015` rad is about 0.9°.
  final double swayAngle;

  /// Whether to fade and pop the logo in on first build.
  final bool entrance;

  /// Duration of the entrance animation.
  final Duration entranceDuration;

  /// Delay before the entrance animation begins — useful for staggering a
  /// logo against the text beneath it.
  final Duration entranceDelay;

  /// Whether a periodic highlight sweeps diagonally across the logo.
  ///
  /// Effective on metallic, foil and gloss marks; switch it off for flat
  /// single-colour logos, where it tends to look like a rendering artefact.
  final bool shine;

  /// Period of the shine, including the pause between sweeps.
  final Duration shineDuration;

  /// Highlight colour, including its alpha. Lower the alpha to soften it.
  final Color shineColor;

  /// Optional alpha-shaped drop shadow. Null means no shadow.
  final AnimatedLogoShadow? shadow;

  /// Whether to freeze all motion when the platform asks for reduced motion.
  /// Leave this on unless the logo animation is itself essential content.
  final bool respectReducedMotion;

  /// Resampling quality. [FilterQuality.medium] keeps a downscaled PNG crisp
  /// at a reasonable cost.
  final FilterQuality filterQuality;

  /// Accessibility label, e.g. the company name.
  final String? semanticLabel;

  @override
  State<AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<AnimatedLogo>
    with TickerProviderStateMixin {
  static const double _entranceFrom = 0.9;

  // Duration comparisons are not const-evaluable, so these cannot be asserted
  // in the constructor without making it non-const. A zero-length controller
  // throws on repeat(), so the values are sanitised here instead.
  static Duration _positive(Duration value) =>
      value > Duration.zero ? value : const Duration(milliseconds: 1);

  late final AnimationController _entranceController = AnimationController(
    vsync: this,
    duration: _positive(widget.entranceDuration),
  );
  late final AnimationController _loopController = AnimationController(
    vsync: this,
    duration: _positive(widget.loopDuration),
  );
  late final AnimationController _shineController = AnimationController(
    vsync: this,
    duration: _positive(widget.shineDuration),
  );

  late final Animation<double> _fade = CurvedAnimation(
    parent: _entranceController,
    curve: const Interval(0, 0.5, curve: Curves.easeOut),
  );

  // easeOutBack overshoots slightly past 1.0 before settling, which gives the
  // entrance a deliberate "placed" feel rather than a flat fade.
  late final Animation<double> _pop =
      Tween<double>(begin: _entranceFrom, end: 1).animate(
        CurvedAnimation(
          parent: _entranceController,
          curve: const Interval(0, 0.75, curve: Curves.easeOutBack),
        ),
      );

  // The sweep occupies the first stretch of the cycle; the remainder is a
  // deliberate rest, so the highlight glints periodically instead of
  // shuttling back and forth.
  late final Animation<double> _shine = CurvedAnimation(
    parent: _shineController,
    curve: const Interval(0, 0.45, curve: Curves.easeInOut),
  );

  Timer? _delayTimer;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (widget.respectReducedMotion &&
        MediaQuery.disableAnimationsOf(context)) {
      _freeze();
      return;
    }

    if (_started) return;
    _started = true;
    _play();
  }

  @override
  void didUpdateWidget(AnimatedLogo oldWidget) {
    super.didUpdateWidget(oldWidget);

    _loopController.duration = _positive(widget.loopDuration);
    _shineController.duration = _positive(widget.shineDuration);

    if (!_started) return;

    if (widget.motion == AnimatedLogoMotion.none) {
      _loopController
        ..stop()
        ..value = 0;
    }

    if (!widget.shine) {
      _shineController
        ..stop()
        ..value = 0;
    }

    if (_entranceController.isCompleted) _startLoops();
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _entranceController.dispose();
    _loopController.dispose();
    _shineController.dispose();
    super.dispose();
  }

  void _freeze() {
    _delayTimer?.cancel();
    _entranceController.value = 1;
    _loopController
      ..stop()
      ..value = 0;
    _shineController
      ..stop()
      ..value = 0;
  }

  void _play() {
    if (!widget.entrance) {
      _entranceController.value = 1;
      _startLoops();
      return;
    }

    _entranceController.addStatusListener(_onEntranceStatus);

    if (widget.entranceDelay == Duration.zero) {
      _entranceController.forward();
      return;
    }

    _delayTimer = Timer(widget.entranceDelay, () {
      if (mounted) _entranceController.forward();
    });
  }

  void _onEntranceStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) _startLoops();
  }

  void _startLoops() {
    if (!mounted) return;

    if (widget.motion != AnimatedLogoMotion.none &&
        !_loopController.isAnimating) {
      _loopController.repeat();
    }

    if (widget.shine && !_shineController.isAnimating) {
      _shineController.repeat();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      // The mark is passed as `child` so the image is not rebuilt on every
      // tick — only the cheap transforms above it are.
      animation: Listenable.merge(<Listenable>[
        _entranceController,
        _loopController,
      ]),
      builder: (BuildContext context, Widget? child) =>
          _transform(child ?? const SizedBox.shrink()),
      child: _mark(),
    );
  }

  Widget _transform(Widget child) {
    // A full sine cycle over the controller's 0..1 range: starts and ends at
    // 0, so the resting pose, the entrance hand-off and every loop boundary
    // all line up exactly.
    final double wave = math.sin(_loopController.value * 2 * math.pi);

    double dy = 0;
    double scale = 1;
    double angle = 0;

    switch (widget.motion) {
      case AnimatedLogoMotion.none:
        break;
      case AnimatedLogoMotion.float:
        dy = -wave * widget.floatOffset;
      case AnimatedLogoMotion.breathe:
        scale = 1 + (wave * widget.breatheScale);
      case AnimatedLogoMotion.floatAndBreathe:
        dy = -wave * widget.floatOffset;
        scale = 1 + (wave * widget.breatheScale);
      case AnimatedLogoMotion.sway:
        angle = wave * widget.swayAngle;
    }

    Widget result = Transform.scale(scale: scale * _pop.value, child: child);

    if (angle != 0) {
      result = Transform.rotate(angle: angle, child: result);
    }

    if (dy != 0) {
      result = Transform.translate(offset: Offset(0, dy), child: result);
    }

    return Opacity(opacity: _fade.value.clamp(0.0, 1.0), child: result);
  }

  Widget _mark() {
    final Widget logo = Image(
      image: widget.image,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      filterQuality: widget.filterQuality,
      isAntiAlias: true,
      gaplessPlayback: true,
      semanticLabel: widget.semanticLabel,
    );

    final Widget front = widget.shine ? _withShine(logo) : logo;
    final AnimatedLogoShadow? shadow = widget.shadow;

    if (shadow == null) return front;

    return Stack(
      // The blurred shadow extends past the logo's bounds; without this the
      // Stack would clip it to a hard edge.
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: <Widget>[_shadowLayer(logo, shadow), front],
    );
  }

  Widget _shadowLayer(Widget logo, AnimatedLogoShadow shadow) {
    return Transform.translate(
      offset: shadow.offset,
      child: IgnorePointer(
        child: ExcludeSemantics(
          child: ImageFiltered(
            imageFilter: ui.ImageFilter.blur(
              sigmaX: shadow.blur,
              sigmaY: shadow.blur,
            ),
            // srcIn keeps the image's alpha and replaces its colour, giving a
            // silhouette of the logo rather than a rectangle.
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(shadow.color, BlendMode.srcIn),
              child: logo,
            ),
          ),
        ),
      ),
    );
  }

  Widget _withShine(Widget logo) {
    return AnimatedBuilder(
      animation: _shine,
      child: logo,
      builder: (BuildContext context, Widget? child) {
        // Sweep the band's alignment across the mark instead of animating
        // gradient stops: stops stay fixed and valid, and Alignment is free to
        // travel outside -1..1 so the band fully clears both edges.
        final double travel = -1.6 + (_shine.value * 3.2);

        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (Rect bounds) => LinearGradient(
            begin: Alignment(travel - 0.45, -1),
            end: Alignment(travel + 0.45, 1),
            colors: <Color>[
              widget.shineColor.withAlpha(0),
              widget.shineColor,
              widget.shineColor.withAlpha(0),
            ],
          ).createShader(bounds),
          child: child,
        );
      },
    );
  }
}
