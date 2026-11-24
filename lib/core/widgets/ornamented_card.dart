import 'package:flutter/material.dart';

import '../constants/app_assets.dart';
import 'card_ornament.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class OrnamentedCard extends StatelessWidget {
  const OrnamentedCard({
    required this.child,
    super.key,
    this.padding,
    this.radius,
    this.leading = AppAssets.assetsOrnamentRight,
    this.trailing = AppAssets.assetsOrnamentBottomLeft,
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? radius;
  final String? leading;
  final String? trailing;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(radius ?? 12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: OrnamentBackdrop(leading: leading, trailing: trailing),
          ),
          Padding(
            padding:
                padding ??
                EdgeInsets.symmetric(horizontal: (16).w(context), vertical: (12).h(context)),
            child: child,
          ),
        ],
      ),
    );
  }
}

class OrnamentBackdrop extends StatelessWidget {
  const OrnamentBackdrop({
    super.key,
    this.leading = AppAssets.assetsOrnamentRight,
    this.trailing = AppAssets.assetsOrnamentBottomLeft,
  });

  final String? leading;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final String? leading = this.leading;
    final String? trailing = this.trailing;

    return IgnorePointer(
      child: Stack(
        children: <Widget>[
          if (leading != null)
            CardOrnament(asset: leading, alignment: Alignment.bottomRight),
          if (trailing != null)
            CardOrnament(asset: trailing, alignment: Alignment.centerLeft),
        ],
      ),
    );
  }
}
