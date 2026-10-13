import '../../../../core/enums/app_version_status_enum.dart';
import '../../../../core/network/json_reader.dart';

class AppVersionModel {
  const AppVersionModel({
    required this.status,
    required this.platform,
    required this.latestVersion,
    required this.minimumVersion,
    required this.latestBuild,
    required this.minimumBuild,
    required this.maintenanceMode,
    required this.message,
    required this.storeUrl,
  });

  final AppVersionStatus status;
  final String platform;
  final String latestVersion;
  final String minimumVersion;
  final int? latestBuild;
  final int? minimumBuild;

  final bool maintenanceMode;
  final String? message;

  final String? storeUrl;

  bool get hasStoreUrl => (storeUrl ?? '').isNotEmpty;

  bool get hasMessage => (message ?? '').isNotEmpty;
  static AppVersionModel? fromResponse(
    Map<String, dynamic> body, {
    required String platform,
    required int currentBuild,
  }) {
    final Map<String, dynamic>? row = _rowFor(body, platform);
    if (row == null) return null;

    return AppVersionModel._fromRow(row, currentBuild: currentBuild);
  }

  factory AppVersionModel._fromRow(
    Map<String, dynamic> row, {
    required int currentBuild,
  }) {
    final int? latestBuild = Json.asOptionalInt(row['latest_build']);
    final int? minimumBuild = Json.asOptionalInt(row['minimum_build']);
    final bool maintenanceMode = Json.asBool(row['maintenance_mode']);

    return AppVersionModel(
      status: _resolveStatus(
        explicit: row['status'],
        currentBuild: currentBuild,
        latestBuild: latestBuild,
        minimumBuild: minimumBuild,
        maintenanceMode: maintenanceMode,
      ),
      platform: Json.asString(row['platform']),
      latestVersion: Json.asString(row['latest_version']),
      minimumVersion: Json.asString(row['minimum_version']),
      latestBuild: latestBuild,
      minimumBuild: minimumBuild,
      maintenanceMode: maintenanceMode,
      message: Json.asOptionalLocalizedString(row['message']),
      storeUrl: Json.asOptionalString(row['store_url']),
    );
  }
  static Map<String, dynamic>? _rowFor(
    Map<String, dynamic> body,
    String platform,
  ) {
    final Map<String, dynamic> data = body.containsKey('data')
        ? Json.asMap(body['data'])
        : body;

    final List<Map<String, dynamic>> items = Json.asMapList(data['items']);

    if (items.isEmpty) {
      final Map<String, dynamic> single = data.isEmpty ? body : data;
      return single.containsKey('latest_build') ||
              single.containsKey('minimum_build')
          ? single
          : null;
    }

    final String wanted = platform.trim().toLowerCase();

    for (final Map<String, dynamic> item in items) {
      if (Json.asString(item['platform']).trim().toLowerCase() == wanted) {
        return item;
      }
    }
    return null;
  }

  static AppVersionStatus _resolveStatus({
    required Object? explicit,
    required int currentBuild,
    required int? latestBuild,
    required int? minimumBuild,
    required bool maintenanceMode,
  }) {
    if (explicit != null) return AppVersionStatus.fromApi(explicit);

    if (maintenanceMode) return AppVersionStatus.maintenance;

    if (minimumBuild != null && currentBuild < minimumBuild) {
      return AppVersionStatus.forceUpdate;
    }

    if (latestBuild != null && currentBuild < latestBuild) {
      return AppVersionStatus.optionalUpdate;
    }

    return AppVersionStatus.ok;
  }
}
