import '../../../../core/enums/app_version_status_enum.dart';
import '../../../../core/network/json_reader.dart';

/// One platform's update settings, from `GET /public/app-version`.
///
/// The endpoint answers with the usual envelope wrapping `data.items`, a row
/// per platform, and sends no verdict of its own — only the thresholds. So
/// [status] is resolved here from the running build, comparing **build numbers
/// only**: the version strings are display text and decide nothing.
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

  /// Below this the update is forced.
  final int? minimumBuild;

  final bool maintenanceMode;

  /// Arrives as `{"ar": ..., "en": ...}` and is read in the active language.
  final String? message;

  final String? storeUrl;

  bool get hasStoreUrl => (storeUrl ?? '').isNotEmpty;

  bool get hasMessage => (message ?? '').isNotEmpty;

  /// Picks this platform's row out of the response and resolves the verdict.
  ///
  /// Returns null when there is nothing to act on — no row for this platform,
  /// or a body in a shape this build does not recognise. A missing answer is
  /// not a reason to stop anyone, so the caller treats null as "carry on".
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

  /// Walks the payload to this platform's row.
  ///
  /// Three shapes are accepted: `data.items` as documented, a bare `data`
  /// object, and a flat top-level row. The spec described the flat one and the
  /// server sends the first, so reading all three keeps a server-side change to
  /// either from turning into a forced update for everyone.
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

    // A row for another platform says nothing about this one.
    return null;
  }

  /// Build numbers only, in order of severity.
  ///
  /// An explicit `status` wins if the server ever starts sending one, as the
  /// spec originally described; otherwise the thresholds decide. Missing
  /// thresholds resolve to [AppVersionStatus.ok] — an incomplete row must not
  /// lock anybody out.
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
