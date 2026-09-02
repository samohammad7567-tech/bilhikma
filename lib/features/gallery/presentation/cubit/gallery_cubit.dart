import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/error_mapper.dart';
import '../../data/models/gallery_image_model.dart';
import '../../data/repos/gallery_repo.dart';

part 'gallery_state.dart';

class GalleryCubit extends Cubit<GalleryState> {
  GalleryCubit({this.repo = const GalleryRepo()})
    : super(const GalleryState()) {
    final List<GalleryImageModel>? cached = repo.cachedImages;
    if (cached != null) {
      emit(GalleryState(status: GalleryStatus.success, images: cached));
    }

    loadImages();
  }

  final GalleryRepo repo;

  Future<void> loadImages() async {
    if (state.images == null) {
      emit(state.copyWith(status: GalleryStatus.loading));
    }

    try {
      final List<GalleryImageModel> images = await repo.fetchImages();
      if (isClosed) return;

      emit(state.copyWith(status: GalleryStatus.success, images: images));
    } catch (error) {
      if (isClosed) return;

      emit(
        state.copyWith(
          status: GalleryStatus.failure,
          errorKey: ErrorMapper.map(error),
        ),
      );
    }
  }

  Future<void> refresh() async {
    try {
      final List<GalleryImageModel> images = await repo.fetchImages(
        forceRefresh: true,
      );
      if (isClosed) return;

      emit(state.copyWith(status: GalleryStatus.success, images: images));
    } catch (error) {
      if (isClosed) return;

      emit(state.copyWith(errorKey: ErrorMapper.map(error)));
    }
  }
}
