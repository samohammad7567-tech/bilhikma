import 'package:flutter/material.dart';

import '../../../../core/widgets/app_empty_view.dart';
import '../../../gallery/data/models/media_album_model.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

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
            padding: EdgeInsets.fromLTRB((16).w(context), (0).h(context), (16).w(context), (12).h(context)),
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
      borderRadius: BorderRadius.circular((14).r(context)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all((12).r(context)),
          child: Row(
            children: <Widget>[
              Container(
                width: (46).w(context),
                height: (46).h(context),
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular((10).r(context)),
                ),
                child: Icon(
                  Icons.photo_library_outlined,
                  size: (22).r(context),
                  color: colors.onPrimaryContainer,
                ),
              ),

              SizedBox(width: (12).w(context)),

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
                      SizedBox(height: (2).h(context)),
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
                size: (14).r(context),
                color: colors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
