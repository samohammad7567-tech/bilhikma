import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/enums/notification_kind_enum.dart';
import '../../../../core/themes/notification_kind_accents.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class NotificationKindChip extends StatelessWidget {
  const NotificationKindChip({required this.kind, super.key});

  final NotificationKind kind;

  @override
  Widget build(BuildContext context) {
    final Color accent = NotificationKindAccents.of(context, kind);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: (8).w(context), vertical: (3).h(context)),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: NotificationKindAccents.chipTint),
        borderRadius: BorderRadius.circular((20).r(context)),
      ),
      child: Text(
        kind.labelKey.tr(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: accent,
          fontSize: (9).sp(context),
          fontWeight: FontWeight.w700,
          height: 1.3.h(context),
        ),
      ),
    );
  }
}
