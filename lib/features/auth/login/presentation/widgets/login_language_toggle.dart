import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/enums/language_option_enum.dart';
import '../../../../../core/themes/app_theme.dart';
import '../../../../../core/widgets/app_icon.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class LoginLanguageToggle extends StatelessWidget {
  const LoginLanguageToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final AppTextStyles styles = AppTheme.styles(context);
    final LanguageOption selected = LanguageOption.of(
      context.locale.languageCode,
    );

    return PopupMenuButton<LanguageOption>(
      onSelected: (LanguageOption option) => _select(context, option),
      tooltip: 'choose_language'.tr(),
      padding: EdgeInsets.zero,
      color: colors.surfaceContainerLowest,
      elevation: (4).r(context),
      offset: Offset(0, 40),
      constraints: BoxConstraints(minWidth: 150),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular((12).r(context))),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<LanguageOption>>[
        PopupMenuItem<LanguageOption>(
          enabled: false,
          height: (34).h(context),
          child: Text(
            'choose_language'.tr(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: styles.labelSmall,
          ),
        ),
        for (final LanguageOption option in LanguageOption.values)
          PopupMenuItem<LanguageOption>(
            value: option,
            height: (40).h(context),
            child: _LanguageMenuRow(
              option: option,
              isSelected: option == selected,
            ),
          ),
      ],
      child: _LanguagePill(label: selected.label.tr()),
    );
  }

  void _select(BuildContext context, LanguageOption option) {
    if (option.code == context.locale.languageCode) return;

    context.setLocale(option.locale);
  }
}

class _LanguagePill extends StatelessWidget {
  const _LanguagePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final AppTextStyles styles = AppTheme.styles(context);

    return Container(
      padding: EdgeInsetsDirectional.fromSTEB(4, 4, 10, 4),
      decoration: BoxDecoration(
        color: colors.tertiary.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular((24).r(context)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: (26).w(context),
            height: (26).h(context),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.primary,
              shape: BoxShape.circle,
            ),
            child: AppIcon(
              asset: AppAssets.assetsLanguageIcon,
              size: (15).r(context),
              color: colors.onPrimary,
            ),
          ),
          SizedBox(width: (6).w(context)),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: styles.labelMedium,
            ),
          ),
          SizedBox(width: (2).w(context)),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            size: (18).r(context),
            color: colors.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}

class _LanguageMenuRow extends StatelessWidget {
  const _LanguageMenuRow({required this.option, required this.isSelected});

  final LanguageOption option;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final AppTextStyles styles = AppTheme.styles(context);

    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            option.label.tr(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: isSelected ? styles.optionLabelSelected : styles.optionLabel,
          ),
        ),
        if (isSelected)
          Icon(Icons.check_rounded, size: (18).r(context), color: colors.onSurfaceVariant),
      ],
    );
  }
}
