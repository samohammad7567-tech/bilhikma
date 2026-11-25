import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

Widget wrapWithDevicePreview({required Widget child}) {
  if (!kDebugMode) return child;

  return DevicePreview(
    enabled: true,
    isToolbarVisible: true,
    storage: DevicePreviewStorage.none(),
    builder: (BuildContext context) => child,
  );
}

Locale? devicePreviewLocale(BuildContext context, Locale fallback) {
  if (!kDebugMode) return fallback;
  return DevicePreview.locale(context) ?? fallback;
}

Widget applyDevicePreviewBuilder(BuildContext context, Widget child) {
  if (!kDebugMode) return child;
  return DevicePreview.appBuilder(context, child);
}
