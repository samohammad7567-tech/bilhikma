import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_envelope.dart';
import '../../../../core/services/app_info_service.dart';
import '../../../../core/services/device_service.dart';
import '../../../../core/utils/app_language.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/app_version_model.dart';

/// Talks to the public version endpoint, and opens the download link.
///
/// This is the one data source in the app that does not go through
/// [ApiClient]/`DioService`. The envelope would parse fine, but `DioService`'s
/// pipeline carries `AuthInterceptor` and `DeviceInterceptor`, and either one
/// reacting to this request — a 401, a device conflict — would clear the
/// session and push the user to login. A public call made before the first
/// screen must not be able to sign anybody out.
///
/// So it owns a bare Dio with no interceptors and no Authorization header, and
/// reads the envelope itself.
class AppUpdateDataSource {
  AppUpdateDataSource({Dio? dio}) : _dio = dio ?? _buildDio();

  static const String _logName = 'app_update';

  /// Shorter than the app-wide timeouts on purpose: this call sits on the
  /// startup path, and a slow answer is worth less than a fast launch. Going
  /// unanswered is handled — [fetch] returns null and the app continues.
  static const Duration _connectTimeout = Duration(seconds: 8);
  static const Duration _receiveTimeout = Duration(seconds: 8);

  final Dio _dio;

  static Dio _buildDio() => Dio(
    BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: _connectTimeout,
      receiveTimeout: _receiveTimeout,
      headers: const <String, String>{'Accept': 'application/json'},
    ),
  );

  /// Returns null when the question could not be answered — offline, timed out,
  /// a non-2xx, or a body that did not parse.
  ///
  /// Never throws. The spec is explicit that a failed check must not block the
  /// user, and the cleanest place to honour that is here, at the boundary:
  /// callers that cannot see an error cannot act on one.
  Future<AppVersionModel?> fetch() async {
    final String platform = DeviceService.platform;
    final String build = AppInfoService.buildNumber;

    // The whole comparison is done on the build number, so without a usable
    // one there is no question to ask. This happens when the package-info
    // platform call failed during startup; the app carries on unchecked rather
    // than acting on a build it cannot compare.
    final int? currentBuild = int.tryParse(build);
    if (currentBuild == null) {
      AppLogger.warning(
        'Skipping the version check: build number "$build" is not a number',
        name: _logName,
      );
      return null;
    }

    try {
      final Response<dynamic> response = await _dio.get<dynamic>(
        ApiEndpoints.appVersion,
        queryParameters: <String, dynamic>{
          'platform': platform,
          'build': build,
        },
        options: Options(
          headers: <String, String>{
            // The endpoint accepts the pair as headers too; sending both costs
            // nothing and survives either server-side reading.
            'Platform': platform,
            'Build-Number': build,
            // The server localizes `message` from this.
            'Accept-Language': AppLanguage.code,
          },
        ),
      );

      final dynamic body = response.data;
      if (body is! Map) {
        AppLogger.warning(
          'Version check answered with ${body.runtimeType}, not an object',
          name: _logName,
        );
        return null;
      }

      final ApiEnvelope envelope = ApiEnvelope.fromJson(
        Map<String, dynamic>.from(body),
      );

      // Read the envelope here rather than through ApiClient, but hold it to
      // the same contract: anything other than a success is no answer at all.
      if (!envelope.isSuccess) {
        AppLogger.warning(
          'Version check rejected: status_code ${envelope.statusCode}'
          '${envelope.message == null ? '' : ' — ${envelope.message}'}',
          name: _logName,
        );
        return null;
      }

      final AppVersionModel? version = AppVersionModel.fromResponse(
        Map<String, dynamic>.from(body),
        platform: platform,
        currentBuild: currentBuild,
      );

      if (version == null) {
        AppLogger.warning(
          'Version check carried no row for "$platform"',
          name: _logName,
        );
        return null;
      }

      AppLogger.info(
        'Version check: build $currentBuild vs latest ${version.latestBuild} / '
        'minimum ${version.minimumBuild} → ${version.status.name}',
        name: _logName,
      );

      return version;
    } catch (error, stackTrace) {
      AppLogger.error(
        'Version check failed — continuing without it',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Hands the download link to the system browser.
  ///
  /// [LaunchMode.externalApplication] rather than an in-app web view: the link
  /// is a Google Drive APK download, which an embedded view cannot complete.
  Future<bool> openStore(String url) async {
    final Uri? uri = Uri.tryParse(url.trim());
    if (uri == null || !uri.hasScheme) {
      AppLogger.warning('Store url is not usable: "$url"', name: _logName);
      return false;
    }

    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (error, stackTrace) {
      AppLogger.error(
        'Could not open the store url',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }
}
