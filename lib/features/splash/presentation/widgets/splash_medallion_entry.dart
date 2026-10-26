import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';

class SplashMedallionEntry extends StatelessWidget {
  const SplashMedallionEntry({
    required this.entry,
    required this.size,
    required this.fromStart,
    super.key,
  });

  final Animation<double> entry;
  final double size;

  /// Whether this medallion enters from the start edge. Which physical side
  /// that is follows the text direction, so the pair mirrors in LTR.
  final bool fromStart;

  @override
  Widget build(BuildContext context) {
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;
    final double towards = fromStart == isRtl ? 1 : -1;

    return AnimatedBuilder(
      animation: entry,
      builder: (BuildContext context, Widget? child) {
        final double t = entry.value;
        final double travel = size * 0.35 * (1 - t);

        return Transform.translate(
          offset: Offset(towards * travel, 0),
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
