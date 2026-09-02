import 'package:share_plus/share_plus.dart';

import 'video_item.dart';
import 'video_player_options.dart';

class VideoShare {
  VideoShare._();

  static bool isAvailable(VideoItem item, FloatingVideoOptions options) =>
      options.onShare != null ||
      (item.shareText != null && item.shareText!.isNotEmpty);

  static void send(VideoItem item, FloatingVideoOptions options) {
    final void Function(VideoItem item)? onShare = options.onShare;
    if (onShare != null) {
      onShare(item);
      return;
    }

    final String? text = item.shareText;
    if (text != null && text.isNotEmpty) {
      SharePlus.instance.share(ShareParams(text: text));
    }
  }
}
