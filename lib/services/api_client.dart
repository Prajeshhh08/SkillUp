import 'dart:io';
import 'package:dio/dio.dart';
import '../config/api_config.dart';
import 'session_service.dart';

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;
  @override
  String toString() => message;
}

class ApiClient {
  ApiClient._() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 12),
        receiveTimeout: const Duration(seconds: 20),
        headers: {'Content-Type': 'application/json'},
      ),
    );
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await SessionService.instance.accessToken;
          if (token != null && token.trim().isNotEmpty) {
            options.headers['Authorization'] = 'Bearer ${token.trim()}';
          }
          handler.next(options);
        },
        onError: (error, handler) => handler.next(error),
      ),
    );
  }

  ApiClient.custom(this._dio);

  static final instance = ApiClient._();
  late final Dio _dio;

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) => _request(
    () =>
        _dio.get<Map<String, dynamic>>(path, queryParameters: queryParameters),
  );

  Future<List<dynamic>> getList(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) => _requestList(
    () => _dio.get<List<dynamic>>(path, queryParameters: queryParameters),
  );

  Future<Map<String, dynamic>> post(String path, {Object? data}) =>
      _request(() => _dio.post<Map<String, dynamic>>(path, data: data));

  Future<Map<String, dynamic>> patch(String path, {Object? data}) =>
      _request(() => _dio.patch<Map<String, dynamic>>(path, data: data));

  Future<Map<String, dynamic>> delete(String path, {Object? data}) =>
      _request(() => _dio.delete<Map<String, dynamic>>(path, data: data));

  Future<Map<String, dynamic>> _request(
    Future<Response<Map<String, dynamic>>> Function() request,
  ) async {
    try {
      final response = await request();
      return response.data ?? <String, dynamic>{};
    } on DioException catch (error) {
      if (Platform.isAndroid &&
          ApiConfig.definedBaseUrl.isEmpty &&
          (error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.connectionError)) {
        final current = _dio.options.baseUrl;
        final alt = current.contains('127.0.0.1')
            ? current.replaceFirst('127.0.0.1', '10.0.2.2')
            : current.contains('10.0.2.2')
                ? current.replaceFirst('10.0.2.2', '127.0.0.1')
                : null;
        if (alt != null) {
          try {
            _dio.options.baseUrl = alt;
            final response = await request();
            return response.data ?? <String, dynamic>{};
          } catch (_) {
            _dio.options.baseUrl = current;
          }
        }
      }
      throw _parseDioError(error);
    }
  }

  Future<List<dynamic>> _requestList(
    Future<Response<List<dynamic>>> Function() request,
  ) async {
    try {
      final response = await request();
      return response.data ?? <dynamic>[];
    } on DioException catch (error) {
      if (Platform.isAndroid &&
          ApiConfig.definedBaseUrl.isEmpty &&
          (error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.connectionError)) {
        final current = _dio.options.baseUrl;
        final alt = current.contains('127.0.0.1')
            ? current.replaceFirst('127.0.0.1', '10.0.2.2')
            : current.contains('10.0.2.2')
                ? current.replaceFirst('10.0.2.2', '127.0.0.1')
                : null;
        if (alt != null) {
          try {
            _dio.options.baseUrl = alt;
            final response = await request();
            return response.data ?? <dynamic>[];
          } catch (_) {
            _dio.options.baseUrl = current;
          }
        }
      }
      throw _parseDioError(error);
    }
  }

  ApiException _parseDioError(DioException error) {
    final data = error.response?.data;
    String message =
        'Unable to connect to SkillUp. Check that the backend is running.';
    if (data is Map<String, dynamic>) {
      final detail = data['detail'];
      if (detail is String) {
        message = detail;
      } else if (detail is List && detail.isNotEmpty) {
        final first = detail.first;
        if (first is Map && first.containsKey('msg')) {
          message = first['msg'].toString();
        } else {
          message = detail.map((e) => e.toString()).join(', ');
        }
      } else if (data['message'] != null) {
        message = data['message'].toString();
      } else {
        message = 'Something went wrong.';
      }
    } else if (data is String && data.isNotEmpty) {
      message = data;
    }
    return ApiException(message, statusCode: error.response?.statusCode);
  }
}
