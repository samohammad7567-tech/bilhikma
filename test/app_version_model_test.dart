import 'package:bilhikma/core/enums/app_version_status_enum.dart';
import 'package:bilhikma/features/app_update/data/models/app_version_model.dart';
import 'package:flutter_test/flutter_test.dart';

/// The real payload from `GET /public/app-version`: the standard envelope, a
/// row per platform under `data.items`, and no `status` field — the verdict is
/// the client's to work out from the build thresholds.
Map<String, dynamic> response({
  String platform = 'android',
  int latestBuild = 3000,
  int minimumBuild = 3000,
  bool maintenanceMode = false,
}) => <String, dynamic>{
  'message': 'تم جلب إعدادات تحديث التطبيق بنجاح',
  'status_code': 1,
  'data': <String, dynamic>{
    'items': <Map<String, dynamic>>[
      <String, dynamic>{
        'id': 3,
        'platform': platform,
        'latest_version': '1.0.1',
        'minimum_version': '1.0.1',
        'latest_build': latestBuild,
        'minimum_build': minimumBuild,
        'store_url': 'https://bilhikma.tech/downloads/BilHikma-1.0.1+3000.apk',
        'message': <String, dynamic>{
          'ar': 'يرجى تحديث التطبيق للاستمرار',
          'en': 'Please update the app to continue',
        },
        'maintenance_mode': maintenanceMode,
        'created_at': '2026-10-10T23:05:52+00:00',
        'updated_at': '2026-10-10T23:05:52+00:00',
      },
    ],
  },
};

AppVersionModel? parse(Map<String, dynamic> body, int currentBuild) =>
    AppVersionModel.fromResponse(
      body,
      platform: 'android',
      currentBuild: currentBuild,
    );

void main() {
  group('verdict', () {
    test('forces the update below minimum_build', () {
      expect(parse(response(), 10)!.status, AppVersionStatus.forceUpdate);
    });

    test('offers the update between minimum_build and latest_build', () {
      final AppVersionModel? version = parse(
        response(minimumBuild: 2000, latestBuild: 3000),
        2500,
      );

      expect(version!.status, AppVersionStatus.optionalUpdate);
    });

    test('allows the current build through', () {
      expect(parse(response(), 3000)!.status, AppVersionStatus.ok);
    });

    test('allows a build newer than the server knows about', () {
      expect(parse(response(), 3001)!.status, AppVersionStatus.ok);
    });

    test('maintenance_mode outranks an otherwise current build', () {
      final AppVersionModel? version = parse(
        response(maintenanceMode: true),
        3000,
      );

      expect(version!.status, AppVersionStatus.maintenance);
    });

    test('a row with no thresholds cannot lock anyone out', () {
      final Map<String, dynamic> body = response();
      (body['data']['items'] as List<dynamic>).first
        ..remove('latest_build')
        ..remove('minimum_build');

      expect(parse(body, 10)!.status, AppVersionStatus.ok);
    });

    test('an explicit status from the server wins over the thresholds', () {
      final Map<String, dynamic> body = response();
      (body['data']['items'] as List<dynamic>).first['status'] = 'ok';

      expect(parse(body, 10)!.status, AppVersionStatus.ok);
    });

    test('an unrecognised status fails open', () {
      final Map<String, dynamic> body = response();
      (body['data']['items'] as List<dynamic>).first['status'] =
          'something_new';

      expect(parse(body, 10)!.status, AppVersionStatus.ok);
    });
  });

  group('row selection', () {
    test('ignores a row belonging to another platform', () {
      expect(parse(response(platform: 'ios'), 10), isNull);
    });

    test('reads the flat shape the spec documented', () {
      final Map<String, dynamic> flat = <String, dynamic>{
        'status': 'force_update',
        'latest_version': '1.0.1',
        'latest_build': 3000,
        'minimum_version': '1.0.1',
        'minimum_build': 3000,
        'message': 'update please',
        'store_url': 'https://bilhikma.tech/app.apk',
      };

      final AppVersionModel? version = parse(flat, 10);

      expect(version!.status, AppVersionStatus.forceUpdate);
      expect(version.storeUrl, 'https://bilhikma.tech/app.apk');
    });

    test('an empty item list yields nothing to act on', () {
      final Map<String, dynamic> body = response();
      body['data'] = <String, dynamic>{'items': <Map<String, dynamic>>[]};

      expect(parse(body, 10), isNull);
    });
  });

  group('fields', () {
    test('reads the localized message and the store url', () {
      final AppVersionModel version = parse(response(), 10)!;

      expect(version.message, 'يرجى تحديث التطبيق للاستمرار');
      expect(version.latestVersion, '1.0.1');
      expect(version.latestBuild, 3000);
      expect(version.hasStoreUrl, isTrue);
    });
  });
}
