part of 'gallery_cubit.dart';

enum GalleryStatus { initial, loading, success, failure }

final class GalleryState {
  const GalleryState({
    this.status = GalleryStatus.initial,
    this.images,
    this.errorKey,
  });

  final GalleryStatus status;
  final List<GalleryImageModel>? images;
  final String? errorKey;

  bool get isLoading => status == GalleryStatus.loading;
  bool get isFirstLoad => isLoading && images == null;

  bool get hasFailed => status == GalleryStatus.failure && images == null;

  List<GalleryImageModel> get visibleImages =>
      images ?? const <GalleryImageModel>[];
  GalleryState copyWith({
    GalleryStatus? status,
    List<GalleryImageModel>? images,
    String? errorKey,
  }) => GalleryState(
    status: status ?? this.status,
    images: images ?? this.images,
    errorKey: errorKey,
  );
}
