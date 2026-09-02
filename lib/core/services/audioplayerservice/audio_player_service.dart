import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart' show rootBundle;
import 'package:just_audio_background/just_audio_background.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'audio_player_handler.dart';
import 'playback_uri_resolver.dart';

class AudioPlayerService {
  AudioPlayerService._();

  static Future<AudioPlayerHandler> init({
    required String androidNotificationChannelId,
    String androidNotificationChannelName = 'Audio Playback',
    bool androidNotificationOngoing = true,
    PlaybackUriResolver? resolver,
    String? defaultArtAsset,
  }) async {
    await JustAudioBackground.init(
      androidNotificationChannelId: androidNotificationChannelId,
      androidNotificationChannelName: androidNotificationChannelName,
      androidNotificationOngoing: androidNotificationOngoing,
    );

    final art = defaultArtAsset == null
        ? null
        : AssetNotificationArt(defaultArtAsset);

    if (art != null) unawaited(art.uri());

    return AudioPlayerHandler(resolver: resolver, defaultArtProvider: art?.uri);
  }
}

class AssetNotificationArt {
  AssetNotificationArt(this.assetPath, {String? fileName})
    : _fileName = fileName ?? p.basename(assetPath);

  final String assetPath;
  final String _fileName;
  Uri? _cached;

  Future<Uri?> uri() async {
    if (kIsWeb) return null;
    if (_cached != null) return _cached;
    final data = await rootBundle.load(assetPath);
    final dir = await getTemporaryDirectory();
    final file = File(p.join(dir.path, _fileName));
    await file.writeAsBytes(data.buffer.asUint8List(), flush: true);
    _cached = Uri.file(file.path);
    return _cached;
  }
}
