import 'dart:io';

import 'audio_track.dart';

abstract class PlaybackUriResolver {
  Future<Uri> resolve(AudioTrack track);
}

class DefaultPlaybackUriResolver implements PlaybackUriResolver {
  const DefaultPlaybackUriResolver();

  @override
  Future<Uri> resolve(AudioTrack track) async {
    final source = track.source.trim();

    if (source.startsWith('assets/')) {
      return Uri.parse('asset:///$source');
    }

    final local = track.localAudioPath?.trim();
    if (local != null && local.isNotEmpty) {
      final f = File(local);
      if (await f.exists()) return Uri.file(f.path);
    }

    if (source.startsWith('http://') || source.startsWith('https://')) {
      return Uri.parse(source);
    }

    if (source.isNotEmpty && File(source).existsSync()) {
      return Uri.file(source);
    }
    return Uri.parse(source);
  }
}
