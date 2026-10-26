/// A button with smooth press, loading, success and error transitions.
///
/// Drop-in and self-contained: pure Flutter, no packages and no
/// project-relative imports, so this file can be copied into any app as-is.
/// Colours fall back to the ambient [ColorScheme], so it looks native in any
/// theme without being coupled to one. Pairs with the other
/// `animated_*.dart` widgets in this folder.
///
/// ```dart
/// AnimatedButton(label: 'حفظ', onPressed: cubit.save)
/// ```
///
/// The button is **dumb**: it renders whatever [AnimatedButton.status] it is
/// given and reports taps. Drive the status from your Cubit/Bloc — the widget
/// never flips its own status, and never resets itself out of
/// [AnimatedButtonStatus.success] or [AnimatedButtonStatus.error]:
///
/// ```dart
/// BlocBuilder<SaveCubit, SaveState>(
///   builder: (BuildContext context, SaveState state) => AnimatedButton(
///     label: 'حفظ',
///     status: state.isSaving
///         ? AnimatedButtonStatus.loading
///         : AnimatedButtonStatus.idle,
///     width: double.infinity,
///     onPressed: context.read<SaveCubit>().save,
///   ),
/// )
/// ```
///
/// Outlined variant — pass a border and a transparent background:
///
/// ```dart
/// AnimatedButton(
///   label: 'إلغاء',
///   background: Colors.transparent,
///   foreground: Theme.of(context).colorScheme.primary,
///   borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
///   onPressed: () => Navigator.of(context).pop(),
/// )
/// ```
///
/// ## What this handles that a hand-rolled button usually does not
///
/// * **The width never changes.** The label stays laid out (just transparent)
///   while a spinner or status icon is overlaid on top, so the button does not
///   resize or nudge its neighbours when it starts loading.
/// * **Double submits are dropped** — see [AnimatedButton.debounce].
/// * **Press state cannot get stuck.** Scale is driven by
///   [InkWell.onHighlightChanged], so dragging a finger off the button
///   releases it correctly instead of leaving it pressed.
/// * **Reachable targets.** Enforces a minimum 48x48 tap target regardless of
///   the height requested.
/// * **RTL comes for free.** [AnimatedButton.icon] sits in a [Row], so it
///   renders at the leading edge — right in Arabic, left in English.
/// * Honours the platform "reduce motion" setting: transitions become
///   instant and the press scale is skipped.
library;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

/// What the button is currently showing.
enum AnimatedButtonStatus {
  /// Normal, tappable, label visible.
  idle,

  /// Work in flight: a spinner replaces the label and taps are ignored.
  loading,

  /// Transient confirmation tick. Reset it from your state management.
  success,

  /// Transient failure mark. Reset it from your state management.
  error,
}

/// An animated button. See the library docs above for usage.
class AnimatedButton extends StatefulWidget {
  const AnimatedButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
    this.status = AnimatedButtonStatus.idle,
    this.background,
    this.foreground,
    this.disabledBackground,
    this.disabledForeground,
    this.borderSide,
    this.radius = 12,
    this.elevation = 0,
    this.width,
    this.height = 48,
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
    this.iconGap = 8,
    this.textStyle,
    this.pressedScale = 0.97,
    this.transitionDuration = const Duration(milliseconds: 180),
    this.pressDuration = const Duration(milliseconds: 110),
    this.debounce = const Duration(milliseconds: 350),
    this.haptics = true,
    this.successIcon = Icons.check_rounded,
    this.errorIcon = Icons.error_outline_rounded,
    this.respectReducedMotion = true,
    this.semanticLabel,
  }) : assert(
         pressedScale > 0 && pressedScale <= 1,
         'pressedScale must be in (0, 1] — 0.97 is a good default',
       ),
       assert(radius >= 0, 'radius must not be negative'),
       assert(elevation >= 0, 'elevation must not be negative'),
       assert(height >= 0, 'height must not be negative'),
       assert(iconGap >= 0, 'iconGap must not be negative');

  /// Button text. Kept to one line with an ellipsis — buttons should not wrap.
  final String label;

  /// Tap handler. Pass null to disable the button.
  final VoidCallback? onPressed;

  /// Optional leading icon. Renders at the leading edge in both directions.
  final Widget? icon;

  /// What to display. Owned by your state management, not by this widget.
  final AnimatedButtonStatus status;

  /// Fill colour. Defaults to [ColorScheme.primary].
  final Color? background;

  /// Label and icon colour. Defaults to [ColorScheme.onPrimary], and wins over
  /// any colour set in [textStyle].
  final Color? foreground;

  /// Fill colour when disabled. Defaults to [background] dimmed toward the
  /// surface, which reads correctly in both light and dark themes.
  final Color? disabledBackground;

  /// Foreground colour when disabled. Defaults to [foreground] dimmed.
  final Color? disabledForeground;

  /// Optional outline. Combine with a transparent [background] for a
  /// secondary/outlined button.
  final BorderSide? borderSide;

  /// Corner radius.
  final double radius;

  /// Material elevation. Defaults to flat.
  final double elevation;

  /// Fixed width. Pass `double.infinity` to fill the parent, or leave null to
  /// size to the content.
  final double? width;

  /// Requested height. The rendered height is at least 48 so the tap target
  /// stays reachable.
  final double height;

  /// Inner padding around the label and icon.
  final EdgeInsetsGeometry padding;

  /// Space between [icon] and [label].
  final double iconGap;

  /// Label style. Defaults to [TextTheme.labelLarge]; its colour is replaced
  /// by [foreground].
  final TextStyle? textStyle;

  /// Scale while held down. `1` disables the press animation.
  final double pressedScale;

  /// Duration of the label/spinner/icon cross-fades.
  final Duration transitionDuration;

  /// Duration of the press scale.
  final Duration pressDuration;

  /// Window in which a second tap is ignored, to stop double submits.
  ///
  /// Pass [Duration.zero] to accept every tap — only do that if the handler is
  /// genuinely idempotent.
  final Duration debounce;

  /// Whether to fire a light haptic on tap.
  final bool haptics;

  /// Icon shown for [AnimatedButtonStatus.success].
  final IconData successIcon;

  /// Icon shown for [AnimatedButtonStatus.error].
  final IconData errorIcon;

  /// Whether to skip animation when the platform asks for reduced motion.
  final bool respectReducedMotion;

  /// Accessibility label. Defaults to [label].
  final String? semanticLabel;

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  /// Smallest comfortable tap target, per both Material and HIG guidance.
  static const double _minTarget = 48;

  // Duration comparisons are not const-evaluable, so they cannot be asserted
  // in a const constructor; a zero-length controller is clamped here instead.
  static Duration _positive(Duration value) =>
      value > Duration.zero ? value : const Duration(milliseconds: 1);

  late final AnimationController _press = AnimationController(
    vsync: this,
    duration: _positive(widget.pressDuration),
  );

  Duration? _lastTap;
  bool _reduced = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduced =
        widget.respectReducedMotion && MediaQuery.disableAnimationsOf(context);

    if (_reduced && _press.value != 0) {
      _press.value = 0;
    }
  }

  @override
  void didUpdateWidget(AnimatedButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _press.duration = _positive(widget.pressDuration);

    // Releasing the press when the button stops being interactive avoids a
    // button left visually held down after it starts loading.
    if (!_interactive && _press.value != 0) _press.reverse();
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  bool get _interactive =>
      widget.onPressed != null && widget.status != AnimatedButtonStatus.loading;

  Duration get _transition =>
      _reduced ? Duration.zero : widget.transitionDuration;

  void _onHighlightChanged(bool pressed) {
    if (_reduced || widget.pressedScale == 1) return;
    if (pressed) {
      _press.forward();
    } else {
      _press.reverse();
    }
  }

  void _onTap() {
    final VoidCallback? onPressed = widget.onPressed;
    if (onPressed == null) return;

    // Drop a second tap inside the debounce window so a slow handler cannot
    // be submitted twice. Frame timestamps rather than DateTime.now(): they
    // are monotonic (immune to system clock changes) and advance with
    // pump() under test.
    final Duration now = SchedulerBinding.instance.currentSystemFrameTimeStamp;
    final Duration? last = _lastTap;
    if (last != null && now - last < widget.debounce) return;
    _lastTap = now;

    if (widget.haptics) HapticFeedback.selectionClick();
    onPressed();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final bool enabled = _interactive;

    final Color background = widget.background ?? scheme.primary;
    final Color foreground = widget.foreground ?? scheme.onPrimary;

    // Dimming toward the surface rather than applying an alpha keeps the
    // disabled state readable on any background, in light and dark alike.
    final Color effectiveBackground = enabled
        ? background
        : widget.disabledBackground ??
              Color.lerp(background, scheme.surface, 0.6)!;
    final Color effectiveForeground = enabled
        ? foreground
        : widget.disabledForeground ??
              Color.lerp(foreground, scheme.surface, 0.45)!;

    final TextStyle labelStyle =
        (widget.textStyle ??
                theme.textTheme.labelLarge ??
                const TextStyle(fontWeight: FontWeight.w600))
            .copyWith(color: effectiveForeground);

    final BorderRadius borderRadius = BorderRadius.circular(widget.radius);

    final BorderSide? side = widget.borderSide;

    final Widget button = Material(
      color: effectiveBackground,
      elevation: widget.elevation,
      clipBehavior: Clip.antiAlias,
      // Material asserts that borderRadius and shape are never both set, so
      // when there is a border the shape carries the radius instead.
      borderRadius: side == null ? borderRadius : null,
      shape: side == null
          ? null
          : RoundedRectangleBorder(borderRadius: borderRadius, side: side),
      child: InkWell(
        onTap: enabled ? _onTap : null,
        // Fires on press, release AND cancel, so the scale can never stick.
        onHighlightChanged: _onHighlightChanged,
        borderRadius: borderRadius,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: widget.height < _minTarget ? _minTarget : widget.height,
            minWidth: _minTarget,
          ),
          child: Padding(
            padding: widget.padding,
            child: _content(labelStyle, effectiveForeground),
          ),
        ),
      ),
    );

    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.semanticLabel ?? widget.label,
      child: ExcludeSemantics(
        child: SizedBox(width: widget.width, child: _scaled(button)),
      ),
    );
  }

  Widget _scaled(Widget child) {
    if (_reduced || widget.pressedScale == 1) return child;

    return AnimatedBuilder(
      animation: _press,
      // The button subtree is passed as `child` so only the transform is
      // rebuilt while the press animates.
      child: child,
      builder: (BuildContext context, Widget? inner) => Transform.scale(
        scale: 1 - ((1 - widget.pressedScale) * _press.value),
        child: inner,
      ),
    );
  }

  Widget _content(TextStyle labelStyle, Color foreground) {
    final Widget? icon = widget.icon;
    final bool idle = widget.status == AnimatedButtonStatus.idle;

    final Widget label = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (icon != null) ...<Widget>[
          IconTheme.merge(
            data: IconThemeData(color: foreground, size: 18),
            child: icon,
          ),
          SizedBox(width: widget.iconGap),
        ],
        Flexible(
          child: Text(
            widget.label,
            style: labelStyle,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        // The label is always laid out, so the button keeps one width across
        // every status and never resizes mid-interaction.
        AnimatedOpacity(
          opacity: idle ? 1 : 0,
          duration: _transition,
          curve: Curves.easeOut,
          child: label,
        ),

        Positioned.fill(
          child: Center(
            child: AnimatedSwitcher(
              duration: _transition,
              child: _overlay(foreground),
            ),
          ),
        ),
      ],
    );
  }

  Widget _overlay(Color foreground) {
    switch (widget.status) {
      case AnimatedButtonStatus.idle:
        return const SizedBox.shrink(key: ValueKey<String>('idle'));

      case AnimatedButtonStatus.loading:
        return SizedBox(
          key: const ValueKey<String>('loading'),
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(foreground),
          ),
        );

      case AnimatedButtonStatus.success:
        return Icon(
          widget.successIcon,
          key: const ValueKey<String>('success'),
          color: foreground,
          size: 22,
        );

      case AnimatedButtonStatus.error:
        return Icon(
          widget.errorIcon,
          key: const ValueKey<String>('error'),
          color: foreground,
          size: 22,
        );
    }
  }
}
