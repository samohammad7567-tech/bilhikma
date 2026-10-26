/// A section that expands and collapses smoothly, without the rigidity of
/// [ExpansionTile].
///
/// Drop-in and self-contained: pure Flutter, no packages and no
/// project-relative imports, so this file can be copied into any app as-is.
/// Colours fall back to the ambient [ColorScheme], so it looks native in any
/// theme without being coupled to one. Pairs with the other
/// `animated_*.dart` widgets in this folder.
///
/// An FAQ row that manages its own state:
///
/// ```dart
/// AnimatedExpandable(
///   title: Text(question.title),
///   child: Text(question.answer),
/// )
/// ```
///
/// Driven from a Cubit — the parent owns which panel is open, so only one can
/// be:
///
/// ```dart
/// AnimatedExpandable(
///   title: Text(section.title),
///   expanded: state.openSection == section.id,
///   onExpandedChanged: (bool expanded) =>
///       context.read<FaqCubit>().toggle(expanded ? section.id : null),
///   child: SectionBody(section),
/// )
/// ```
///
/// As a card, with the whole header tappable:
///
/// ```dart
/// AnimatedExpandable(
///   title: Text(context.translate(LangKeys.orderDetails)),
///   leading: const Icon(Icons.receipt_long_rounded),
///   background: Theme.of(context).colorScheme.surfaceContainer,
///   borderRadius: BorderRadius.circular(16),
///   padding: const EdgeInsets.all(16),
///   child: OrderLines(order),
/// )
/// ```
///
/// ## Notes
///
/// * **Controlled or self-managed.** Leave [AnimatedExpandable.expanded] null
///   and it tracks its own state; pass it and the parent — your Cubit — owns
///   the truth, which is the only way to keep an accordion to one open panel.
/// * **The body is not built while collapsed.** Nothing off-screen is laid
///   out, mounted or kept alive unless you ask for it with
///   [AnimatedExpandable.maintainState] — worth it only when the body holds
///   state you need to survive a collapse, like a part-filled form.
/// * **It cannot overflow mid-animation.** The body is clipped as it grows, so
///   a tall child does not spill over the rows below while opening.
/// * **RTL comes for free.** The header is a [Row], so the leading widget and
///   the chevron sit at the correct edges in both directions, and the chevron
///   rotates the way the reading direction implies.
/// * Honours the platform "reduce motion" setting: the body appears and
///   disappears without animating.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

/// An expanding, collapsing section. See the library docs above for usage.
class AnimatedExpandable extends StatefulWidget {
  const AnimatedExpandable({
    required this.title,
    required this.child,
    super.key,
    this.expanded,
    this.initiallyExpanded = false,
    this.onExpandedChanged,
    this.leading,
    this.trailing,
    this.subtitle,
    this.duration = const Duration(milliseconds: 280),
    this.curve = Curves.easeInOutCubic,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    this.childPadding = const EdgeInsets.fromLTRB(16, 0, 16, 16),
    this.background,
    this.borderRadius,
    this.border,
    this.divider = false,
    this.maintainState = false,
    this.enabled = true,
    this.respectReducedMotion = true,
  });

  /// The header's main content — usually a [Text].
  final Widget title;

  /// The body, revealed when expanded.
  final Widget child;

  /// Controlled state. Null leaves the widget to manage its own.
  final bool? expanded;

  /// Starting state when self-managed. Ignored when [expanded] is given.
  final bool initiallyExpanded;

  /// Called with the state the user asked for. Required reading when
  /// [expanded] is given — without acting on it, nothing will open.
  final ValueChanged<bool>? onExpandedChanged;

  /// Widget before the title — an icon, an avatar, a number.
  final Widget? leading;

  /// Replaces the rotating chevron. Pass [SizedBox.shrink] to drop it.
  final Widget? trailing;

  /// Secondary line under the title.
  final Widget? subtitle;

  /// Length of the open and close animation.
  final Duration duration;

  /// Easing for the reveal. Symmetric curves suit a two-way animation.
  final Curve curve;

  /// Padding around the header.
  final EdgeInsetsGeometry padding;

  /// Padding around the body.
  final EdgeInsetsGeometry childPadding;

  /// Surface colour behind the whole section.
  final Color? background;

  /// Corner radius of the surface and of the header's ink.
  final BorderRadius? borderRadius;

  /// Optional outline around the section.
  final BoxBorder? border;

  /// Whether a hairline is drawn between header and body while open.
  final bool divider;

  /// Whether the body stays mounted while collapsed. Off by default — see the
  /// library docs.
  final bool maintainState;

  /// Whether the header responds to taps.
  final bool enabled;

  /// When true (the default), the platform "reduce motion" setting swaps the
  /// body in and out instead of animating it.
  final bool respectReducedMotion;

  @override
  State<AnimatedExpandable> createState() => _AnimatedExpandableState();
}

class _AnimatedExpandableState extends State<AnimatedExpandable>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
    value: _initialValue ? 1 : 0,
  );

  late final CurvedAnimation _reveal = CurvedAnimation(
    parent: _controller,
    curve: widget.curve,
  );

  /// Mirrors [AnimatedExpandable.expanded] while self-managed.
  late bool _expanded = _initialValue;

  bool get _initialValue => widget.expanded ?? widget.initiallyExpanded;

  bool get _isExpanded => widget.expanded ?? _expanded;

  @override
  void didUpdateWidget(AnimatedExpandable oldWidget) {
    super.didUpdateWidget(oldWidget);

    _controller.duration = widget.duration;

    // A controlled panel follows the parent, including when the parent closes
    // it because a sibling was opened.
    if (widget.expanded != null && widget.expanded != oldWidget.expanded) {
      _animateTo(widget.expanded!);
    }
  }

  @override
  void dispose() {
    _reveal.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _animateTo(bool expanded) {
    if (_reducedMotion) {
      _controller.value = expanded ? 1 : 0;
      return;
    }

    if (expanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  bool get _reducedMotion =>
      widget.respectReducedMotion && MediaQuery.disableAnimationsOf(context);

  void _toggle() {
    final bool next = !_isExpanded;

    // Self-managed panels move themselves; controlled ones wait to be told.
    if (widget.expanded == null) {
      setState(() => _expanded = next);
      _animateTo(next);
    }

    widget.onExpandedChanged?.call(next);
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final BorderRadius radius = widget.borderRadius ?? BorderRadius.zero;

    Widget section = Material(
      type: widget.background == null
          ? MaterialType.transparency
          : MaterialType.canvas,
      color: widget.background ?? Colors.transparent,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          InkWell(
            onTap: widget.enabled ? _toggle : null,
            customBorder: RoundedRectangleBorder(borderRadius: radius),
            child: Padding(padding: widget.padding, child: _header(scheme)),
          ),
          _body(scheme),
        ],
      ),
    );

    final BoxBorder? border = widget.border;
    if (border != null) {
      section = DecoratedBox(
        decoration: BoxDecoration(border: border, borderRadius: radius),
        child: section,
      );
    }

    return section;
  }

  Widget _header(ColorScheme scheme) {
    final Widget? leading = widget.leading;
    final Widget? subtitle = widget.subtitle;

    return Row(
      children: <Widget>[
        if (leading != null) ...<Widget>[leading, const SizedBox(width: 12)],
        Expanded(
          child: subtitle == null
              ? widget.title
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    widget.title,
                    const SizedBox(height: 4),
                    subtitle,
                  ],
                ),
        ),
        const SizedBox(width: 12),
        widget.trailing ?? _chevron(scheme),
      ],
    );
  }

  /// Rotates a quarter turn into the reading direction, so it points down when
  /// open in both RTL and LTR.
  Widget _chevron(ColorScheme scheme) {
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;

    return RotationTransition(
      turns: _reveal.drive(Tween<double>(begin: 0, end: isRtl ? -0.25 : 0.25)),
      child: Icon(
        isRtl ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
        color: scheme.onSurfaceVariant,
      ),
    );
  }

  Widget _body(ColorScheme scheme) {
    // Collapsed and not asked to stay: the body is not in the tree at all, so
    // nothing off-screen is laid out or kept alive.
    if (!_isExpanded && !_controller.isAnimating && !widget.maintainState) {
      return const SizedBox.shrink();
    }

    final Widget body = Padding(
      padding: widget.childPadding,
      child: widget.child,
    );

    return AnimatedBuilder(
      animation: _reveal,
      child: body,
      builder: (BuildContext context, Widget? child) {
        final double t = _reveal.value;

        // Fully closed mid-rebuild: drop it again rather than keep an
        // zero-height clip in the tree.
        if (t == 0 && !widget.maintainState) return const SizedBox.shrink();

        return ClipRect(
          // Clipped as it grows, so a tall body cannot spill over the rows
          // below while opening.
          child: Align(
            alignment: Alignment.topCenter,
            heightFactor: math.max(t, 0),
            child: Opacity(
              // Content fades in over the back half of the travel: fading in
              // step with the height makes the text look like it is stretching.
              opacity: Curves.easeIn.transform(
                ((t - 0.35) / 0.65).clamp(0.0, 1.0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (widget.divider)
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: scheme.outlineVariant,
                    ),
                  child ?? const SizedBox.shrink(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
