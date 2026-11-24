import 'package:flutter/material.dart';

import '../../../../core/themes/app_theme.dart';
import 'test_intro_card.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class TestIntroCardRow extends StatelessWidget {
  const TestIntroCardRow({required this.row, super.key});

  final TestIntroRow row;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: (12).h(context)),
      child: Row(
        children: <Widget>[
          Container(
            width: (40).w(context),
            height: (40).h(context),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.secondary,
              borderRadius: BorderRadius.circular((10).r(context)),
            ),
            child: Icon(row.icon, size: (20).r(context), color: colors.onSecondary),
          ),
          SizedBox(width: (12).w(context)),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  row.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.styles(context).labelSmall,
                ),

                SizedBox(height: (2).h(context)),

                Text(row.value, style: AppTheme.styles(context).labelStrong),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
