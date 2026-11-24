import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/localization/lang_keys.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class LivePlayerBadge extends StatelessWidget {
  const LivePlayerBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: (8).w(context), vertical: (4).h(context)),
      decoration: BoxDecoration(
        color: colors.error,
        borderRadius: BorderRadius.circular((6).r(context)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: (6).w(context),
            height: (6).h(context),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: (6).w(context)),
          Text(
            LangKeys.liveNow.tr(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colors.onError,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
