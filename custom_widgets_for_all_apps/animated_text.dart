/// Smooth, professional text entrance animations.
///
/// Drop-in and self-contained: pure Flutter, no packages, no theme lookups and
/// no project-relative imports, so this file can be copied into any app as-is.
/// Pairs with `animated_logo.dart`.
///
/// ```dart
/// AnimatedText('مرحباً بك', style: Theme.of(context).textTheme.headlineMedium)
/// ```
///
/// Staggered words, delayed so it lands after a logo above it:
///
/// ```dart
/// AnimatedText(
///   'Learn at your own pace',
///   mode: AnimatedTextMode.word,
///   delay: const Duration(milliseconds: 400),
/// )
/// ```
///
/// ## Arabic / RTL — read this before picking a mode
///
/// Arabic is cursive: letters join, and a letter's glyph depends on its
/// neighbours. Flutter shapes text per style run, so splitting a string into
/// one widget per character renders every letter in its **isolated** form and
/// the word visibly falls apart. That makes
/// [AnimatedTextMode.character] unsafe for Arabic.
///
/// Safe for Arabic:
///
/// * [AnimatedTextMode.fade] — animates the block as a whole.
/// * [AnimatedTextMode.reveal] — masks the painted result, so shaping is
///   untouched. Handles multi-line and is direction-aware.
/// * [AnimatedTextMode.word] — splits only on whitespace, so shaping inside
///   each word is preserved.
/// * [AnimatedTextMode.typewriter] — renders a growing prefix of the *same*
///   string as a single [Text], so each frame is shaped correctly.
///
/// Use [AnimatedTextMode.character] only for Latin text.
///
/// Honours the platform "reduce motion" setting: when it is on, the final text
/// is rendered immediately and nothing animates.
library;

import 'dart:async';

import 'package:flutter/material.dart';

/// How the text animates in.
enum AnimatedTextMode {
  /// The whole block fades and slides up together. Cheapest and safest.
  fade,

  /// A soft edge wipes across the text from its leading side.
  ///
  /// Shaping-safe in every script and the best choice for multi-line text,
  /// because the text is laid out once and only the painted result is masked.
  reveal,

  /// Words fade and slide up one after another. Safe for Arabic.
  ///
  /// Each word becomes its own inline widget, so keep this for headlines and
  /// short lines rather than paragraphs.
  word,

  /// Characters fade and slide up one after another.
  ///
  /// **Latin only** — this breaks Arabic letter joining. See the library docs.
  character,

  /// Characters appear one at a time, with an optional blinking caret.
  ///
  /// Shaping-safe: every frame is one [Text] holding a prefix of the string.
  typewriter,
}

/// Animated text. See the library docs above for mode guidance.
class AnimatedText extends StatefulWidget {
  const AnimatedText(
    this.text, {
    super.key,
    this.style,
    this.mode = AnimatedTextMode.fade,
    this.duration = const Duration(milliseconds: 650),
    this.stagger = const Duration(milliseconds: 45),
    this.delay = Duration.zero,
    this.curve = Curves.easeOutCubic,
    this.slideOffset = 10,
    this.textAlign,
    this.textDirection,
    this.maxLines,
    this.overflow = TextOverflow.clip,
    this.caret = true,
    this.caretColor,
    this.reserveSpace = true,
    this.respectReducedMotion = true,
    this.onCompleted,
    this.semanticsLabel,
  }) : assert(slideOffset >= 0, 'slideOffset must not be negative');

  /// The string to animate.
  final String text;

  /// Text style. Merged over the ambient [DefaultTextStyle], exactly as
  /// [Text] would.
  final TextStyle? style;

  /// Which animation to run. Defaults to [AnimatedTextMode.fade].
  final AnimatedTextMode mode;

  /// How long a single unit takes to animate in — and the whole block for
  /// [AnimatedTextMode.fade] and [AnimatedTextMode.reveal].
  ///
  /// Ignored by [AnimatedTextMode.typewriter], where characters appear
  /// instantly and [stagger] sets the typing speed.
  final Duration duration;

  /// Delay between consecutive units.
  ///
  /// For [AnimatedTextMode.word] and [AnimatedTextMode.character] this is the
  /// stagger between units; for [AnimatedTextMode.typewriter] it is the time
  /// per character. Unused by [AnimatedTextMode.fade] and
  /// [AnimatedTextMode.reveal].
  final Duration stagger;

  /// Delay before the animation begins. Useful for staggering a line against
  /// a logo or a heading above it.
  final Duration delay;

  /// Easing applied to each unit.
  final Curve curve;

  /// Vertical travel in logical pixels for the fading modes. Keep it small —
  /// text sliding a long way reads as cheap.
  final double slideOffset;

  /// See [Text.textAlign].
  ///
  /// For [AnimatedTextMode.typewriter], prefer start alignment: a centred
  /// line re-centres itself as it grows. [reserveSpace] removes that shift.
  final TextAlign? textAlign;

  /// See [Text.textDirection]. Defaults to the ambient [Directionality],
  /// which is what you normally want.
  final TextDirection? textDirection;

  /// See [Text.maxLines].
  final int? maxLines;

  /// See [Text.overflow].
  final TextOverflow overflow;

  /// Whether [AnimatedTextMode.typewriter] shows a blinking caret while
  /// typing. The caret disappears when typing finishes, so nothing keeps
  /// animating once the text has landed.
  final bool caret;

  /// Caret colour. Defaults to the resolved text colour.
  final Color? caretColor;

  /// Whether [AnimatedTextMode.typewriter] reserves the final text's size up
  /// front.
  ///
  /// On by default: an invisible copy of the full string holds the layout, so
  /// the line never reflows or nudges surrounding widgets as it types — the
  /// usual thing that makes a typewriter effect look amateurish.
  final bool reserveSpace;

  /// Whether to skip all animation when the platform asks for reduced motion.
  final bool respectReducedMotion;

  /// Called once when the animation finishes. Also called when motion is
  /// skipped, so it is safe to chain on.
  final VoidCallback? onCompleted;

  /// Accessibility label. Defaults to [text], so screen readers always
  /// announce the complete string rather than a partial one.
  final String? semanticsLabel;

  @override
  State<AnimatedText> createState() => _AnimatedTextState();
}

class _AnimatedTextState extends State<AnimatedText>
    with TickerProviderStateMixin {
  static const Duration _caretPeriod = Duration(milliseconds: 1100);

  late final AnimationController _controller = AnimationController(vsync: this);
  late final AnimationController _caret = AnimationController(
    vsync: this,
    duration: _caretPeriod,
  );

  /// Text split into words and the whitespace between them, in order.
  List<String> _tokens = <String>[];

  /// For each entry in [_tokens], its animation index, or null for
  /// whitespace, which is never animated.
  List<int?> _tokenUnit = <int?>[];

  /// Code points, so astral characters are never cut in half.
  List<int> _runes = <int>[];

  Timer? _delayTimer;
  bool _started = false;
  bool _reduced = false;
  bool _notified = false;

  @override
  void initState() {
    super.initState();
    _splitText();
    _controller.addStatusListener(_onStatus);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _reduced =
        widget.respectReducedMotion && MediaQuery.disableAnimationsOf(context);

    if (_reduced) {
      _delayTimer?.cancel();
      _controller.value = 1;
      _caret.stop();
      _notifyOnce();
      return;
    }

    if (_started) return;
    _started = true;
    _play();
  }

  @override
  void didUpdateWidget(AnimatedText oldWidget) {
    super.didUpdateWidget(oldWidget);

    final bool changed =
        widget.text != oldWidget.text ||
        widget.mode != oldWidget.mode ||
        widget.duration != oldWidget.duration ||
        widget.stagger != oldWidget.stagger;

    if (!changed) return;

    if (widget.text != oldWidget.text) _splitText();

    if (_reduced) {
      _controller.value = 1;
      return;
    }

    // Replay from the start so the new string animates in rather than
    // appearing mid-flight.
    _notified = false;
    _delayTimer?.cancel();
    _controller.reset();
    _play();
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _controller.dispose();
    _caret.dispose();
    super.dispose();
  }

  void _splitText() {
    _runes = widget.text.runes.toList(growable: false);

    final List<String> tokens = <String>[];
    final List<int?> units = <int?>[];
    int unit = 0;
    int cursor = 0;

    void push(String value, {required bool animated}) {
      tokens.add(value);
      units.add(animated ? unit++ : null);
    }

    for (final Match match in RegExp(r'\s+').allMatches(widget.text)) {
      if (match.start > cursor) {
        push(widget.text.substring(cursor, match.start), animated: true);
      }
      push(widget.text.substring(match.start, match.end), animated: false);
      cursor = match.end;
    }
    if (cursor < widget.text.length) {
      push(widget.text.substring(cursor), animated: true);
    }

    _tokens = List<String>.unmodifiable(tokens);
    _tokenUnit = List<int?>.unmodifiable(units);
  }

  int get _unitCount => switch (widget.mode) {
    AnimatedTextMode.fade || AnimatedTextMode.reveal => 1,
    AnimatedTextMode.word => _tokenUnit.whereType<int>().length,
    AnimatedTextMode.character || AnimatedTextMode.typewriter => _runes.length,
  };

  Duration get _totalDuration {
    final int units = _unitCount;

    final Duration total = switch (widget.mode) {
      AnimatedTextMode.fade || AnimatedTextMode.reveal => widget.duration,
      AnimatedTextMode.word || AnimatedTextMode.character =>
        widget.duration + widget.stagger * (units <= 1 ? 0 : units - 1),
      AnimatedTextMode.typewriter => widget.stagger * (units == 0 ? 1 : units),
    };

    // A zero-length controller never completes, so onCompleted would never
    // fire and the text would stay invisible.
    return total > Duration.zero ? total : const Duration(milliseconds: 1);
  }

  void _play() {
    _controller.duration = _totalDuration;

    if (widget.mode == AnimatedTextMode.typewriter && widget.caret) {
      _caret.repeat();
    }

    if (widget.delay == Duration.zero) {
      _controller.forward();
      return;
    }

    _delayTimer = Timer(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  void _onStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    _caret.stop();
    _notifyOnce();
  }

  void _notifyOnce() {
    if (_notified) return;
    _notified = true;

    final VoidCallback? callback = widget.onCompleted;
    if (callback == null) return;

    // Never fire during build or layout.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) callback();
    });
  }

  /// Eased progress of unit [index], derived straight from the controller so
  /// no per-frame objects are allocated.
  double _unitProgress(int index) {
    final double total = _totalDuration.inMicroseconds.toDouble();
    final double start = (widget.stagger * index).inMicroseconds / total;
    final double span = widget.duration.inMicroseconds / total;

    if (span <= 0) return _controller.value >= start ? 1 : 0;

    final double raw = ((_controller.value - start) / span).clamp(0.0, 1.0);
    return widget.curve.transform(raw);
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle style = DefaultTextStyle.of(
      context,
    ).style.merge(widget.style);

    final TextDirection direction =
        widget.textDirection ?? Directionality.of(context);

    return AnimatedBuilder(
      animation: widget.mode == AnimatedTextMode.typewriter
          ? Listenable.merge(<Listenable>[_controller, _caret])
          : _controller,
      builder: (BuildContext context, Widget? child) => switch (widget.mode) {
        AnimatedTextMode.fade => _buildFade(style),
        AnimatedTextMode.reveal => _buildReveal(style, direction),
        AnimatedTextMode.word => _buildSpans(style, words: true),
        AnimatedTextMode.character => _buildSpans(style, words: false),
        AnimatedTextMode.typewriter => _buildTypewriter(style),
      },
    );
  }

  Text _plainText(TextStyle style, {String? value, bool muteSemantics = true}) {
    return Text(
      value ?? widget.text,
      style: style,
      textAlign: widget.textAlign,
      textDirection: widget.textDirection,
      maxLines: widget.maxLines,
      overflow: widget.overflow,
      // The full string is announced once by the Semantics wrapper, so the
      // rendered (possibly partial) text must not be read as well.
      semanticsLabel: muteSemantics ? '' : null,
    );
  }

  Widget _withSemantics(Widget child) {
    return Semantics(
      label: widget.semanticsLabel ?? widget.text,
      container: true,
      child: child,
    );
  }

  Widget _rise(double progress, Widget child) {
    final Widget shifted = widget.slideOffset == 0
        ? child
        : Transform.translate(
            offset: Offset(0, (1 - progress) * widget.slideOffset),
            child: child,
          );

    return Opacity(opacity: progress.clamp(0.0, 1.0), child: shifted);
  }

  Widget _buildFade(TextStyle style) {
    return _withSemantics(
      _rise(widget.curve.transform(_controller.value), _plainText(style)),
    );
  }

  Widget _buildReveal(TextStyle style, TextDirection direction) {
    final double progress = widget.curve.transform(_controller.value);
    final bool rtl = direction == TextDirection.rtl;

    // Soft edge, a touch wider than a hard wipe so it reads as a sweep.
    const double feather = 0.12;

    return _withSemantics(
      ShaderMask(
        // dstIn keeps the text only where the mask is opaque.
        blendMode: BlendMode.dstIn,
        shaderCallback: (Rect bounds) => LinearGradient(
          begin: rtl ? Alignment.centerRight : Alignment.centerLeft,
          end: rtl ? Alignment.centerLeft : Alignment.centerRight,
          colors: const <Color>[Color(0xFFFFFFFF), Color(0x00FFFFFF)],
          stops: <double>[
            (progress - feather).clamp(0.0, 1.0),
            (progress + feather).clamp(0.0, 1.0),
          ],
        ).createShader(bounds),
        child: _plainText(style),
      ),
    );
  }

  Widget _buildSpans(TextStyle style, {required bool words}) {
    final List<InlineSpan> spans = <InlineSpan>[];

    if (words) {
      for (int i = 0; i < _tokens.length; i++) {
        final int? unit = _tokenUnit[i];

        // Whitespace stays a plain span so the paragraph still wraps at it.
        if (unit == null) {
          spans.add(TextSpan(text: _tokens[i], style: style));
          continue;
        }

        spans.add(_unitSpan(_tokens[i], style, _unitProgress(unit)));
      }
    } else {
      for (int i = 0; i < _runes.length; i++) {
        spans.add(
          _unitSpan(String.fromCharCode(_runes[i]), style, _unitProgress(i)),
        );
      }
    }

    return _withSemantics(
      ExcludeSemantics(
        child: Text.rich(
          TextSpan(children: spans),
          style: style,
          textAlign: widget.textAlign,
          textDirection: widget.textDirection,
          maxLines: widget.maxLines,
          overflow: widget.overflow,
        ),
      ),
    );
  }

  InlineSpan _unitSpan(String value, TextStyle style, double progress) {
    return WidgetSpan(
      alignment: PlaceholderAlignment.baseline,
      baseline: TextBaseline.alphabetic,
      child: _rise(progress, Text(value, style: style)),
    );
  }

  Widget _buildTypewriter(TextStyle style) {
    final int shown = (_controller.value * _runes.length).round().clamp(
      0,
      _runes.length,
    );
    final String typed = String.fromCharCodes(_runes.take(shown));

    final bool showCaret =
        widget.caret && !_reduced && !_controller.isCompleted;

    final Widget line = showCaret
        ? Text.rich(
            TextSpan(
              children: <InlineSpan>[
                TextSpan(text: typed),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Opacity(
                    // Hard on/off blink, the way a real caret behaves.
                    opacity: _caret.value < 0.5 ? 1 : 0,
                    child: Container(
                      width: 2,
                      height: (style.fontSize ?? 14) * 1.1,
                      color: widget.caretColor ?? style.color,
                    ),
                  ),
                ),
              ],
            ),
            style: style,
            textAlign: widget.textAlign,
            textDirection: widget.textDirection,
            maxLines: widget.maxLines,
            overflow: widget.overflow,
          )
        : _plainText(style, value: typed);

    if (!widget.reserveSpace) return _withSemantics(line);

    return _withSemantics(
      Stack(
        children: <Widget>[
          // Invisible full string holds the final layout so nothing reflows.
          ExcludeSemantics(
            child: Opacity(opacity: 0, child: _plainText(style)),
          ),
          Positioned.fill(child: line),
        ],
      ),
    );
  }
}
