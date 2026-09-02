import 'package:audio_service/audio_service.dart';

class AudioTrack {
  const AudioTrack({
    required this.id,
    required this.title,
    required this.artist,
    required this.source,
    this.imageUrl,
    this.localAudioPath,
    this.localImagePath,
  });

  final String id;
  final String title;
  final String artist;

  final String source;

  final String? imageUrl;

  final String? localAudioPath;

  final String? localImagePath;

  MediaItem toMediaItem() {
    return MediaItem(
      id: id,
      title: title,
      artist: artist,
      artUri: _artUri(),
      extras: {
        'source': source,
        if (imageUrl != null && imageUrl!.isNotEmpty) 'imageUrl': imageUrl,
        if (localAudioPath != null && localAudioPath!.isNotEmpty)
          'localAudioPath': localAudioPath!,
        if (localImagePath != null && localImagePath!.isNotEmpty)
          'localImagePath': localImagePath!,
      },
    );
  }

  Uri? _artUri() {
    final local = localImagePath?.trim();
    if (local != null && local.isNotEmpty) return Uri.file(local);
    final net = imageUrl?.trim();
    if (net != null && net.isNotEmpty) return Uri.tryParse(net);
    return null;
  }

  factory AudioTrack.fromMediaItem(MediaItem item) {
    final extras = item.extras;

    final artUriStr = item.artUri?.toString();
    final imageUrl =
        (extras?['imageUrl'] as String?) ??
        (artUriStr?.startsWith('http') == true ? artUriStr : null);
    return AudioTrack(
      id: item.id,
      title: item.title,
      artist: item.artist ?? '',
      source: (extras?['source'] as String?) ?? item.id,
      imageUrl: imageUrl,
      localAudioPath: extras?['localAudioPath'] as String?,
      localImagePath: extras?['localImagePath'] as String?,
    );
  }

  AudioTrack copyWith({
    String? id,
    String? title,
    String? artist,
    String? source,
    String? imageUrl,
    String? localAudioPath,
    String? localImagePath,
  }) {
    return AudioTrack(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      source: source ?? this.source,
      imageUrl: imageUrl ?? this.imageUrl,
      localAudioPath: localAudioPath ?? this.localAudioPath,
      localImagePath: localImagePath ?? this.localImagePath,
    );
  }
}
