// easy_localization re-exports intl, whose TextDirection would shadow the
// framework one used for the LTR dial codes below.
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_countries.dart';
import '../models/country_model.dart';
import '../themes/app_theme.dart';
import 'custom_text_field.dart';
import 'sheet_handle.dart';

/// Searchable country list. Resolves with the picked [Country], or `null` when
/// the sheet is dismissed.
class CountryPickerSheet extends StatefulWidget {
  const CountryPickerSheet({required this.selected, super.key});

  final Country selected;

  static Future<Country?> show(
    BuildContext context, {
    required Country selected,
  }) => showModalBottomSheet<Country>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (BuildContext sheetContext) =>
        CountryPickerSheet(selected: selected),
  );

  @override
  State<CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<CountryPickerSheet> {
  final TextEditingController _search = TextEditingController();

  List<Country> _results = AppCountries.all;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _filter(String query) => setState(
    () => _results = AppCountries.all
        .where((Country country) => country.matches(query))
        .toList(),
  );

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final String language = context.locale.languageCode;

    return Padding(
      // Lifts the sheet above the keyboard while searching.
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        height: 0.78.sh,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: <Widget>[
              SizedBox(height: 12.h),

              const SheetHandle(),

              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 12.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'select_country'.tr(),
                      textAlign: TextAlign.start,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.styles(context).labelStrong,
                    ),

                    SizedBox(height: 12.h),

                    CustomTextField(
                      controller: _search,
                      filled: true,
                      fillColour: colors.tertiary.withValues(alpha: 0.4),
                      borderColor: Colors.transparent,
                      borderRadius: 12.r,
                      hintText: 'search_country'.tr(),
                      prefixIcon: Icon(Icons.search, size: 20.w),
                      onChanged: (String? value) {
                        _filter(value ?? '');
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              Expanded(
                child: _results.isEmpty
                    ? Center(
                        child: Text(
                          'no_countries_found'.tr(),
                          textAlign: TextAlign.center,
                          style: AppTheme.styles(context).labelSmall,
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.only(bottom: 12.h),
                        itemCount: _results.length,
                        itemBuilder: (BuildContext context, int index) {
                          final Country country = _results[index];

                          return _CountryTile(
                            country: country,
                            language: language,
                            isSelected:
                                country.isoCode == widget.selected.isoCode,
                            onTap: () =>
                                Navigator.of(context).pop<Country>(country),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CountryTile extends StatelessWidget {
  const _CountryTile({
    required this.country,
    required this.language,
    required this.isSelected,
    required this.onTap,
  });

  final Country country;
  final String language;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return ListTile(
      onTap: onTap,
      selected: isSelected,
      selectedTileColor: colors.tertiary.withValues(alpha: 0.3),
      leading: Text(
        country.flag,
        style: TextStyle(fontSize: 24.sp),
      ),
      title: Text(
        country.localizedName(language),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTheme.styles(context).optionLabel,
      ),
      trailing: Text(
        country.displayDialCode,
        textDirection: TextDirection.ltr,
        style: AppTheme.styles(context).labelMedium.copyWith(
          color: isSelected ? colors.secondary : colors.onSurfaceVariant,
        ),
      ),
    );
  }
}
