/// An image that shows a placeholder while it loads, fades in when it arrives,
/// and falls back to something sensible when it fails.
///
/// Drop-in and self-contained: pure Flutter, no packages and no
/// project-relative imports, so this file can be copied into any app as-is.
/// Colours fall back to the ambient [ColorScheme], so it looks native in any
/// theme without being coupled to one. Pairs with the other
/// `animated_*.dart` widgets in this folder.
///
/// ```dart
/// AnimatedImage.network(lesson.coverUrl, aspectRatio: 16 / 9, radius: 16)
/// ```
///
/// A fixed-size avatar:
///
/// ```dart
/// AnimatedImage.network(
///   user.photoUrl,
///   width: 48,
///   height: 48,
///   radius: 24,
///   errorChild: const Icon(Icons.person_rounded),
/// )
/// ```
///
/// With the shimmer from `animated_skeleton.dart` as the placeholder, when both
/// files are in the project:
///
/// ```dart
/// AnimatedImage.network(
///   book.coverUrl,
///   aspectRatio: 3 / 4,
///   radius: 12,
///   placeholder: const SkeletonBox(radius: 12),
/// )
/// ```
///
/// Any [ImageProvider] works — the unnamed constructor takes one directly, so a
/// cached-network-image provider or a `MemoryImage` drops straight in:
///
/// ```dart
/// AnimatedImage(image: FileImage(downloadedCover), aspectRatio: 1)
/// ```
///
/// ## Notes
///
/// * **Reserve the space.** Give it a [AnimatedImage.width] and
///   [AnimatedImage.height], an [AnimatedImage.aspectRatio], or a parent that
///   constrains it. Without one the placeholder has no size of its own and the
///   layout jumps when the image lands — the thing a placeholder exists to
///   prevent.
/// * **Cached images do not flash.** A frame that was already decoded is
///   painted immediately; only a genuine load fades in.
/// * **Decode at display size.** Pass [AnimatedImage.cacheWidth] for anything
///   you render small — a 3000px photo in a 48px avatar costs the same memory
///   as a full-screen one until you do.
/// * **A failed image is not an error state.** It falls back in place rather
///   than taking over the screen; use `animated_status_view.dart` when the
///   whole request failed.
/// * For a download whose progress you actually want to show, use
///   `AnimatedLoader(progress: ...)` from `animated_loader.dart` — an image
///   byte count is not worth a progress bar.
library;

import 'package:flutter/material.dart';

/// An image with a placeholder, a fade-in and an error fallback.
class AnimatedImage extends StatelessWidget {
  /// Takes any [ImageProvider] — including one from an image-caching package.
  const AnimatedImage({
    required this.image,
    super.key,
    this.width,
    this.height,
    this.aspectRatio,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.radius = 0,
    this.placeholder,
    this.errorChild,
    this.backgroundColor,
    this.fadeDuration = const Duration(milliseconds: 300),
    this.cacheWidth,
    this.cacheHeight,
    this.filterQuality = FilterQuality.medium,
    this.semanticLabel,
    this.respectReducedMotion = true,
  });

  /// Loads from the network. An empty [url] renders the error fallback without
  /// attempting a request.
  AnimatedImage.network(
    String url, {
    super.key,
    Map<String, String>? headers,
    this.width,
    this.height,
    this.aspectRatio,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.radius = 0,
    this.placeholder,
    this.errorChild,
    this.backgroundColor,
    this.fadeDuration = const Duration(milliseconds: 300),
    this.cacheWidth,
    this.cacheHeight,
    this.filterQuality = FilterQuality.medium,
    this.semanticLabel,
    this.respectReducedMotion = true,
  }) : image = url.trim().isEmpty ? null : NetworkImage(url, headers: headers);

  /// Loads from the asset bundle.
  AnimatedImage.asset(
    String name, {
    super.key,
    this.width,
    this.height,
    this.aspectRatio,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.radius = 0,
    this.placeholder,
    this.errorChild,
    this.backgroundColor,
    this.fadeDuration = const Duration(milliseconds: 300),
    this.cacheWidth,
    this.cacheHeight,
    this.filterQuality = FilterQuality.medium,
    this.semanticLabel,
    this.respectReducedMotion = true,
  }) : image = name.trim().isEmpty ? null : AssetImage(name);

  /// Where the bytes come from. `null` — an empty URL or asset name — renders
  /// the error fallback, so a missing field needs no guard at the call site.
  final ImageProvider? image;

  /// Fixed width, if any.
  final double? width;

  /// Fixed height, if any.
  final double? height;

  /// Width-to-height ratio to lay out at. The clean way to reserve space for a
  /// cover or a thumbnail whose height you do not want to hard-code.
  final double? aspectRatio;

  /// How the image fills its box. [BoxFit.cover] by default — the right choice
  /// for photos, and the reason [aspectRatio] matters.
  final BoxFit fit;

  /// How the image is positioned inside its box.
  final AlignmentGeometry alignment;

  /// Corner radius applied to the image, the placeholder and the fallback
  /// alike, so the shape never changes mid-load.
  final double radius;

  /// Shown until the first frame is decoded. Defaults to a flat tinted block;
  /// pass `SkeletonBox()` from `animated_skeleton.dart` for a shimmer.
  final Widget? placeholder;

  /// Shown when the image cannot be loaded. Defaults to a muted icon on the
  /// placeholder tint. An [Icon] is laid out centred and scaled down.
  final Widget? errorChild;

  /// Tint behind the placeholder and the fallback. Defaults to
  /// [ColorScheme.onSurface] at 8%, blended onto [ColorScheme.surface].
  final Color? backgroundColor;

  /// Cross-fade length once the first frame is ready.
  final Duration fadeDuration;

  /// Decode width. Pass the pixel width you actually render at.
  final int? cacheWidth;

  /// Decode height.
  final int? cacheHeight;

  /// Sampling quality. [FilterQuality.medium] is the right default for a photo
  /// being scaled down; drop to [FilterQuality.low] for anything drawn at or
  /// near its native size.
  final FilterQuality filterQuality;

  /// Screen-reader description. Pass an already-translated string, or leave it
  /// null for a decorative image.
  final String? semanticLabel;

  /// When true (the default), the platform "reduce motion" setting swaps the
  /// image in instantly instead of fading it.
  final bool respectReducedMotion;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color background =
        backgroundColor ??
        Color.alphaBlend(
          scheme.onSurface.withValues(alpha: 0.08),
          scheme.surface,
        );

    final Duration fade =
        respectReducedMotion && MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : fadeDuration;

    final ImageProvider? provider = image;

    Widget result = provider == null
        ? _fallback(context, background)
        : Image(
            // The generic Image constructor has no cacheWidth of its own: the
            // decode size belongs to the provider, which is exactly what
            // Image.network does internally.
            image: ResizeImage.resizeIfNeeded(
              cacheWidth,
              cacheHeight,
              provider,
            ),
            width: width,
            height: height,
            fit: fit,
            alignment: alignment,
            filterQuality: filterQuality,
            semanticLabel: semanticLabel,
            // A rebuild with the same provider keeps showing the old frame
            // instead of blinking back to the placeholder.
            gaplessPlayback: true,
            frameBuilder:
                (
                  BuildContext context,
                  Widget child,
                  int? frame,
                  bool wasSynchronouslyLoaded,
                ) {
                  // Already decoded — painting it straight away is what keeps
                  // a scrolled-back-to list from flashing.
                  if (wasSynchronouslyLoaded) return child;

                  return AnimatedSwitcher(
                    duration: fade,
                    // Cross-fades placeholder to image, then drops the
                    // placeholder from the tree once the fade is done.
                    child: frame == null
                        ? _placeholder(context, background)
                        : child,
                  );
                },
            errorBuilder:
                (BuildContext context, Object error, StackTrace? stack) =>
                    _fallback(context, background),
          );

    final double? ratio = aspectRatio;

    if (ratio != null && ratio > 0) {
      result = AspectRatio(aspectRatio: ratio, child: result);
    }

    if (radius > 0) {
      result = ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: result,
      );
    }

    return result;
  }

  Widget _placeholder(BuildContext context, Color background) {
    // Sized so it fills whatever space the image will take: the fixed size if
    // there is one, otherwise the box the parent or the aspect ratio gives it.
    return SizedBox(
      key: const ValueKey<String>('placeholder'),
      width: width,
      height: height,
      child: placeholder ?? ColoredBox(color: background),
    );
  }

  Widget _fallback(BuildContext context, Color background) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Widget child = errorChild ?? const Icon(Icons.broken_image_rounded);

    return SizedBox(
      key: const ValueKey<String>('fallback'),
      width: width,
      height: height,
      child: ColoredBox(
        color: background,
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: IconTheme.merge(
              data: IconThemeData(color: scheme.outline, size: 28),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
