import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_shimmer.dart';

/// A run of identical skeleton rows, generalised from the downloads-log
/// skeleton that was already doing this correctly.
///
/// The sweep every row shares is owned by the enclosing [AppShimmerGroup], so
/// row count never multiplies tickers.
class AppSkeletonList extends StatelessWidget {
  const AppSkeletonList({
    required this.itemCount,
    required this.itemBuilder,
    super.key,
    this.padding,
    this.gap,
    this.physics = const NeverScrollableScrollPhysics(),
    this.shrinkWrap = false,
  });

  final int itemCount;

  /// Rows are interchangeable by definition, so there is no index to pass.
  final Widget Function(BuildContext context) itemBuilder;

  final EdgeInsetsGeometry? padding;
  final double? gap;

  final ScrollPhysics physics;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    return AppShimmerGroup(
      child: ListView.separated(
        padding: padding ?? EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
        physics: physics,
        shrinkWrap: shrinkWrap,
        itemCount: itemCount,
        separatorBuilder: (BuildContext context, int index) =>
            SizedBox(height: gap ?? 10.h),
        itemBuilder: (BuildContext context, int index) => itemBuilder(context),
      ),
    );
  }
}
