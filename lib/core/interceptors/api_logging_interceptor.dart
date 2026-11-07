import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiLoggingInterceptor extends Interceptor {
  ApiLoggingInterceptor({
    this.maxBodyLength = 4000,
    this.logResponseHeaders = true,
  });

  final int maxBodyLength;
  final bool logResponseHeaders;

  static const String _logName = 'API';
  static const String _startTimeKey = '_api_request_start';

  static const Set<String> _sensitiveKeys = <String>{
    'authorization',
    'token',
    'access_token',
    'refresh_token',
    'id_token',
    'auth_token',
    'password',
    'secret',
    'client_secret',
    'api_key',
    'apikey',
    'device_uuid',
    'fcm_token',
    'cookie',
    'set_cookie',
  };

  // ---------------------------------------------------------------------------
  // Logging
  // ---------------------------------------------------------------------------

  void _log(String message) {
    if (!kDebugMode) return;

    developer.log(message, name: _logName);
  }

  void _safeLog(String Function() builder) {
    if (!kDebugMode) return;

    try {
      _log(builder());
    } catch (error, stackTrace) {
      // Logging must never break an API request.
      developer.log(
        'API logging failed: $error',
        name: _logName,
        stackTrace: stackTrace,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Request
  // ---------------------------------------------------------------------------

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      options.extra[_startTimeKey] = Stopwatch()..start();

      _safeLog(() {
        return '''
┌────────────────────────────────────────────
│ 🚀 API REQUEST
├────────────────────────────────────────────
│ METHOD: ${options.method.toUpperCase()}
│ URL: ${options.uri}
│ QUERY: ${_format(_sanitize(options.queryParameters))}
│ HEADERS: ${_format(_sanitize(options.headers))}
│ BODY: ${_format(_sanitizeBody(options.data))}
└────────────────────────────────────────────
''';
      });
    }

    handler.next(options);
  }

  // ---------------------------------------------------------------------------
  // Response
  // ---------------------------------------------------------------------------

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      _safeLog(() {
        final int? elapsed = _elapsed(response.requestOptions);

        return '''
┌────────────────────────────────────────────
│ ✅ API RESPONSE
├────────────────────────────────────────────
│ METHOD: ${response.requestOptions.method}
│ URL: ${response.requestOptions.uri}
│ STATUS: ${response.statusCode}
│ DURATION: ${elapsed ?? 'unknown'} ms
│ HEADERS: ${logResponseHeaders ? _format(_sanitize(response.headers.map)) : 'disabled'}
│ DATA: ${_format(_sanitizeBody(response.data))}
└────────────────────────────────────────────
''';
      });
    }

    handler.next(response);
  }

  // ---------------------------------------------------------------------------
  // Error
  // ---------------------------------------------------------------------------

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      _safeLog(() {
        final int? elapsed = _elapsed(err.requestOptions);

        return '''
┌────────────────────────────────────────────
│ ❌ API ERROR
├────────────────────────────────────────────
│ METHOD: ${err.requestOptions.method}
│ URL: ${err.requestOptions.uri}
│ STATUS: ${err.response?.statusCode ?? 'No response'}
│ TYPE: ${err.type.name}
│ DURATION: ${elapsed ?? 'unknown'} ms
│ MESSAGE: ${err.message}
│ RESPONSE HEADERS: ${logResponseHeaders ? _format(_sanitize(err.response?.headers.map)) : 'disabled'}
│ RESPONSE: ${_format(_sanitizeBody(err.response?.data))}
└────────────────────────────────────────────
''';
      });
    }

    handler.next(err);
  }

  int? _elapsed(RequestOptions options) {
    final Object? value = options.extra[_startTimeKey];

    if (value is! Stopwatch) return null;

    return value.elapsedMilliseconds;
  }

  // ---------------------------------------------------------------------------
  // Sensitive data protection
  // ---------------------------------------------------------------------------

  dynamic _sanitize(dynamic value) {
    if (value is Map) {
      return <String, dynamic>{
        for (final MapEntry<dynamic, dynamic> entry in value.entries)
          entry.key.toString(): _isSensitive(entry.key.toString())
              ? '***REDACTED***'
              : _sanitize(entry.value),
      };
    }

    if (value is List) {
      return value.map(_sanitize).toList();
    }

    return value;
  }

  bool _isSensitive(String key) {
    final String normalized = key
        .toLowerCase()
        .replaceAll('-', '_')
        .replaceAll(' ', '_');

    if (_sensitiveKeys.contains(normalized)) {
      return true;
    }

    // Catch common variations such as:
    // user_access_token, x_api_key, authentication_token.
    return normalized.endsWith('_token') ||
        normalized.endsWith('_secret') ||
        normalized.endsWith('_password') ||
        normalized.endsWith('_api_key') ||
        normalized.startsWith('x_api_key') ||
        normalized == 'authentication';
  }

  // ---------------------------------------------------------------------------
  // Body sanitization
  // ---------------------------------------------------------------------------

  dynamic _sanitizeBody(dynamic data) {
    if (data == null) return null;

    if (data is ResponseBody) {
      return '<Response stream omitted>';
    }

    if (data is FormData) {
      return <String, dynamic>{
        'fields': _sanitize(Map<String, dynamic>.fromEntries(data.fields)),
        'files': data.files.map((entry) {
          return <String, dynamic>{
            'field': entry.key,
            'filename': entry.value.filename,
            'length': entry.value.length,
          };
        }).toList(),
      };
    }

    if (data is MultipartFile || data is List<int> || data is Uint8List) {
      return '<Binary data omitted>';
    }

    if (data is Stream) {
      return '<Stream data omitted>';
    }

    return _sanitize(data);
  }

  // ---------------------------------------------------------------------------
  // Formatting
  // ---------------------------------------------------------------------------

  String _format(dynamic value) {
    if (value == null) return 'null';

    dynamic normalized = value;

    // Decode JSON strings to make logs more readable.
    if (value is String) {
      try {
        normalized = jsonDecode(value);
      } catch (_) {
        normalized = value;
      }
    }

    String output;

    try {
      output = const JsonEncoder.withIndent('  ').convert(normalized);
    } catch (_) {
      output = normalized.toString();
    }

    if (output.length > maxBodyLength) {
      output = '${output.substring(0, maxBodyLength)}... [TRUNCATED]';
    }

    return output;
  }
}
