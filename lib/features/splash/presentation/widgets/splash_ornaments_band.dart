import 'package:flutter/material.dart';

import 'package:bilhikma/core/utils/my_screen_size.dart';
import 'splash_logo_pop.dart';
import 'splash_medallion_entry.dart';

class SplashOrnamentsBand extends StatelessWidget {
  const SplashOrnamentsBand({
    super.key,
    required this.logoPop,
    required this.logoSettle,
    required this.ornamentsEntry,
  });
  final Animation<double> logoPop;
  final Animation<double> logoSettle;
  final Animation<double> ornamentsEntry;

  @override
  Widget build(BuildContext context) {
    final double medallionSize = MyScreenSize.widthFraction(context, 0.72);
    final double overflow = medallionSize * 0.65;

    return SizedBox(
      height: medallionSize,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Positioned(
            left: -overflow,
            child: SplashMedallionEntry(
              entry: ornamentsEntry,
              size: medallionSize,
              fromLeft: true,
            ),
          ),
          Positioned(
            right: -overflow,
            child: SplashMedallionEntry(
              entry: ornamentsEntry,
              size: medallionSize,
              fromLeft: false,
            ),
          ),

          Positioned(
            bottom: 0,
            child: SplashLogoPop(pop: logoPop, settle: logoSettle),
          ),
        ],
      ),
    );
  }
}
