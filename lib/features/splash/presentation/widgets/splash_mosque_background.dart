import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';

class SplashMosqueBackground extends StatelessWidget {
  const SplashMosqueBackground({super.key, required this.entry});
  final Animation<double> entry;

  static const double _opacity = 0.8;
  static const double _travel = 0.12;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: AnimatedBuilder(
        animation: entry,
        builder: (BuildContext context, Widget? child) {
          final double t = entry.value.clamp(0.0, 1.0);

          return FractionalTranslation(
            translation: Offset(0, _travel * (1 - t)),
            child: Opacity(opacity: _opacity * t, child: child),
          );
        },
        child: Image.asset(
          AppAssets.assetsBackgroundImageLogo,
          width: double.infinity,
          fit: BoxFit.fitWidth,
          alignment: Alignment.bottomCenter,
        ),
      ),
    );
  }
}
