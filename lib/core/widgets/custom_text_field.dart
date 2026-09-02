import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../themes/app_theme.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    required this.controller,
    this.filled = false,
    this.obscureText = false,
    this.readOnly = false,
    super.key,
    this.validator,
    this.fillColour,
    this.suffixIcon,
    this.hintText,
    this.keyboardType,
    this.hintStyle,
    this.overrideValidator = false,
    this.prefixIcon,
    this.onChanged,
    this.maxLength,
    this.maxLines = 1,
    this.contentPadding,
    this.borderColor,
    this.borderRadius,
    this.inputFormatters,
  });

  final String? Function(String?)? validator;
  final String? Function(String?)? onChanged;
  final TextEditingController controller;
  final bool filled;
  final Color? fillColour;
  final bool obscureText;
  final bool readOnly;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final String? hintText;
  final TextInputType? keyboardType;
  final bool overrideValidator;
  final TextStyle? hintStyle;
  final int? maxLength;
  final int? maxLines;
  final EdgeInsetsGeometry? contentPadding;
  final Color? borderColor;
  final double? borderRadius;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    final Color outline = borderColor ?? Theme.of(context).colorScheme.outline;
    final BorderRadius radius = BorderRadius.circular(borderRadius ?? 15.r);

    return TextFormField(
      controller: controller,
      style: AppTheme.styles(context).fieldInput,
      validator: validator,
      onChanged: onChanged,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLength: maxLength,
      obscureText: obscureText,
      maxLines: maxLines,
      readOnly: readOnly,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: radius),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: outline),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
        ),
        contentPadding:
            contentPadding ??
            EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        counterText: '',
        filled: filled,
        fillColor: fillColour ?? Theme.of(context).colorScheme.tertiary,
        suffixIcon: suffixIcon,
        prefixIcon: prefixIcon,
        hintText: hintText,
        hintStyle: hintStyle ?? AppTheme.styles(context).fieldHint,
        errorStyle: AppTheme.styles(context).fieldError,
      ),
    );
  }
}
