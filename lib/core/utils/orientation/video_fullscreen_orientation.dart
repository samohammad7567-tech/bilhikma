import 'package:flutter/services.dart';

import 'orientation_util.dart';

class VideoFullscreenOrientation {
  VideoFullscreenOrientation._();

  static Future<void> enter() async {
    await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  static Future<void> restore({required bool isMobile}) async {
    await SystemChrome.setPreferredOrientations(
      getPreferredOrientationsByDeviceType(isMobile),
    );
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
  }
}
