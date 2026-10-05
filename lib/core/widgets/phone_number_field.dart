// easy_localization re-exports intl, whose TextDirection would shadow the
// framework one used for the LTR dial code below.
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_countries.dart';
import '../models/country_model.dart';
import '../themes/app_theme.dart';
import '../utils/app_regex.dart';
import '../utils/phone_number_input_formatter.dart';
import 'country_picker_sheet.dart';
import 'custom_text_field.dart';

/// Country selector stacked above a local-number input.
///
/// [controller] is kept in sync with the full E.164 number (`+963958953288`),
/// so the cubits reading it need no changes. The user never types `+` or the
/// calling code.
class PhoneNumberField extends StatefulWidget {
  const PhoneNumberField({
    required this.controller,
    super.key,
    this.fillColour,
    this.borderColor,
    this.borderRadius,
    this.suffixIcon,
  });

  /// Receives the full E.164 number on every edit.
  final TextEditingController controller;

  final Color? fillColour;
  final Color? borderColor;
  final double? borderRadius;
  final Widget? suffixIcon;

  @override
  State<PhoneNumberField> createState() => _PhoneNumberFieldState();
}

class _PhoneNumberFieldState extends State<PhoneNumberField> {
  late Country _country;
  late final TextEditingController _national;

  @override
  void initState() {
    super.initState();

    // A remembered identity arrives as a full number; split it back apart so
    // both the selector and the input repopulate.
    final ({Country country, String nationalNumber})? parsed =
        AppCountries.parse(widget.controller.text);

    _country = parsed?.country ?? AppCountries.defaultCountry;
    _national = TextEditingController(
      text: parsed == null
          ? ''
          : _country.formatNational(parsed.nationalNumber),
    );

    _syncController();
  }

  @override
  void dispose() {
    _national.dispose();
    super.dispose();
  }

  /// Digits the user typed, minus any local trunk prefix.
  String get _nationalDigits =>
      _national.text.replaceAll(RegExp(r'\D'), '').replaceFirst(RegExp('^0+'), '');

  void _syncController() {
    final String digits = _nationalDigits;
    widget.controller.text = digits.isEmpty ? '' : _country.toE164(digits);
  }

  Future<void> _pickCountry() async {
    final Country? picked = await CountryPickerSheet.show(
      context,
      selected: _country,
    );
    if (picked == null || !mounted) return;

    setState(() {
      _country = picked;
      // Re-space the existing digits into the new country's grouping.
      _national.text = picked.formatNational(
        _nationalDigits.length > picked.maxLength
            ? _nationalDigits.substring(0, picked.maxLength)
            : _nationalDigits,
      );
    });

    _syncController();
  }

  String? _validate(String? value) {
    final String digits = _nationalDigits;
    if (digits.isEmpty) return 'phone_required'.tr();

    if (!_country.isValidNationalNumber(digits)) {
      final String name = _country.localizedName(context.locale.languageCode);

      return _country.minLength == _country.maxLength
          ? 'phone_length_exact'.tr(
              namedArgs: <String, String>{
                'country': name,
                'count': '${_country.maxLength}',
              },
            )
          : 'phone_length_range'.tr(
              namedArgs: <String, String>{
                'country': name,
                'min': '${_country.minLength}',
                'max': '${_country.maxLength}',
              },
            );
    }

    // The app-wide rule, unchanged, applied to the composed number.
    if (!AppRegex.isValidPhone(_country.toE164(digits))) {
      return 'valid_phone_required'.tr();
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final Color fill = widget.fillColour ?? colors.tertiary.withValues(alpha: 0.4);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _CountrySelectorTile(
          country: _country,
          fill: fill,
          borderColor: widget.borderColor,
          borderRadius: widget.borderRadius,
          onTap: _pickCountry,
        ),

        SizedBox(height: 10.h),

        CustomTextField(
          controller: _national,
          filled: true,
          fillColour: fill,
          borderColor: widget.borderColor,
          borderRadius: widget.borderRadius,
          hintText: 'phone_number'.tr(),
          keyboardType: TextInputType.phone,
          suffixIcon: widget.suffixIcon,
          prefixIcon: Padding(
            padding: EdgeInsetsDirectional.only(start: 16.w, end: 8.w),
            child: Text(
              _country.displayDialCode,
              textDirection: TextDirection.ltr,
              maxLines: 1,
              style: AppTheme.styles(context).fieldInput,
            ),
          ),
          inputFormatters: <TextInputFormatter>[
            PhoneNumberInputFormatter(_country),
          ],
          onChanged: (String? value) {
            _syncController();
            return null;
          },
          validator: _validate,
        ),

        SizedBox(height: 6.h),

        Padding(
          padding: EdgeInsetsDirectional.only(start: 4.w, end: 4.w),
          child: Text(
            'phone_hint_without_country_code'.tr(),
            textAlign: TextAlign.start,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.styles(context).labelSmall,
          ),
        ),
      ],
    );
  }
}

class _CountrySelectorTile extends StatelessWidget {
  const _CountrySelectorTile({
    required this.country,
    required this.fill,
    required this.onTap,
    this.borderColor,
    this.borderRadius,
  });

  final Country country;
  final Color fill;
  final VoidCallback onTap;
  final Color? borderColor;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final BorderRadius radius = BorderRadius.circular(borderRadius ?? 15.r);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: fill,
            borderRadius: radius,
            border: Border.all(color: borderColor ?? colors.outline),
          ),
          child: Row(
            children: <Widget>[
              Text(country.flag, style: TextStyle(fontSize: 22.sp)),

              SizedBox(width: 10.w),

              Expanded(
                child: Text(
                  country.localizedName(context.locale.languageCode),
                  textAlign: TextAlign.start,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.styles(context).fieldInput,
                ),
              ),

              SizedBox(width: 8.w),

              Text(
                country.displayDialCode,
                textDirection: TextDirection.ltr,
                maxLines: 1,
                style: AppTheme.styles(
                  context,
                ).labelMedium.copyWith(color: colors.onSurfaceVariant),
              ),

              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 22.w,
                color: colors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
