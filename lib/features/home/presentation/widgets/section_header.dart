import 'package:flutter/material.dart';

import '../../../../core/themes/app_theme.dart';
import 'section_view_all_button.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.title,
    super.key,
    this.subtitle,
    this.onViewAll,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    final String? subtitle = this.subtitle;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.styles(context).sectionTitle,
              ),

              if (subtitle != null && subtitle.isNotEmpty) ...<Widget>[
                SizedBox(height: (2).h(context)),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.styles(context).bodyMedium.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),

        if (onViewAll != null) ...<Widget>[
          SizedBox(width: (12).w(context)),
          SectionViewAllButton(onPressed: onViewAll!),
        ],
      ],
    );
  }
}
