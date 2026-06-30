import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_constants.dart';

class ApiClient {
  late final Dio _dio;
  final FlutterSecureStorage _storage;

  ApiClient({required FlutterSecureStorage storage}) : _storage = storage {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'access_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        // Handle token refresh logic here if 401
        if (e.response?.statusCode == 401) {
          final refreshToken = await _storage.read(key: 'refresh_token');
          if (refreshToken != null) {
            try {
              // Try to refresh
              final refreshResponse = await Dio().post(
                '${ApiConstants.baseUrl}${ApiConstants.refresh}',
                data: {'refresh_token': refreshToken},
              );
              
              if (refreshResponse.statusCode == 200) {
                final newAccess = refreshResponse.data['access_token'];
                final newRefresh = refreshResponse.data['refresh_token'];
                
                await _storage.write(key: 'access_token', value: newAccess);
                await _storage.write(key: 'refresh_token', value: newRefresh);
                
                // Retry the original request
                final opts = Options(
                  method: e.requestOptions.method,
                  headers: e.requestOptions.headers,
                );
                opts.headers?['Authorization'] = 'Bearer $newAccess';
                
                final cloneReq = await _dio.request(
                  e.requestOptions.path,
                  options: opts,
                  data: e.requestOptions.data,
                  queryParameters: e.requestOptions.queryParameters,
                );
                
                return handler.resolve(cloneReq);
              }
            } catch (_) {
              // Refresh failed, clear tokens and let the error pass
              await _storage.deleteAll();
            }
          }
        }
        return handler.next(e);
      },
    ));
  }

  Dio get dio => _dio;
}
