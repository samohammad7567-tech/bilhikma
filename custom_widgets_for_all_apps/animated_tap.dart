/// Makes anything tappable, with the press feedback a hand-rolled
/// `GestureDetector` never quite gets right.
///
/// Drop-in and self-contained: pure Flutter, no packages and no
/// project-relative imports, so this file can be copied into any app as-is.
/// Colours fall back to the ambient [ColorScheme], so it looks native in any
/// theme without being coupled to one. Pairs with the other
/// `animated_*.dart` widgets in this folder.
///
/// A list row:
///
/// ```dart
/// AnimatedTap(
///   onTap: () => context.push('${AppRoutes.lesson}/${lesson.id}'),
///   child: LessonRow(lesson),
/// )
/// ```
///
/// A card — give it a surface and it draws one:
///
/// ```dart
/// AnimatedTap(
///   onTap: cubit.openBook,
///   background: Theme.of(context).colorScheme.surfaceContainer,
///   elevation: 2,
///   padding: const EdgeInsets.all(16),
///   child: BookSummary(book),
/// )
/// ```
///
/// A small icon target, lifted to a reachable size without changing how it
/// looks:
///
/// ```dart
/// AnimatedTap(
///   onTap: cubit.toggleFavorite,
///   borderRadius: BorderRadius.circular(24),
///   padding: const EdgeInsets.all(8),
///   child: Icon(state.isFavorite ? Icons.favorite : Icons.favorite_border),
/// )
/// ```
///
/// Use [AnimatedButton] from `animated_button.dart` for a labelled button with
/// loading and result states; use this for everything else that responds to a
/// tap.
///
/// ## What this handles that a hand-rolled tap target usually does not
///
/// * **Press state cannot get stuck.** The scale is driven by
///   [InkWell.onHighlightChanged], so dragging a finger off the child releases
///   it instead of leaving it held down.
/// * **Double taps are dropped.** Two taps inside [AnimatedTap.debounce] fire
///   once — the cheapest fix for double navigation pushes and double submits.
/// * **The ink stays inside the corners.** The splash is clipped to
///   [AnimatedTap.borderRadius] rather than bleeding past a rounded card.
/// * **Reachable targets.** Enforces a minimum 48x48 tap target by default,
///   whatever size the child is.
/// * **Disabled looks identical.** With no callbacks it renders the same
///   surface without ink or scale, so a list does not jump between states.
/// * Honours the platform "reduce motion" setting: the press scale is skipped
///   and the ink is left to do the work.
library;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

/// A tappable surface with press, ink and elevation feedback.
class AnimatedTap extends StatefulWidget {
  const AnimatedTap({
    required this.child,
    super.key,
    this.onTap,
    this.onLongPress,
    this.pressedScale = 0.97,
    this.duration = const Duration(milliseconds: 120),
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.background,
    this.border,
    this.elevation = 0,
    this.pressedElevation,
    this.shadowColor,
    this.splash = true,
    this.splashColor,
    this.haptics = false,
    this.debounce = const Duration(milliseconds: 400),
    this.padding,
    this.ensureTapTarget = true,
    this.semanticLabel,
    this.respectReducedMotion = true,
  });

  /// The content being made tappable.
  final Widget child;

  /// Tap handler. With both this and [onLongPress] null the surface renders
  /// without any interaction.
  final VoidCallback? onTap;

  /// Long-press handler.
  final VoidCallback? onLongPress;

  /// Scale while held. `1` disables the squeeze; below ~0.93 it reads as the
  /// row collapsing rather than responding.
  final double pressedScale;

  /// Length of the press and release transitions.
  final Duration duration;

  /// Corner radius of the surface, the ink and the shadow alike.
  final BorderRadius borderRadius;

  /// Surface colour. `null` leaves the background to whatever is behind,
  /// making this a pure wrapper.
  final Color? background;

  /// Optional outline.
  final BoxBorder? border;

  /// Resting elevation. Needs a [background] to cast against.
  final double elevation;

  /// Elevation while held. Defaults to half of [elevation] — pressing a card
  /// should sink it, not lift it.
  final double? pressedElevation;

  /// Shadow colour. Defaults to [ColorScheme.shadow] at 24%.
  final Color? shadowColor;

  /// Whether a ripple is drawn. Turn it off for surfaces that already move
  /// enough on their own.
  final bool splash;

  /// Ripple colour. Defaults to the Material default for the theme.
  final Color? splashColor;

  /// Whether a tap fires a selection click. Reach for it on toggles and
  /// pickers, not on ordinary navigation.
  final bool haptics;

  /// Window in which a second tap is ignored. [Duration.zero] disables it.
  final Duration debounce;

  /// Padding inside the surface, around [child].
  final EdgeInsetsGeometry? padding;

  /// Whether the target is grown to at least 48x48. Leave it on for icons and
  /// compact rows.
  final bool ensureTapTarget;

  /// Screen-reader description of the action. Pass an already-translated
  /// string.
  final String? semanticLabel;

  /// When true (the default), the platform "reduce motion" setting skips the
  /// press scale.
  final bool respectReducedMotion;

  @override
  State<AnimatedTap> createState() => _AnimatedTapState();
}

class _AnimatedTapState extends State<AnimatedTap> {
  bool _pressed = false;
  Duration? _lastTap;

  bool get _interactive => widget.onTap != null || widget.onLongPress != null;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  void _handleTap() {
    final VoidCallback? onTap = widget.onTap;
    if (onTap == null) return;

    // Dropped rather than queued: a second navigation push or submit is never
    // what the user meant by tapping twice quickly. Frame timestamps rather
    // than DateTime.now(): they are monotonic (immune to system clock changes)
    // and advance with pump() under test.
    final Duration now = SchedulerBinding.instance.currentSystemFrameTimeStamp;
    final Duration? last = _lastTap;

    if (last != null &&
        widget.debounce > Duration.zero &&
        now - last < widget.debounce) {
      return;
    }

    _lastTap = now;

    if (widget.haptics) HapticFeedback.selectionClick();

    onTap();
  }

  void _handleLongPress() {
    final VoidCallback? onLongPress = widget.onLongPress;
    if (onLongPress == null) return;

    if (widget.haptics) HapticFeedback.mediumImpact();

    onLongPress();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool animate =
        !(widget.respectReducedMotion &&
            MediaQuery.disableAnimationsOf(context));

    final double elevation = _pressed && _interactive
        ? (widget.pressedElevation ?? widget.elevation / 2)
        : widget.elevation;

    final bool opaque = widget.background != null || widget.elevation > 0;

    Widget content = widget.child;

    final EdgeInsetsGeometry? padding = widget.padding;
    if (padding != null) {
      content = Padding(padding: padding, child: content);
    }

    if (widget.ensureTapTarget) {
      content = ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        child: Center(widthFactor: 1, heightFactor: 1, child: content),
      );
    }

    Widget surface = Material(
      // Transparency is what keeps this usable as a plain wrapper: no colour
      // is painted, and the ink still clips to the corners below.
      type: opaque ? MaterialType.canvas : MaterialType.transparency,
      color: widget.background ?? Colors.transparent,
      elevation: elevation,
      shadowColor: widget.shadowColor ?? scheme.shadow.withValues(alpha: 0.24),
      borderRadius: widget.borderRadius,
      animationDuration: widget.duration,
      clipBehavior: Clip.antiAlias,
      child: _interactive
          ? InkWell(
              onTap: _handleTap,
              onLongPress: widget.onLongPress == null ? null : _handleLongPress,
              // Driven by the highlight rather than raw pointer events, so a
              // finger dragged off the child releases the press properly.
              onHighlightChanged: animate ? _setPressed : null,
              customBorder: RoundedRectangleBorder(
                borderRadius: widget.borderRadius,
              ),
              splashFactory: widget.splash ? null : NoSplash.splashFactory,
              splashColor: widget.splashColor,
              child: content,
            )
          : content,
    );

    final BoxBorder? border = widget.border;
    if (border != null) {
      surface = DecoratedBox(
        decoration: BoxDecoration(
          border: border,
          borderRadius: widget.borderRadius,
        ),
        child: surface,
      );
    }

    if (animate && widget.pressedScale != 1 && _interactive) {
      surface = AnimatedScale(
        scale: _pressed ? widget.pressedScale : 1,
        duration: widget.duration,
        curve: Curves.easeOut,
        child: surface,
      );
    }

    final String? semanticLabel = widget.semanticLabel;
    if (semanticLabel == null) return surface;

    return Semantics(
      label: semanticLabel,
      button: _interactive,
      child: surface,
    );
  }
}
