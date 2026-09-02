import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppScreenUtil {
  AppScreenUtil._();
  static const Size designSize = Size(412, 917);

  static const bool minTextAdapt = true;
  static const bool splitScreenMode = true;
  static void ensureConfigured() {
    try {
      ScreenUtil().screenWidth;
    } on Error {
      ScreenUtil.configure(
        data: const MediaQueryData(size: designSize),
        designSize: designSize,
        minTextAdapt: minTextAdapt,
        splitScreenMode: splitScreenMode,
      );
    }
  }
}
