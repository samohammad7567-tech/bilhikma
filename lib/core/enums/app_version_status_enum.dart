/// What the backend says about the build that is running.
///
/// Comes from `GET /public/app-version`; the app reacts to the status, never to
/// the version strings, which exist only to be shown to the user.
enum AppVersionStatus {
  ok,
  optionalUpdate,
  forceUpdate,
  maintenance;

  /// Maps the wire value, and treats anything unrecognised as [ok].
  ///
  /// Failing open is deliberate: a status this build has never heard of must
  /// not lock the user out of an app that was working a minute ago.
  static AppVersionStatus fromApi(Object? value) =>
      switch ((value ?? '').toString().trim().toLowerCase()) {
        'optional_update' => AppVersionStatus.optionalUpdate,
        'force_update' => AppVersionStatus.forceUpdate,
        'maintenance' => AppVersionStatus.maintenance,
        _ => AppVersionStatus.ok,
      };

  bool get isMaintenance => this == AppVersionStatus.maintenance;

  /// The app may not be used at all while this is true.
  bool get blocksApp => this == AppVersionStatus.forceUpdate || isMaintenance;
}
