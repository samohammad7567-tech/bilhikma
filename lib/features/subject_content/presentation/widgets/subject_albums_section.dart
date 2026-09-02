import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/widgets/app_empty_view.dart';
import '../../../gallery/data/models/media_album_model.dart';

class SubjectAlbumsSection extends StatelessWidget {
  const SubjectAlbumsSection({
    required this.albums,
    required this.onAlbumTap,
    super.key,
  });

  final List<MediaAlbumModel> albums;
  final ValueChanged<MediaAlbumModel> onAlbumTap;

  @override
  Widget build(BuildContext context) {
    if (albums.isEmpty) {
      return const AppEmptyView(
        icon: Icons.image_outlined,
        messageKey: 'no_pictures',
      );
    }

    return Column(
      children: <Widget>[
        for (final MediaAlbumModel album in albums)
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
            child: _AlbumRow(album: album, onTap: () => onAlbumTap(album)),
          ),
      ],
    );
  }
}

class _AlbumRow extends StatelessWidget {
  const _AlbumRow({required this.album, required this.onTap});

  final MediaAlbumModel album;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.tertiaryContainer,
      borderRadius: BorderRadius.circular(14.r),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Row(
            children: <Widget>[
              Container(
                width: 46.w,
                height: 46.w,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.photo_library_outlined,
                  size: 22.w,
                  color: colors.onPrimaryContainer,
                ),
              ),

              SizedBox(width: 12.w),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      album.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    if ((album.description ?? '').isNotEmpty) ...<Widget>[
                      SizedBox(height: 2.h),
                      Text(
                        album.description!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),

              Icon(
                Icons.arrow_forward_ios,
                size: 14.w,
                color: colors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
