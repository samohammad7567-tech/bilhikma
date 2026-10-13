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

final class AppUpdateAllowed extends AppUpdateState {
  const AppUpdateAllowed();
}

final class AppUpdateOptional extends AppUpdateState {
  const AppUpdateOptional(this.version);

  final AppVersionModel version;
}

final class AppUpdateBlocked extends AppUpdateState {
  const AppUpdateBlocked(this.version, {this.errorKey});

  final AppVersionModel version;
  final String? errorKey;
}
