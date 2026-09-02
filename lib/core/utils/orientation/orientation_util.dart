import '../screen_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void setPreferredOrientationByDevice(BuildContext context) {
  setPreferredOrientationByDeviceType(isMobile: ScreenSize.isMobile(context));
}

void setPreferredOrientationByDeviceType({required bool isMobile}) {
  if (isMobile) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  } else {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }
}

List<DeviceOrientation> getPreferredOrientationsByDeviceType(bool isMobile) {
  if (isMobile) {
    return [DeviceOrientation.portraitUp];
  }
  return [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight];
}
