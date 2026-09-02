import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/app_screen_util.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static AppTextStyles styles(BuildContext context) =>
      AppTextStyles(Theme.of(context).colorScheme);

  static const ColorScheme lightColorScheme = ColorScheme.light(
    primary: AppColors.green,
    onPrimary: Colors.white,
    primaryContainer: AppColors.actionGreen,
    onPrimaryContainer: Colors.white,
    inversePrimary: AppColors.ink,
    secondary: AppColors.darkGreen,
    onSecondary: Colors.white,
    secondaryContainer: AppColors.green,
    onSecondaryContainer: Colors.white,
    tertiary: AppColors.gold,
    onTertiary: Colors.white,
    tertiaryContainer: AppColors.sand,
    onTertiaryContainer: AppColors.darkGreen,
    error: Colors.red,
    onError: Colors.white,
    surface: AppColors.cream,
    onSurface: AppColors.ink,
    onSurfaceVariant: AppColors.green,
    surfaceContainerLowest: Colors.white,
    surfaceContainerHigh: AppColors.ringTrack,
    surfaceContainerHighest: AppColors.creamCard,
    outline: AppColors.green,
  );

  static const ColorScheme darkColorScheme = ColorScheme.dark(
    primary: Color(0xffA54735),
    secondary: Color(0xff3E5A3E),
    surface: Color(0xff171717),
    inversePrimary: Colors.white,
    tertiary: Color(0xffC0A572),
    tertiaryContainer: Color(0xff2C2A22),
    secondaryContainer: Color(0xff9DBF9D),
    onSecondaryContainer: Color(0xff102010),
    outline: Color(0xff9DBF9D),
    onSurfaceVariant: Color(0xffB9CBB9),
    primaryContainer: Color(0xff4E7A4E),
    onPrimaryContainer: Colors.white,
    surfaceContainerLowest: Color(0xff0E0E0E),
    surfaceContainerHighest: Color(0xff242424),
    surfaceContainerHigh: Color(0xff334433),
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: Colors.white,
    onTertiary: Color(0xff1E1E1E),
    onTertiaryContainer: Color(0xffE8DCC4),
    error: Colors.red,
    onError: Colors.white,
  );

  static ThemeData light() {
    AppScreenUtil.ensureConfigured();

    return ThemeData(
      useMaterial3: false,
      primaryColorLight: lightColorScheme.surface,
      primaryColorDark: lightColorScheme.secondary,

      iconTheme: IconThemeData(color: lightColorScheme.primary),
      scaffoldBackgroundColor: lightColorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: lightColorScheme.surface,
        foregroundColor: lightColorScheme.primary,
        elevation: 0,
      ),
      colorScheme: lightColorScheme,

      textTheme: const AppTextStyles(lightColorScheme).textTheme,
    );
  }

  static ThemeData dark() {
    AppScreenUtil.ensureConfigured();

    return ThemeData(
      useMaterial3: false,
      brightness: Brightness.dark,

      primaryColor: darkColorScheme.primary,
      primaryColorLight: const Color(0xff1E1E1E),
      primaryColorDark: Colors.white,
      scaffoldBackgroundColor: darkColorScheme.surface,

      iconTheme: IconThemeData(color: darkColorScheme.primary),

      colorScheme: darkColorScheme,

      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xff1E1E1E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      textTheme: const AppTextStyles(darkColorScheme).textTheme,

      dividerColor: Colors.white12,

      cardColor: const Color(0xff1E1E1E),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Colors.white,
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: Colors.white),
      ),
    );
  }
}

@immutable
class AppTextStyles {
  const AppTextStyles(this.colors);

  final ColorScheme colors;
  TextStyle _style({
    required double size,
    required FontWeight weight,
    required Color color,
    double? height,
  }) => GoogleFonts.cairo(
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
  );
  TextStyle get statusTitle =>
      _style(size: 26.sp, weight: FontWeight.w700, color: colors.onSurface);
  TextStyle get authTitle =>
      _style(size: 24.sp, weight: FontWeight.w700, color: colors.onSurface);
  TextStyle get screenTitle =>
      _style(size: 20.sp, weight: FontWeight.w800, color: colors.onSurface);
  TextStyle get sectionTitle =>
      _style(size: 18.sp, weight: FontWeight.w800, color: colors.onSurface);
  TextStyle get panelTitle =>
      _style(size: 17.sp, weight: FontWeight.w800, color: colors.onSurface);
  TextStyle get bannerTitle =>
      _style(size: 17.sp, weight: FontWeight.w700, color: colors.onSurface);
  TextStyle get groupTitle =>
      _style(size: 15.sp, weight: FontWeight.w800, color: colors.onSurface);
  TextStyle get splashTitle => GoogleFonts.arefRuqaa(
    fontSize: 18.sp,
    fontWeight: FontWeight.w700,
    color: colors.onSurface,
  );
  TextStyle get cardTitle =>
      _style(size: 15.sp, weight: FontWeight.w700, color: colors.onSurface);
  TextStyle get cardSubtitle => _style(
    size: 12.sp,
    weight: FontWeight.w400,
    color: colors.onSurfaceVariant,
  );
  TextStyle get cardBlurb => _style(
    size: 11.sp,
    weight: FontWeight.w400,
    color: colors.onSurfaceVariant,
    height: 1.6,
  );
  TextStyle get cardCaption => _style(
    size: 11.sp,
    weight: FontWeight.w400,
    color: colors.onSurfaceVariant,
  );
  TextStyle get rowTitle =>
      _style(size: 14.sp, weight: FontWeight.w700, color: colors.onSurface);
  TextStyle get rowValue => _style(
    size: 12.sp,
    weight: FontWeight.w600,
    color: colors.onSurfaceVariant,
  );
  TextStyle get optionLabel =>
      _style(size: 14.sp, weight: FontWeight.w500, color: colors.onSurface);
  TextStyle get optionLabelSelected =>
      _style(size: 14.sp, weight: FontWeight.w800, color: colors.onSurface);
  TextStyle get labelStrong =>
      _style(size: 13.sp, weight: FontWeight.w700, color: colors.onSurface);
  TextStyle get labelMedium =>
      _style(size: 13.sp, weight: FontWeight.w600, color: colors.onSurface);
  TextStyle get labelSmall => _style(
    size: 12.sp,
    weight: FontWeight.w600,
    color: colors.onSurfaceVariant,
  );
  TextStyle get pillLabel =>
      _style(size: 14.sp, weight: FontWeight.w600, color: colors.onPrimary);
  TextStyle get badgeLabel =>
      _style(size: 11.sp, weight: FontWeight.w600, color: colors.onPrimary);
  TextStyle get progressLabel =>
      _style(size: 11.sp, weight: FontWeight.w700, color: colors.onSurface);
  TextStyle get caption =>
      _style(size: 11.sp, weight: FontWeight.w400, color: colors.onSurface);
  TextStyle get brandTagline => _style(
    size: 11.sp,
    weight: FontWeight.w400,
    color: colors.onSecondary,
    height: 1.7,
  );
  TextStyle get statValue =>
      _style(size: 16.sp, weight: FontWeight.w700, color: colors.onSurface);
  TextStyle get statLabel => _style(
    size: 10.sp,
    weight: FontWeight.w700,
    color: colors.onSurfaceVariant,
  );
  TextStyle get buttonLabel =>
      _style(size: 16.sp, weight: FontWeight.w400, color: colors.onPrimary);
  TextStyle get navLabel =>
      _style(size: 12.sp, weight: FontWeight.w400, color: colors.surface);
  TextStyle get linkLabel =>
      _style(size: 12.sp, weight: FontWeight.w400, color: colors.secondary);
  TextStyle get fieldInput =>
      _style(size: 14.sp, weight: FontWeight.w400, color: colors.onSurface);
  TextStyle get fieldHint =>
      _style(size: 14.sp, weight: FontWeight.w400, color: colors.onSurface);
  TextStyle get searchHint => _style(
    size: 13.sp,
    weight: FontWeight.w400,
    color: colors.onSurfaceVariant,
  );
  TextStyle get fieldError =>
      _style(size: 12.sp, weight: FontWeight.w400, color: colors.error);

  TextStyle get bodyLarge =>
      _style(size: 16.sp, weight: FontWeight.w400, color: colors.onSurface);
  TextStyle get bodyStrong =>
      _style(size: 16.sp, weight: FontWeight.w700, color: colors.onSurface);

  TextStyle get bodyMedium =>
      _style(size: 14.sp, weight: FontWeight.w400, color: colors.onSurface);

  TextStyle get bodySmall => _style(
    size: 12.sp,
    weight: FontWeight.w400,
    color: colors.onSurfaceVariant,
  );
  TextStyle get note => _style(
    size: 16.sp,
    weight: FontWeight.w400,
    color: colors.secondary,
    height: 1.5,
  );
  TextTheme get textTheme => TextTheme(
    headlineLarge: authTitle,
    headlineMedium: screenTitle,
    headlineSmall: sectionTitle,
    titleLarge: panelTitle,
    titleMedium: cardTitle,
    titleSmall: rowTitle,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
    labelLarge: buttonLabel,
    labelMedium: labelMedium,
    labelSmall: badgeLabel,
  );
}
