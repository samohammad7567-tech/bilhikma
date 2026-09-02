import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../widgets/splash_brand_texts.dart';
import '../widgets/splash_mosque_background.dart';
import '../widgets/splash_ornaments_band.dart';
import 'splash_timeline.dart';

class SplashBody extends StatefulWidget {
  const SplashBody({super.key});

  @override
  State<SplashBody> createState() => _SplashBodyState();
}

class _SplashBodyState extends State<SplashBody>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: SplashTimeline.total,
  );
  late final SplashStageAnimations _stages = SplashStageAnimations(_controller);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else if (!_controller.isAnimating && _controller.value == 0) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        SplashMosqueBackground(entry: _stages.backgroundEntry),
        SafeArea(
          child: Column(
            children: [
              const Spacer(),
              SplashOrnamentsBand(
                logoPop: _stages.logoPop,
                logoSettle: _stages.logoSettle,
                ornamentsEntry: _stages.ornamentsEntry,
              ),
              SizedBox(height: 20.h),
              SplashBrandTexts(
                titleEntry: _stages.titleEntry,
                taglineEntry: _stages.taglineEntry,
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ],
    );
  }
}
