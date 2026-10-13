enum AppVersionStatus {
  ok,
  optionalUpdate,
  forceUpdate,
  maintenance;

  static AppVersionStatus fromApi(Object? value) =>
      switch ((value ?? '').toString().trim().toLowerCase()) {
        'optional_update' => AppVersionStatus.optionalUpdate,
        'force_update' => AppVersionStatus.forceUpdate,
        'maintenance' => AppVersionStatus.maintenance,
        _ => AppVersionStatus.ok,
      };

  bool get isMaintenance => this == AppVersionStatus.maintenance;
  bool get blocksApp => this == AppVersionStatus.forceUpdate || isMaintenance;
}
