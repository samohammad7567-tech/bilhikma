import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/themes/app_theme.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle({required this.labelKey, super.key});

  final String labelKey;

  @override
  Widget build(BuildContext context) {
    return Text(
      labelKey.tr(),
      textAlign: TextAlign.start,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: AppTheme.styles(context).sectionTitle,
    );
  }
}
