import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../security/presentation/widgets/security_watch.dart';
import '../../data/models/gallery_image_model.dart';

class GalleryViewerScreen extends StatefulWidget {
  const GalleryViewerScreen({
    required this.images,
    required this.initialIndex,
    super.key,
  });

  final List<GalleryImageModel> images;
  final int initialIndex;

  static Future<void> open(
    BuildContext context, {
    required List<GalleryImageModel> images,
    required int initialIndex,
  }) => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) =>
          GalleryViewerScreen(images: images, initialIndex: initialIndex),
    ),
  );

  @override
  State<GalleryViewerScreen> createState() => _GalleryViewerScreenState();
}

class _GalleryViewerScreenState extends State<GalleryViewerScreen>
    with SingleTickerProviderStateMixin {
  late final PageController _controller;
  late final ScrollController _thumbController;
  late final AnimationController _dragAnim;
  late int _index;

  double _dragOffset = 0;

  bool _currentPageZoomed = false;

  static const double _dismissThreshold = 130;
  static const double _dragLimit = 400;

  double get _thumbSize => 56.w;
  double get _thumbGap => 8.w;
  double get _thumbPadding => 16.w;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _controller = PageController(initialPage: _index);
    _thumbController = ScrollController();
    _dragAnim = AnimationController(
      vsync: this,
      lowerBound: -_dragLimit,
      upperBound: _dragLimit,
      duration: const Duration(milliseconds: 220),
    )..addListener(() => setState(() => _dragOffset = _dragAnim.value));

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scrollThumbsTo(_index),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _thumbController.dispose();
    _dragAnim.dispose();
    super.dispose();
  }

  List<GalleryImageModel> get _images => widget.images;

  String _fullUrl(GalleryImageModel image) =>
      image.imageUrl ?? image.gridUrl ?? '';

  String _thumbUrl(GalleryImageModel image) =>
      image.gridUrl ?? image.imageUrl ?? '';

  void _scrollThumbsTo(int index) {
    if (!_thumbController.hasClients) return;

    final double target =
        (index * (_thumbSize + _thumbGap)) -
        (_thumbController.position.viewportDimension / 2) +
        (_thumbSize / 2);

    _thumbController.animateTo(
      target.clamp(0, _thumbController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  void _goToPage(int index) {
    if (index == _index) return;

    setState(() => _index = index);
    _controller.jumpToPage(index);
    _scrollThumbsTo(index);
    HapticFeedback.selectionClick();
  }

  void _animateToPage(int index) {
    if (index == _index) return;

    _controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  void _onFilmstripScrub(DragUpdateDetails details) {
    final double contentDx =
        details.localPosition.dx + _thumbController.offset - _thumbPadding;

    _goToPage(
      (contentDx / (_thumbSize + _thumbGap)).round().clamp(
        0,
        _images.length - 1,
      ),
    );
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    if (_currentPageZoomed) return;

    setState(() {
      _dragOffset = (_dragOffset + details.delta.dy).clamp(
        -_dragLimit,
        _dragLimit,
      );
    });
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    if (_currentPageZoomed) return;

    final double? velocity = details.primaryVelocity;
    final bool flungAway = velocity != null && velocity.abs() > 800;

    if (_dragOffset.abs() > _dismissThreshold || flungAway) {
      Navigator.of(context).maybePop();
      return;
    }

    _dragAnim.value = _dragOffset;
    _dragAnim.animateTo(
      0,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double backdropOpacity = (1 - (_dragOffset.abs() / _dragLimit)).clamp(
      0.35,
      1.0,
    );

    final String? caption = _images[_index].caption;
    final bool hasFilmstrip = _images.length > 1;

    return SecurityWatch(
      screen: AppRoutes.pictures,
      child: Scaffold(
        backgroundColor: Colors.black.withValues(alpha: backdropOpacity),
        body: SafeArea(
          child: Stack(
            children: <Widget>[
              GestureDetector(
                onVerticalDragUpdate: _onVerticalDragUpdate,
                onVerticalDragEnd: _onVerticalDragEnd,
                child: Transform.translate(
                  offset: Offset(0, _dragOffset),

                  child: PhotoViewGallery.builder(
                    pageController: _controller,
                    itemCount: _images.length,
                    onPageChanged: (int index) {
                      setState(() {
                        _index = index;
                        _currentPageZoomed = false;
                      });
                      _scrollThumbsTo(index);
                    },
                    loadingBuilder:
                        (BuildContext context, ImageChunkEvent? _) =>
                            const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white54,
                              ),
                            ),
                    backgroundDecoration: const BoxDecoration(
                      color: Colors.transparent,
                    ),
                    scaleStateChangedCallback: (PhotoViewScaleState state) =>
                        setState(
                          () => _currentPageZoomed =
                              state != PhotoViewScaleState.initial,
                        ),
                    builder: (BuildContext context, int index) =>
                        PhotoViewGalleryPageOptions(
                          imageProvider: CachedNetworkImageProvider(
                            _fullUrl(_images[index]),

                            cacheKey: _images[index].fullCacheKey,
                          ),
                          minScale: PhotoViewComputedScale.contained,
                          maxScale: PhotoViewComputedScale.covered * 3,
                          initialScale: PhotoViewComputedScale.contained,
                          heroAttributes: PhotoViewHeroAttributes(
                            tag: 'gallery-photo-${_images[index].id}',
                          ),
                        ),
                  ),
                ),
              ),

              PositionedDirectional(
                top: 8.h,
                start: 8.w,
                child: IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ),

              if (caption != null && caption.isNotEmpty)
                Positioned(
                  bottom: hasFilmstrip ? 92.h : 16.h,
                  left: 16.w,
                  right: 16.w,
                  child: Text(
                    caption,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 14.sp),
                  ),
                ),

              if (hasFilmstrip)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 12.h,
                  child: SizedBox(
                    height: _thumbSize,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onHorizontalDragUpdate: _onFilmstripScrub,

                      child: Center(
                        child: SingleChildScrollView(
                          controller: _thumbController,
                          scrollDirection: Axis.horizontal,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.symmetric(
                            horizontal: _thumbPadding,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              for (
                                int i = 0;
                                i < _images.length;
                                i++
                              ) ...<Widget>[
                                if (i > 0) SizedBox(width: _thumbGap),
                                _ThumbTile(
                                  imageUrl: _thumbUrl(_images[i]),
                                  cacheKey: _images[i].gridCacheKey,
                                  size: _thumbSize,
                                  selected: i == _index,
                                  onTap: () => _animateToPage(i),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThumbTile extends StatelessWidget {
  const _ThumbTile({
    required this.imageUrl,
    required this.cacheKey,
    required this.size,
    required this.selected,
    required this.onTap,
  });

  final String imageUrl;

  final String cacheKey;
  final double size;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: selected
                ? colors.tertiary
                : Colors.white.withValues(alpha: 0.25),
            width: selected ? 2.5 : 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6.r),
          child: Opacity(
            opacity: selected ? 1 : 0.55,
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              cacheKey: cacheKey,
              fit: BoxFit.cover,

              memCacheWidth: 120,
              fadeInDuration: Duration.zero,
            ),
          ),
        ),
      ),
    );
  }
}
