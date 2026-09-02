import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';

class SplashMedallionEntry extends StatelessWidget {
  const SplashMedallionEntry({
    required this.entry,
    required this.size,
    required this.fromLeft,
    super.key,
  });

  final Animation<double> entry;
  final double size;
  final bool fromLeft;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: entry,
      builder: (BuildContext context, Widget? child) {
        final double t = entry.value;
        final double travel = size * 0.35 * (1 - t);

        return Transform.translate(
          offset: Offset(fromLeft ? -travel : travel, 0),
          child: Opacity(opacity: t.clamp(0.0, 1.0), child: child),
        );
      },
      child: SizedBox(
        width: size,
        height: size,
        child: Image.asset(AppAssets.assetsLogoOrnament, fit: BoxFit.cover),
      ),
    );
  }
}
