import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_assets.dart';

/// Pops the logo in, turns it in 3D (double sided, perspective + edge shading)
/// for a fixed number of revolutions, then parks it dead flat and facing the
/// camera. The spin is finite and decelerating, so the logo is readable and
/// perfectly still for the rest of the splash, well before login opens.
class SplashLogoPop extends StatefulWidget {
  const SplashLogoPop({required this.pop, required this.settle, super.key});

  final Animation<double> pop;
  final Animation<double> settle;

  @override
  State<SplashLogoPop> createState() => _SplashLogoPopState();
}

class _SplashLogoPopState extends State<SplashLogoPop>
    with SingleTickerProviderStateMixin {
  static const double _settleTravel = 22;

  /// Two revolutions over 2.8s, against a 4.5s splash: the logo comes to rest
  /// ~1.7s before navigation, so the user reads it standing still.
  static const Duration _spinDuration = Duration(milliseconds: 2800);
  static const double _turns = 2;

  /// Camera depth — small value keeps the perspective believable, not fisheye.
  static const double _perspective = 0.0014;
  static const double _tiltX = 0.10;
  static const double _edgeShade = 0.38;

  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: _spinDuration,
  );

  late final Animation<double> _progress = _spin.drive(
    CurveTween(curve: Curves.easeOutCubic),
  );

  @override
  void initState() {
    super.initState();
    _spin.forward();
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge(<Listenable>[
        widget.pop,
        widget.settle,
        _spin,
      ]),
      builder: (BuildContext context, Widget? child) {
        final double scale = widget.pop.value.clamp(0.0, 1.2);
        final double opacity = widget.pop.value.clamp(0.0, 1.0);
        final double settled = widget.settle.value.clamp(0.0, 1.0);
        final double spun = _progress.value.clamp(0.0, 1.0);

        return Transform.translate(
          offset: Offset(0, _settleTravel * (1 - settled)),
          child: Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: opacity,
              // Once parked, drop the 3D layers entirely so the final logo is
              // rendered crisp and unshaded.
              child: spun >= 1 ? child : _turning(spun, child),
            ),
          ),
        );
      },
      child: SvgPicture.asset(AppAssets.assetsLogoText, fit: BoxFit.contain),
    );
  }

  Widget _turning(double spun, Widget? child) {
    final double turn = spun * _turns * 2 * math.pi;
    final double facing = math.cos(turn);

    // 0 when the logo faces the camera, 1 when it is edge on.
    final double edgeOn = 1 - facing.abs();

    final Matrix4 matrix = Matrix4.identity()
      ..setEntry(3, 2, _perspective)
      // Tilt fades out with the spin, so the resting logo is flat on.
      ..rotateX(_tiltX * (1 - edgeOn) * (1 - spun))
      ..rotateY(turn);

    // Mirror the back half so the logo stays readable on both faces.
    if (facing < 0) {
      matrix.multiply(Matrix4.diagonal3Values(-1, 1, 1));
    }

    return Transform(
      transform: matrix,
      alignment: Alignment.center,
      filterQuality: FilterQuality.high,
      child: ColorFiltered(
        colorFilter: ColorFilter.mode(
          Colors.black.withValues(alpha: _edgeShade * edgeOn),
          BlendMode.srcATop,
        ),
        child: child,
      ),
    );
  }
}
