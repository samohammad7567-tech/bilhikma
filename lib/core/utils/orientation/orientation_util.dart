import '../my_screen_size.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void setPreferredOrientationByDevice(BuildContext context) {
  setPreferredOrientationByDeviceType(isMobile: MyScreenSize.isMobile(context));
}

void setPreferredOrientationByDeviceType({required bool isMobile}) {
  SystemChrome.setPreferredOrientations(
    getPreferredOrientationsByDeviceType(isMobile),
  );
}

List<DeviceOrientation> getPreferredOrientationsByDeviceType(bool isMobile) {
  if (isMobile) {
    return <DeviceOrientation>[DeviceOrientation.portraitUp];
  }
  return <DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ];
}
