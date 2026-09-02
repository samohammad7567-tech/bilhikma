import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
      itemCount: images.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12.h,
        crossAxisSpacing: 12.w,
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
