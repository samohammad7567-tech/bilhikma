import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_state_switcher.dart';
import '../../data/models/gallery_image_model.dart';
import '../cubit/gallery_cubit.dart';
import '../widgets/gallery_grid.dart';
import '../widgets/gallery_skeleton.dart';

class GalleryBody extends StatelessWidget {
  const GalleryBody({super.key, this.onImageTap});

  final void Function(List<GalleryImageModel> images, int index)? onImageTap;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GalleryCubit, GalleryState>(
      builder: (BuildContext context, GalleryState state) =>
          AppStateSwitcher(child: _content(context, state)),
    );
  }

  Widget _content(BuildContext context, GalleryState state) {
    if (state.isFirstLoad) return const GallerySkeleton();

    if (state.hasFailed) {
      return AppErrorView(
        errorKey: state.errorKey,
        onRetry: context.read<GalleryCubit>().loadImages,
      );
    }

    final List<GalleryImageModel> images = state.visibleImages;
    final void Function(List<GalleryImageModel>, int)? onImageTap =
        this.onImageTap;

    return RefreshIndicator(
      onRefresh: context.read<GalleryCubit>().refresh,
      child: GalleryGrid(
        images: images,
        onImageTap: onImageTap == null
            ? null
            : (int index) => onImageTap(images, index),
      ),
    );
  }
}
