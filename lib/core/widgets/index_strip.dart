import 'package:flutter/material.dart';

import '../themes/app_theme.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class IndexStrip extends StatelessWidget {
  const IndexStrip({required this.order, super.key});

  final int order;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minWidth: 26),
      color: Theme.of(context).colorScheme.tertiary,
      alignment: Alignment.topCenter,
      padding: EdgeInsets.only(top: (10).h(context), left: (4).w(context), right: (4).w(context)),
      child: Text(
        '$order',
        maxLines: 1,
        style: AppTheme.styles(
          context,
        ).rowTitle.copyWith(color: Theme.of(context).colorScheme.onTertiary),
      ),
    );
  }
}
