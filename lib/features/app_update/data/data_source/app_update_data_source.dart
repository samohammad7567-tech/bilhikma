import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_envelope.dart';
import '../../../../core/services/app_info_service.dart';
import '../../../../core/services/device_service.dart';
import '../../../../core/utils/app_language.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/app_version_model.dart';

class AppUpdateDataSource {
  AppUpdateDataSource({Dio? dio}) : _dio = dio ?? _buildDio();

  static const String _logName = 'app_update';
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
  Future<AppVersionModel?> fetch() async {
    final String platform = DeviceService.platform;
    final String build = AppInfoService.buildNumber;
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
            'Platform': platform,
            'Build-Number': build,
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
