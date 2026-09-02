import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/widgets/app_section_scaffold.dart';
import '../../data/models/gallery_image_model.dart';
import '../cubit/gallery_cubit.dart';
import '../refactor/gallery_body.dart';
import 'gallery_viewer_screen.dart';
import '../../../../core/widgets/app_toast.dart';

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key, this.onImageTap});

  final void Function(List<GalleryImageModel> images, int index)? onImageTap;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GalleryCubit>(
      create: (_) => getIt<GalleryCubit>(),
      child: BlocListener<GalleryCubit, GalleryState>(
        listenWhen: (GalleryState previous, GalleryState current) =>
            current.errorKey != null && current.images != null,
        listener: _showRefreshError,
        child: AppSectionScaffold(
          title: context.tr('pictures'),
          child: Builder(
            builder: (BuildContext context) => GalleryBody(
              onImageTap: (List<GalleryImageModel> images, int index) =>
                  _openImage(context, images, index),
            ),
          ),
        ),
      ),
    );
  }

  void _openImage(
    BuildContext context,
    List<GalleryImageModel> images,
    int index,
  ) {
    final void Function(List<GalleryImageModel>, int)? onImageTap =
        this.onImageTap;
    if (onImageTap != null) {
      onImageTap(images, index);
      return;
    }

    GalleryViewerScreen.open(context, images: images, initialIndex: index);
  }

  void _showRefreshError(BuildContext context, GalleryState state) {
    final String? errorKey = state.errorKey;
    if (errorKey == null) return;

    AppToast.error(context, errorKey.tr());
  }
}
