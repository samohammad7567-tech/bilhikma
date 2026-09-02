part of 'app_preferences_cubit.dart';

@immutable
sealed class AppPreferencesState {}

final class AppPreferencesInitial extends AppPreferencesState {}

final class AppPreferencesThemeChanged extends AppPreferencesState {}

final class AppPreferencesFontScaleChanged extends AppPreferencesState {}

final class AppPreferencesTabChanged extends AppPreferencesState {}
