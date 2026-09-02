import 'package:dio/dio.dart';
import '../services/dio_service.dart';
import '../utils/error_mapper.dart';
import 'api_envelope.dart';
import 'paginated_result.dart';

class ApiClient {
  const ApiClient();

  Future<ApiEnvelope> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) => _send(() => DioService.get(path, queryParameters: queryParameters));

  Future<ApiEnvelope> post(String path, {Object? data}) =>
      _send(() => DioService.post(path, data: data));

  Future<ApiEnvelope> put(String path, {Object? data}) =>
      _send(() => DioService.put(path, data: data));

  Future<ApiEnvelope> patch(String path, {Object? data}) =>
      _send(() => DioService.patch(path, data: data));

  Future<ApiEnvelope> delete(String path) =>
      _send(() => DioService.delete(path));

  Future<T> getObject<T>(
    String path,
    T Function(Map<String, dynamic> data) parse, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final ApiEnvelope envelope = await get(
      path,
      queryParameters: queryParameters,
    );
    return parse(envelope.dataMap);
  }

  Future<PaginatedResult<T>> getPage<T>(
    String path,
    T Function(Map<String, dynamic> json) parse, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final ApiEnvelope envelope = await get(
      path,
      queryParameters: queryParameters,
    );
    return PaginatedResult<T>.fromDynamic(envelope.data, parse);
  }

  Future<ApiEnvelope> _send(
    Future<Response<dynamic>> Function() request,
  ) async {
    try {
      final Response<dynamic> response = await request();
      final dynamic body = response.data;

      if (body is! Map) {
        throw const AppException('something_went_wrong');
      }

      final ApiEnvelope envelope = ApiEnvelope.fromJson(
        Map<String, dynamic>.from(body),
      );

      if (!envelope.isSuccess) {
        throw ErrorMapper.fromEnvelope(
          envelope,
          statusCode: response.statusCode,
        );
      }

      return envelope;
    } catch (error) {
      throw ErrorMapper.toException(error);
    }
  }
}
