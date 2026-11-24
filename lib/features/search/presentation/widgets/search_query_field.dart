import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/themes/app_theme.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class SearchQueryField extends StatelessWidget {
  const SearchQueryField({
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
    super.key,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmitted;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final BorderRadius radius = BorderRadius.circular((28).r(context));

    return TextField(
      controller: controller,
      onChanged: onChanged,
      onSubmitted: (_) => onSubmitted(),
      textInputAction: TextInputAction.search,
      style: AppTheme.styles(context).fieldInput,
      decoration: InputDecoration(
        filled: true,
        fillColor: colors.surfaceContainerHighest,
        hintText: 'search_hint'.tr(),
        hintStyle: AppTheme.styles(context).searchHint,
        contentPadding: EdgeInsets.symmetric(horizontal: (20).w(context), vertical: (14).h(context)),
        border: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: colors.outline),
        ),
      ),
    );
  }
}
