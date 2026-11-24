import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/themes/app_theme.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class SectionViewAllButton extends StatelessWidget {
  const SectionViewAllButton({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular((6).r(context));
    final Color accent = Theme.of(context).colorScheme.onSurfaceVariant;

    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      child: InkWell(
        onTap: onPressed,
        borderRadius: radius,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: (12).w(context), vertical: (6).h(context)),
          decoration: BoxDecoration(
            border: Border.all(color: accent),
            borderRadius: radius,
          ),
          child: Text(
            'view_all'.tr(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.styles(context).labelMedium.copyWith(color: accent),
          ),
        ),
      ),
    );
  }
}
