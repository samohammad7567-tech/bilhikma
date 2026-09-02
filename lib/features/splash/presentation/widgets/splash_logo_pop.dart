import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_assets.dart';

class SplashLogoPop extends StatelessWidget {
  const SplashLogoPop({required this.pop, required this.settle, super.key});

  final Animation<double> pop;
  final Animation<double> settle;

  static const double _settleTravel = 22;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge(<Animation<double>>[pop, settle]),
      builder: (BuildContext context, Widget? child) {
        final double scale = pop.value.clamp(0.0, 1.2);
        final double opacity = pop.value.clamp(0.0, 1.0);
        final double settled = settle.value.clamp(0.0, 1.0);

        return Transform.translate(
          offset: Offset(0, _settleTravel * (1 - settled)),
          child: Transform.scale(
            scale: scale,
            child: Opacity(opacity: opacity, child: child),
          ),
        );
      },
      child: SvgPicture.asset(AppAssets.assetsLogoText, fit: BoxFit.contain),
    );
  }
}
