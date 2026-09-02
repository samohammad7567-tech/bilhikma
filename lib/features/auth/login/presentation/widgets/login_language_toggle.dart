import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/enums/language_option_enum.dart';
import '../../../../../core/themes/app_theme.dart';
import '../../../../../core/widgets/app_icon.dart';

/// The language pill above the login title.
///
/// Settings can change the language, but settings sits behind the sign-in, so
/// a user who cannot read the language the app opened in has no way through.
/// This is that way through — the only language control reachable while signed
/// out. `context.setLocale` persists the choice, so it survives the restart.
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
      elevation: 4,
      offset: Offset(0, 40.h),
      constraints: BoxConstraints(minWidth: 150.w),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<LanguageOption>>[
        PopupMenuItem<LanguageOption>(
          enabled: false,
          height: 34.h,
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
            height: 40.h,
            child: _LanguageMenuRow(
              option: option,
              isSelected: option == selected,
            ),
          ),
      ],
      child: _LanguagePill(label: selected.label.tr()),
    );
  }

  /// Re-selecting the current language would rebuild the whole app for nothing.
  void _select(BuildContext context, LanguageOption option) {
    if (option.code == context.locale.languageCode) return;

    context.setLocale(option.locale);
  }
}

/// The collapsed control: globe, current language, chevron. Laid out with the
/// globe first so direction carries it — leading in English, trailing in Arabic.
class _LanguagePill extends StatelessWidget {
  const _LanguagePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final AppTextStyles styles = AppTheme.styles(context);

    return Container(
      padding: EdgeInsetsDirectional.fromSTEB(4.w, 4.h, 10.w, 4.h),
      decoration: BoxDecoration(
        color: colors.tertiary.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 26.w,
            height: 26.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.primary,
              shape: BoxShape.circle,
            ),
            child: AppIcon(
              asset: AppAssets.assetsLanguageIcon,
              size: 15.w,
              color: colors.onPrimary,
            ),
          ),
          SizedBox(width: 6.w),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: styles.labelMedium,
            ),
          ),
          SizedBox(width: 2.w),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 18.w,
            color: colors.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}

/// One language in the open menu. Both labels stay in their own script in
/// either locale, so the option a user is looking for is always legible.
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
          Icon(
            Icons.check_rounded,
            size: 18.w,
            color: colors.onSurfaceVariant,
          ),
      ],
    );
  }
}
