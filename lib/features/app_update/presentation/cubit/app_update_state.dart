part of 'app_update_cubit.dart';

sealed class AppUpdateState {
  const AppUpdateState();
}

final class AppUpdateInitial extends AppUpdateState {
  const AppUpdateInitial();
}

final class AppUpdateChecking extends AppUpdateState {
  const AppUpdateChecking();
}

/// The app may run: the build is current, the user chose "later", or the check
/// could not be made at all.
final class AppUpdateAllowed extends AppUpdateState {
  const AppUpdateAllowed();
}

/// A newer build exists but this one still works — offer it, do not insist.
final class AppUpdateOptional extends AppUpdateState {
  const AppUpdateOptional(this.version);

  final AppVersionModel version;
}

/// The app cannot be used: either the build is below the minimum, or the
/// backend is in maintenance. Carries [errorKey] so a failed attempt to open
/// the store can be reported without leaving this state.
final class AppUpdateBlocked extends AppUpdateState {
  const AppUpdateBlocked(this.version, {this.errorKey});

  final AppVersionModel version;
  final String? errorKey;
}
