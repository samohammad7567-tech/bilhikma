import 'package:flutter/material.dart';

import '../../../../core/utils/my_screen_size.dart';
import '../../../../core/utils/screen_scale.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../data/models/gallery_image_model.dart';
import 'gallery_tile.dart';

class GalleryGrid extends StatelessWidget {
  const GalleryGrid({required this.images, this.onImageTap, super.key});

  final List<GalleryImageModel> images;

  final ValueChanged<int>? onImageTap;

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const <Widget>[
          AppEmptyView(icon: Icons.image_outlined, messageKey: 'no_pictures'),
        ],
      );
    }

    final int crossAxisCount = MyScreenSize.galleryColumns(context);

    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        (16).w(context),
        (0).h(context),
        (16).w(context),
        (24).h(context),
      ),
      itemCount: images.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemBuilder: (BuildContext context, int index) {
        final GalleryImageModel image = images[index];

        return GalleryTile(
          image: image,
          onTap: onImageTap == null ? null : () => onImageTap!(index),
        );
      },
    );
  }
}
