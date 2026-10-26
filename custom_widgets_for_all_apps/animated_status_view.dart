/// The state a screen shows when there is no content: an error with a retry, an
/// empty result, or a finished action.
///
/// Drop-in and self-contained: pure Flutter, no packages and no
/// project-relative imports, so this file can be copied into any app as-is.
/// Colours and buttons come from the ambient [ThemeData], so it looks native in
/// any theme without being coupled to one. Pairs with the other
/// `animated_*.dart` widgets in this folder.
///
/// A failed request — the one case that must always offer a way out:
///
/// ```dart
/// AnimatedStatusView.error(
///   message: context.translate(state.errorKey ?? LangKeys.somethingWentWrong),
///   actionLabel: context.translate(LangKeys.retry),
///   onAction: context.read<LessonsCubit>().load,
/// )
/// ```
///
/// A successful request that simply has no rows. Not an error, and never an
/// endless spinner:
///
/// ```dart
/// AnimatedStatusView.empty(
///   icon: Icons.inbox_rounded,
///   title: context.translate(LangKeys.noLessonsTitle),
///   message: context.translate(LangKeys.noLessonsMessage),
/// )
/// ```
///
/// A finished action, with a way onward:
///
/// ```dart
/// AnimatedStatusView.success(
///   message: context.translate(LangKeys.orderPlaced),
///   actionLabel: context.translate(LangKeys.backToHome),
///   onAction: () => context.go(AppRoutes.home),
/// )
/// ```
///
/// Inside a card or a section, rather than filling the screen:
///
/// ```dart
/// AnimatedStatusView.empty(
///   icon: Icons.search_off_rounded,
///   message: context.translate(LangKeys.noResults),
///   compact: true,
/// )
/// ```
///
/// Swap your own artwork in for the icon with `illustration:` — a Lottie, an
/// SVG, an [Image]; anything that builds.
///
/// ## Notes
///
/// * **Text is never translated here.** Pass already-translated strings, so the
///   widget stays dumb and the keys stay in `LangKeys`.
/// * **It cannot overflow.** The content centres in the space available and
///   scrolls instead of overflowing when the space is short — a landscape
///   phone, a split view, or a large text-scale setting.
/// * **Height-agnostic.** Given unbounded height (inside a `Column` in a scroll
///   view) it lays out at its natural height instead of asserting.
/// * **One tween, staggered.** The icon, title, message and buttons arrive in
///   sequence off a single tween with no timers, so there is nothing to cancel
///   when the state is swapped mid-flight.
/// * Honours the platform "reduce motion" setting: the content renders
///   immediately and nothing animates.
library;

import 'package:flutter/material.dart';

/// How the state reads, which drives the icon tint.
enum AnimatedStatusTone {
  /// Informational — an empty list, a blank search. Tinted
  /// [ColorScheme.outline]; nothing has gone wrong.
  neutral,

  /// A failure. Tinted [ColorScheme.error].
  error,

  /// A completed action. Tinted [ColorScheme.tertiary].
  success,
}

/// An empty, error or success state. See the library docs above for usage.
class AnimatedStatusView extends StatelessWidget {
  /// A state with no preset tone or icon. Prefer the named constructors.
  const AnimatedStatusView({
    required this.message,
    super.key,
    this.icon,
    this.illustration,
    this.title,
    this.actionLabel,
    this.onAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.tone = AnimatedStatusTone.neutral,
    this.iconColor,
    this.iconSize = 40,
    this.padding = const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
    this.compact = false,
    this.duration = const Duration(milliseconds: 700),
    this.respectReducedMotion = true,
  }) : assert(
         onAction == null || actionLabel != null,
         'Pass actionLabel alongside onAction, or the button has nothing to say.',
       ),
       assert(
         onSecondaryAction == null || secondaryActionLabel != null,
         'Pass secondaryActionLabel alongside onSecondaryAction.',
       );

  /// A failed request. Give it an [onAction] — an error the user cannot retry
  /// is a dead end.
  const AnimatedStatusView.error({
    required this.message,
    super.key,
    this.icon = Icons.cloud_off_rounded,
    this.illustration,
    this.title,
    this.actionLabel,
    this.onAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.iconColor,
    this.iconSize = 40,
    this.padding = const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
    this.compact = false,
    this.duration = const Duration(milliseconds: 700),
    this.respectReducedMotion = true,
  }) : tone = AnimatedStatusTone.error,
       assert(
         onAction == null || actionLabel != null,
         'Pass actionLabel alongside onAction, or the button has nothing to say.',
       ),
       assert(
         onSecondaryAction == null || secondaryActionLabel != null,
         'Pass secondaryActionLabel alongside onSecondaryAction.',
       );

  /// A request that succeeded and returned nothing.
  const AnimatedStatusView.empty({
    required this.message,
    super.key,
    this.icon = Icons.inbox_rounded,
    this.illustration,
    this.title,
    this.actionLabel,
    this.onAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.iconColor,
    this.iconSize = 40,
    this.padding = const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
    this.compact = false,
    this.duration = const Duration(milliseconds: 700),
    this.respectReducedMotion = true,
  }) : tone = AnimatedStatusTone.neutral,
       assert(
         onAction == null || actionLabel != null,
         'Pass actionLabel alongside onAction, or the button has nothing to say.',
       ),
       assert(
         onSecondaryAction == null || secondaryActionLabel != null,
         'Pass secondaryActionLabel alongside onSecondaryAction.',
       );

  /// A completed action.
  const AnimatedStatusView.success({
    required this.message,
    super.key,
    this.icon = Icons.check_circle_rounded,
    this.illustration,
    this.title,
    this.actionLabel,
    this.onAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.iconColor,
    this.iconSize = 40,
    this.padding = const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
    this.compact = false,
    this.duration = const Duration(milliseconds: 700),
    this.respectReducedMotion = true,
  }) : tone = AnimatedStatusTone.success,
       assert(
         onAction == null || actionLabel != null,
         'Pass actionLabel alongside onAction, or the button has nothing to say.',
       ),
       assert(
         onSecondaryAction == null || secondaryActionLabel != null,
         'Pass secondaryActionLabel alongside onSecondaryAction.',
       );

  /// The explanation. Pass an already-translated string.
  final String message;

  /// Icon above the message. Ignored when [illustration] is given.
  final IconData? icon;

  /// Custom artwork in place of the icon — a Lottie, an SVG, an [Image].
  final Widget? illustration;

  /// Optional heading above [message], for a state that needs to name what is
  /// missing before explaining it. Pass an already-translated string.
  final String? title;

  /// Label of the primary button. Ignored unless [onAction] is given. Pass an
  /// already-translated string.
  final String? actionLabel;

  /// Primary action — the retry, or the way onward.
  final VoidCallback? onAction;

  /// Label of the secondary, lower-emphasis button. Ignored unless
  /// [onSecondaryAction] is given.
  final String? secondaryActionLabel;

  /// Secondary action — "go back", "contact support".
  final VoidCallback? onSecondaryAction;

  /// How the state reads. Set by the named constructors.
  final AnimatedStatusTone tone;

  /// Icon tint. Defaults to the [tone] colour.
  final Color? iconColor;

  /// Icon glyph size. The halo around it is sized from this.
  final double iconSize;

  /// Padding around the content.
  final EdgeInsetsGeometry padding;

  /// When true, lays out at its natural height with tighter spacing, for use
  /// inside a card or a section rather than as a whole screen.
  final bool compact;

  /// Total length of the staggered entrance.
  final Duration duration;

  /// When true (the default), the platform "reduce motion" setting renders the
  /// content immediately instead of animating it in.
  final bool respectReducedMotion;

  @override
  Widget build(BuildContext context) {
    final bool animate =
        !(respectReducedMotion && MediaQuery.disableAnimationsOf(context));

    final Widget content = Padding(
      padding: padding,
      child: _AnimatedStatusContent(
        view: this,
        duration: animate ? duration : Duration.zero,
      ),
    );

    if (compact) return content;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // Unbounded height means it is already inside something scrollable —
        // laying out naturally is correct, and a nested scroll view would
        // assert.
        if (!constraints.hasBoundedHeight) return content;

        // Centred in the space available, but scrollable rather than
        // overflowing when that space is short: landscape, a split view, or a
        // large text-scale setting.
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(child: content),
          ),
        );
      },
    );
  }
}

class _AnimatedStatusContent extends StatelessWidget {
  const _AnimatedStatusContent({required this.view, required this.duration});

  final AnimatedStatusView view;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final Color tint = view.iconColor ?? _toneColor(scheme, view.tone);
    final double gap = view.compact ? 8 : 12;

    final String? title = view.title;
    final String? actionLabel = view.actionLabel;
    final String? secondaryActionLabel = view.secondaryActionLabel;
    // A label is asserted alongside its callback, so a missing one is caught in
    // debug; in release the button is dropped rather than rendered blank.
    final VoidCallback? onAction = actionLabel == null ? null : view.onAction;
    final VoidCallback? onSecondaryAction = secondaryActionLabel == null
        ? null
        : view.onSecondaryAction;

    // Each child declares the slice of the tween it arrives on, so the parts
    // land in reading order off a single animation.
    final List<(double, Widget)> steps = <(double, Widget)>[
      (0, _mark(context, tint)),
      if (title != null)
        (
          0.12,
          Padding(
            padding: EdgeInsets.only(top: gap + 4),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      (
        0.2,
        Padding(
          padding: EdgeInsets.only(top: gap),
          child: Text(
            view.message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
        ),
      ),
      if (onAction != null)
        (
          0.3,
          Padding(
            padding: EdgeInsets.only(top: view.compact ? 16 : 24),
            child: FilledButton(onPressed: onAction, child: Text(actionLabel!)),
          ),
        ),
      if (onSecondaryAction != null)
        (
          0.38,
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TextButton(
              onPressed: onSecondaryAction,
              child: Text(secondaryActionLabel!),
            ),
          ),
        ),
    ];

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: duration,
      curve: Curves.easeOut,
      builder: (BuildContext context, double t, Widget? child) => Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (final (double start, Widget step) in steps)
            _reveal(t, start, step),
        ],
      ),
    );
  }

  /// The icon in a soft halo of its own tint — enough shape to anchor the
  /// column without needing artwork.
  Widget _mark(BuildContext context, Color tint) {
    final Widget? illustration = view.illustration;
    if (illustration != null) return illustration;

    final IconData? icon = view.icon;
    if (icon == null) return const SizedBox.shrink();

    final double halo = view.iconSize * 2;

    return Container(
      width: halo,
      height: halo,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.10),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: view.iconSize, color: tint),
    );
  }

  /// Fades and lifts one step over its slice of the tween.
  Widget _reveal(double t, double start, Widget child) {
    const double span = 0.55;
    final double v = Curves.easeOut.transform(
      ((t - start) / span).clamp(0.0, 1.0),
    );

    return Opacity(
      opacity: v,
      child: Transform.translate(offset: Offset(0, (1 - v) * 10), child: child),
    );
  }
}

Color _toneColor(ColorScheme scheme, AnimatedStatusTone tone) => switch (tone) {
  AnimatedStatusTone.neutral => scheme.outline,
  AnimatedStatusTone.error => scheme.error,
  AnimatedStatusTone.success => scheme.tertiary,
};
