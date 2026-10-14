import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photo_view/photo_view.dart';

import 'drag_dismiss_backdrop.dart';

/// Reusable full screen viewer for a single network image: pinch and double tap
/// to zoom, drag to dismiss, nothing cropped.
///
/// Open it from anywhere with [AppImageViewer.open], passing the same url the
/// thumbnail used so the bytes come straight from the cache. Pass [heroTag] and
/// wrap the thumbnail in a `Hero` with the same tag to animate between them.
class AppImageViewer extends StatefulWidget {
  const AppImageViewer({
    required this.url,
    super.key,
    this.cacheKey,
    this.heroTag,
    this.caption,
  });

  final String url;
  final String? cacheKey;
  final Object? heroTag;
  final String? caption;

  static Future<void> open(
    BuildContext context, {
    required String url,
    String? cacheKey,
    Object? heroTag,
    String? caption,
  }) {
    if (url.isEmpty) return Future<void>.value();

    return Navigator.of(context, rootNavigator: true).push<void>(
      PageRouteBuilder<void>(
        opaque: false,
        barrierColor: Colors.transparent,
        transitionDuration: const Duration(milliseconds: 220),
        reverseTransitionDuration: const Duration(milliseconds: 180),
        pageBuilder: (_, _, _) => AppImageViewer(
          url: url,
          cacheKey: cacheKey,
          heroTag: heroTag,
          caption: caption,
        ),
        transitionsBuilder: (_, Animation<double> animation, _, Widget child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  State<AppImageViewer> createState() => _AppImageViewerState();
}

class _AppImageViewerState extends State<AppImageViewer> {
  bool _zoomed = false;

  @override
  Widget build(BuildContext context) {
    final String? caption = widget.caption;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: DragDismissBackdrop(
              enabled: !_zoomed,
              child: PhotoView(
                imageProvider: CachedNetworkImageProvider(
                  widget.url,
                  cacheKey: widget.cacheKey,
                ),
                backgroundDecoration: const BoxDecoration(
                  color: Colors.transparent,
                ),
                minScale: PhotoViewComputedScale.contained,
                initialScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 3,
                heroAttributes: widget.heroTag == null
                    ? null
                    : PhotoViewHeroAttributes(tag: widget.heroTag!),
                scaleStateChangedCallback: (PhotoViewScaleState state) =>
                    setState(
                      () => _zoomed = state != PhotoViewScaleState.initial,
                    ),
                loadingBuilder: (_, _) => const Center(
                  child: CircularProgressIndicator(color: Colors.white54),
                ),
                errorBuilder: (_, _, _) => _error(),
              ),
            ),
          ),

          SafeArea(
            child: Stack(
              children: <Widget>[
                PositionedDirectional(
                  top: 8.h,
                  start: 8.w,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    tooltip: 'close'.tr(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ),

                if (caption != null && caption.isNotEmpty)
                  PositionedDirectional(
                    bottom: 16.h,
                    start: 16.w,
                    end: 16.w,
                    child: Text(
                      caption,
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.white70, fontSize: 14.sp),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _error() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(Icons.broken_image_outlined, color: Colors.white54, size: 44.r),

        SizedBox(height: 10.h),

        Text(
          'something_went_wrong'.tr(),
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70, fontSize: 14.sp),
        ),
      ],
    ),
  );
}
