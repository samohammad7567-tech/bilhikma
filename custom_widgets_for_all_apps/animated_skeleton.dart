/// Shimmering skeleton placeholders: the loading state for lists, cards and
/// detail pages.
///
/// Drop-in and self-contained: pure Flutter, no packages and no
/// project-relative imports, so this file can be copied into any app as-is.
/// Colours fall back to the ambient [ColorScheme], so it looks native in any
/// theme without being coupled to one. Pairs with the other
/// `animated_*.dart` widgets in this folder.
///
/// A list that is loading:
///
/// ```dart
/// const SkeletonList(itemCount: 6)
/// ```
///
/// Any skeleton shape shimmers on its own, so this works too:
///
/// ```dart
/// const SkeletonLine(widthFactor: 0.6)
/// ```
///
/// Compose your own layouts, and wrap them in one [AnimatedSkeleton] so every
/// shape sweeps in sync on a single ticker:
///
/// ```dart
/// AnimatedSkeleton(
///   child: Column(
///     crossAxisAlignment: CrossAxisAlignment.start,
///     children: const <Widget>[
///       SkeletonBox(height: 180),            // cover image
///       SizedBox(height: 16),
///       SkeletonLine(widthFactor: 0.7, height: 18),
///       SizedBox(height: 12),
///       SkeletonParagraph(lines: 3),
///     ],
///   ),
/// )
/// ```
///
/// Driven from a Cubit, swapping to the real content when it arrives:
///
/// ```dart
/// state.isLoading ? const SkeletonList() : LessonsList(state.lessons)
/// ```
///
/// ## Why a skeleton instead of a spinner
///
/// A skeleton tells the user what is coming and where it will be. Keep the
/// shapes the same size and position as the real content, and nothing jumps
/// when the data lands — the layout shift a spinner causes is what makes an
/// app feel unfinished.
///
/// ## Notes
///
/// * **One ticker per group.** An [AnimatedSkeleton] masks its whole subtree in
///   a single pass, so a list of twenty rows still animates on one controller.
///   A bare shape wraps itself in one, so it never silently sits still.
/// * **RTL comes for free.** The sweep follows the ambient [Directionality] —
///   right-to-left in Arabic, left-to-right in English — unless you pin it with
///   [AnimatedSkeleton.sweep].
/// * **Opaque blocks.** The highlight is painted *over* the shapes, so every
///   block is filled with an opaque tone blended from [ColorScheme.onSurface]
///   onto the surface it sits on. On a card or a coloured sheet, pass that
///   colour as `surfaceColor` so the blocks keep the right contrast.
/// * Honours the platform "reduce motion" setting: the blocks render as static
///   placeholders and no frame is scheduled.
library;

import 'package:flutter/material.dart';

/// Direction the highlight travels.
enum SkeletonSweep {
  /// Follows the ambient [Directionality] — the default.
  auto,

  /// Left to right, regardless of locale.
  leftToRight,

  /// Right to left, regardless of locale.
  rightToLeft,

  /// Top to bottom. Suits tall, single-column skeletons.
  topToBottom,
}

/// Sweeps one highlight across every skeleton shape below it.
///
/// Optional — shapes shimmer on their own — but wrapping a composite skeleton
/// keeps the whole group on a single ticker and in a single sweep.
class AnimatedSkeleton extends StatefulWidget {
  const AnimatedSkeleton({
    required this.child,
    super.key,
    this.enabled = true,
    this.baseColor,
    this.highlightColor,
    this.surfaceColor,
    this.duration = const Duration(milliseconds: 1400),
    this.sweep = SkeletonSweep.auto,
    this.respectReducedMotion = true,
  });

  /// The skeleton shapes to shimmer.
  final Widget child;

  /// When false, [child] is returned untouched and no ticker runs. Handy for
  /// wrapping a subtree once and toggling it from state.
  final bool enabled;

  /// Fill colour of the blocks. Defaults to [ColorScheme.onSurface] at 10%
  /// blended onto [surfaceColor].
  final Color? baseColor;

  /// Colour of the travelling band. Defaults to [ColorScheme.surface].
  final Color? highlightColor;

  /// The colour the skeleton sits on. Defaults to [ColorScheme.surface]; pass
  /// the card or sheet colour when it differs.
  final Color? surfaceColor;

  /// Time for one sweep, edge to edge.
  final Duration duration;

  /// Direction of travel.
  final SkeletonSweep sweep;

  /// When true (the default), the platform "reduce motion" setting holds the
  /// highlight still instead of sweeping it.
  final bool respectReducedMotion;

  @override
  State<AnimatedSkeleton> createState() => _AnimatedSkeletonState();
}

class _AnimatedSkeletonState extends State<AnimatedSkeleton>
    with SingleTickerProviderStateMixin {
  /// Half-width of the band, in alignment units — so the highlight covers
  /// roughly 60% of the subtree at a time.
  static const double _band = 0.6;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _positive(widget.duration),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(AnimatedSkeleton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.duration = _positive(widget.duration);
    _sync();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sync() {
    final bool animate =
        widget.enabled &&
        !(widget.respectReducedMotion &&
            MediaQuery.disableAnimationsOf(context));

    if (!animate) {
      if (_controller.isAnimating) _controller.stop();
      // Parked mid-travel: a frozen skeleton still reads as a highlighted
      // placeholder rather than a flat grey block.
      _controller.value = 0.5;
      return;
    }

    if (!_controller.isAnimating) _controller.repeat();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color surface = widget.surfaceColor ?? scheme.surface;
    final Color base = widget.baseColor ?? _defaultBase(scheme, surface);
    final Color highlight = widget.highlightColor ?? scheme.surface;
    final SkeletonSweep sweep = _resolveSweep(widget.sweep, context);

    // Disabled still publishes the scope: without it the shapes below would
    // each wrap themselves in a group of their own and shimmer anyway.
    if (!widget.enabled) {
      return _SkeletonScope(base: base, surface: surface, child: widget.child);
    }

    return _SkeletonScope(
      base: base,
      surface: surface,
      child: AnimatedBuilder(
        animation: _controller,
        // The shapes are passed as `child` so the subtree is not rebuilt on
        // every tick — only the mask above it is repainted.
        child: widget.child,
        builder: (BuildContext context, Widget? child) => ShaderMask(
          // srcATop keeps the highlight inside the shapes, so the gaps between
          // blocks stay empty instead of lighting up as one big band.
          blendMode: BlendMode.srcATop,
          shaderCallback: (Rect bounds) =>
              _shader(bounds, highlight, sweep, _controller.value),
          child: child,
        ),
      ),
    );
  }

  Shader _shader(Rect bounds, Color highlight, SkeletonSweep sweep, double t) {
    // Travel runs past both edges, so the band enters and leaves completely
    // instead of appearing out of nowhere mid-block. Moving the alignments
    // rather than the gradient stops keeps the band a constant width — stops
    // have to be clamped to 0..1, which squashes the highlight at the edges.
    final double from = -1 - _band;
    final double to = 1 + _band;
    final bool reverse = sweep == SkeletonSweep.rightToLeft;
    final double travel = reverse
        ? to + ((from - to) * t)
        : from + ((to - from) * t);

    final bool vertical = sweep == SkeletonSweep.topToBottom;

    return LinearGradient(
      begin: vertical
          ? Alignment(0, travel - _band)
          : Alignment(travel - _band, 0),
      end: vertical
          ? Alignment(0, travel + _band)
          : Alignment(travel + _band, 0),
      colors: <Color>[
        highlight.withValues(alpha: 0),
        highlight.withValues(alpha: 0.55),
        highlight.withValues(alpha: 0),
      ],
    ).createShader(bounds);
  }
}

SkeletonSweep _resolveSweep(SkeletonSweep sweep, BuildContext context) {
  if (sweep != SkeletonSweep.auto) return sweep;

  return Directionality.of(context) == TextDirection.rtl
      ? SkeletonSweep.rightToLeft
      : SkeletonSweep.leftToRight;
}

/// Blended rather than translucent: the block has to be opaque for the
/// highlight painted on top of it to show up at all.
Color _defaultBase(ColorScheme scheme, Color surface) =>
    Color.alphaBlend(scheme.onSurface.withValues(alpha: 0.10), surface);

Duration _positive(Duration duration) =>
    duration > Duration.zero ? duration : const Duration(milliseconds: 1);

/// Carries the resolved colours from an [AnimatedSkeleton] down to the shapes,
/// so every block in a group is filled identically.
class _SkeletonScope extends InheritedWidget {
  const _SkeletonScope({
    required this.base,
    required this.surface,
    required super.child,
  });

  final Color base;
  final Color surface;

  static _SkeletonScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_SkeletonScope>();

  @override
  bool updateShouldNotify(_SkeletonScope oldWidget) =>
      base != oldWidget.base || surface != oldWidget.surface;
}

/// The painted block every public shape is built from.
class _SkeletonFill extends StatelessWidget {
  const _SkeletonFill({
    this.width,
    this.height,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
    this.color,
    this.surfaceColor,
  });

  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final BoxShape shape;
  final Color? color;
  final Color? surfaceColor;

  @override
  Widget build(BuildContext context) {
    final _SkeletonScope? scope = _SkeletonScope.maybeOf(context);
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color surface = surfaceColor ?? scope?.surface ?? scheme.surface;
    final Color fill =
        color ??
        (surfaceColor == null ? scope?.base : null) ??
        _defaultBase(scheme, surface);

    return SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: fill,
          shape: shape,
          borderRadius: shape == BoxShape.circle ? null : borderRadius,
        ),
      ),
    );
  }
}

/// Wraps [child] in an [AnimatedSkeleton] unless one is already above it, so a
/// shape used on its own still shimmers and a shape inside a group does not
/// start a second ticker.
Widget _shimmer(BuildContext context, Widget child) =>
    _SkeletonScope.maybeOf(context) == null
    ? AnimatedSkeleton(child: child)
    : child;

/// A rectangular placeholder block — an image, a thumbnail, a chart, a button.
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height = 12,
    this.radius = 8,
    this.color,
    this.surfaceColor,
  });

  /// Block width. `null` fills the available width.
  final double? width;

  /// Block height.
  final double? height;

  /// Corner radius.
  final double radius;

  /// Fill colour. Defaults to the group's base tone.
  final Color? color;

  /// The colour this block sits on, when that is not [ColorScheme.surface].
  final Color? surfaceColor;

  @override
  Widget build(BuildContext context) => _shimmer(
    context,
    _SkeletonFill(
      width: width,
      height: height,
      borderRadius: BorderRadius.circular(radius),
      color: color,
      surfaceColor: surfaceColor,
    ),
  );
}

/// A single line of placeholder text, pill-shaped.
///
/// Give it a [widthFactor] rather than a [width] where you can: real text
/// rarely fills its line, and a run of equal-length bars reads as a table, not
/// a paragraph.
class SkeletonLine extends StatelessWidget {
  const SkeletonLine({
    super.key,
    this.width,
    this.widthFactor,
    this.height = 12,
    this.color,
    this.surfaceColor,
  });

  /// Absolute width. Wins over [widthFactor].
  final double? width;

  /// Width as a fraction, `0..1`, of the space available. Anchored to the
  /// leading edge, so it reads correctly in both RTL and LTR.
  final double? widthFactor;

  /// Line height — match the line height of the text it stands in for.
  final double height;

  /// Fill colour. Defaults to the group's base tone.
  final Color? color;

  /// The colour this line sits on, when that is not [ColorScheme.surface].
  final Color? surfaceColor;

  @override
  Widget build(BuildContext context) {
    final Widget line = _SkeletonFill(
      width: width,
      height: height,
      borderRadius: BorderRadius.circular(height / 2),
      color: color,
      surfaceColor: surfaceColor,
    );

    final double? factor = widthFactor;

    return _shimmer(
      context,
      width != null || factor == null
          ? line
          : FractionallySizedBox(
              widthFactor: factor.clamp(0.0, 1.0),
              alignment: AlignmentDirectional.centerStart,
              child: line,
            ),
    );
  }
}

/// A circular placeholder — an avatar, or a round icon button.
class SkeletonCircle extends StatelessWidget {
  const SkeletonCircle({
    super.key,
    this.size = 44,
    this.color,
    this.surfaceColor,
  });

  /// Diameter of the circle.
  final double size;

  /// Fill colour. Defaults to the group's base tone.
  final Color? color;

  /// The colour this circle sits on, when that is not [ColorScheme.surface].
  final Color? surfaceColor;

  @override
  Widget build(BuildContext context) => _shimmer(
    context,
    _SkeletonFill(
      width: size,
      height: size,
      shape: BoxShape.circle,
      color: color,
      surfaceColor: surfaceColor,
    ),
  );
}

/// Several lines of placeholder text, with a short last line.
class SkeletonParagraph extends StatelessWidget {
  const SkeletonParagraph({
    super.key,
    this.lines = 3,
    this.lineHeight = 12,
    this.spacing = 10,
    this.lastLineFactor = 0.55,
    this.color,
    this.surfaceColor,
  });

  /// Number of lines. Values below one render nothing.
  final int lines;

  /// Height of each line.
  final double lineHeight;

  /// Gap between lines.
  final double spacing;

  /// Width of the final line, as a fraction of the available width — what
  /// makes the block read as prose rather than as a bar chart.
  final double lastLineFactor;

  /// Fill colour. Defaults to the group's base tone.
  final Color? color;

  /// The colour this paragraph sits on, when that is not
  /// [ColorScheme.surface].
  final Color? surfaceColor;

  @override
  Widget build(BuildContext context) {
    if (lines < 1) return const SizedBox.shrink();

    return _shimmer(
      context,
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (int i = 0; i < lines; i++) ...<Widget>[
            if (i > 0) SizedBox(height: spacing),
            SkeletonLine(
              height: lineHeight,
              widthFactor: i == lines - 1 ? lastLineFactor : 1,
              color: color,
              surfaceColor: surfaceColor,
            ),
          ],
        ],
      ),
    );
  }
}

/// One placeholder list row: leading circle, stacked lines, optional trailing
/// block. The shape of most list items, and the building block of
/// [SkeletonList].
class SkeletonTile extends StatelessWidget {
  const SkeletonTile({
    super.key,
    this.leading = true,
    this.leadingSize = 44,
    this.leadingRadius,
    this.lines = 2,
    this.trailing = false,
    this.trailingWidth = 28,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.color,
    this.surfaceColor,
  });

  /// Whether to draw the leading block.
  final bool leading;

  /// Size of the leading block.
  final double leadingSize;

  /// Corner radius of the leading block. `null` draws a circle — an avatar;
  /// pass a radius for a square thumbnail.
  final double? leadingRadius;

  /// Number of text lines beside the leading block.
  final int lines;

  /// Whether to draw a trailing block — a chevron, a badge, a switch.
  final bool trailing;

  /// Width of the trailing block.
  final double trailingWidth;

  /// Padding around the row. Match the real row so nothing shifts.
  final EdgeInsetsGeometry padding;

  /// Fill colour. Defaults to the group's base tone.
  final Color? color;

  /// The colour this row sits on, when that is not [ColorScheme.surface].
  final Color? surfaceColor;

  @override
  Widget build(BuildContext context) {
    final double? radius = leadingRadius;

    return _shimmer(
      context,
      Padding(
        padding: padding,
        child: Row(
          children: <Widget>[
            if (leading) ...<Widget>[
              // A Row lays out in the reading direction, so the leading block
              // sits at the right edge in Arabic and the left in English.
              if (radius == null)
                SkeletonCircle(
                  size: leadingSize,
                  color: color,
                  surfaceColor: surfaceColor,
                )
              else
                SkeletonBox(
                  width: leadingSize,
                  height: leadingSize,
                  radius: radius,
                  color: color,
                  surfaceColor: surfaceColor,
                ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: SkeletonParagraph(
                lines: lines,
                lastLineFactor: 0.45,
                color: color,
                surfaceColor: surfaceColor,
              ),
            ),
            if (trailing) ...<Widget>[
              const SizedBox(width: 12),
              SkeletonBox(
                width: trailingWidth,
                height: trailingWidth,
                color: color,
                surfaceColor: surfaceColor,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A run of placeholder rows, sharing one sweep.
///
/// Renders a plain [Column], so it drops into a `SingleChildScrollView`, a
/// `Sliver...ToBoxAdapter` or a bare `Padding` without fighting over
/// constraints. Keep [itemCount] to roughly what fills one screen — a skeleton
/// taller than the viewport is wasted work.
///
/// Pass [itemBuilder] to use your own row shape instead of [SkeletonTile]:
///
/// ```dart
/// SkeletonList(
///   itemCount: 4,
///   itemBuilder: (BuildContext context, int index) => const SkeletonBox(
///     height: 120,
///     radius: 16,
///   ),
/// )
/// ```
class SkeletonList extends StatelessWidget {
  const SkeletonList({
    super.key,
    this.itemCount = 6,
    this.itemBuilder,
    this.separator = 8,
    this.padding = EdgeInsets.zero,
    this.surfaceColor,
  });

  /// Number of placeholder rows. Values below one render nothing.
  final int itemCount;

  /// Builds each row. Defaults to a [SkeletonTile] with an avatar and two
  /// lines.
  final IndexedWidgetBuilder? itemBuilder;

  /// Gap between rows.
  final double separator;

  /// Padding around the whole run.
  final EdgeInsetsGeometry padding;

  /// The colour this list sits on, when that is not [ColorScheme.surface].
  final Color? surfaceColor;

  @override
  Widget build(BuildContext context) {
    if (itemCount < 1) return const SizedBox.shrink();

    final IndexedWidgetBuilder builder =
        itemBuilder ??
        (BuildContext context, int index) =>
            SkeletonTile(surfaceColor: surfaceColor);

    final Widget rows = Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (int i = 0; i < itemCount; i++) ...<Widget>[
            if (i > 0) SizedBox(height: separator),
            builder(context, i),
          ],
        ],
      ),
    );

    // One AnimatedSkeleton for the whole run: every row shimmers in sync, on a
    // single ticker, in a single mask pass. Nested inside a bigger skeleton it
    // joins that group's sweep instead of starting a second one.
    return _SkeletonScope.maybeOf(context) == null
        ? AnimatedSkeleton(surfaceColor: surfaceColor, child: rows)
        : rows;
  }
}
