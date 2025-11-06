// lib/services/civitai_api_service.dart

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

// Move the Dio Provider here as it is closely related to the API Service.
// 将 Dio Provider 移到这里，因为它与 API Service 紧密相关。
final dioProvider = Provider<Dio>((ref) {
  return Dio(BaseOptions(baseUrl: 'https://civitai.com/api/v1'));
});

// Create a Provider for the ApiService.
// 创建 ApiService 的 Provider。
final civitaiApiServiceProvider = Provider<CivitaiApiService>((ref) {
  final dio = ref.watch(dioProvider);
  return CivitaiApiService(dio, ref);
});

// Define the ApiService class.
// 定义 ApiService 类。
class CivitaiApiService {
  final Dio _dio;
  final Ref _ref;

  CivitaiApiService(this._dio, this._ref);

  /// Fetches image data from the Civitai API.
  /// 从 Civitai API 获取图片数据。
  Future<Map<String, dynamic>> fetchImages({
    String? cursor,
    required Map<String, dynamic> filters,
  }) async {
    try {
      final authState = _ref.read(authProvider);
      final String? token = authState.civitaiToken;

      final queryParameters = {
        ...filters,
        if (cursor != null) 'cursor': cursor,
      };

      queryParameters.removeWhere((key, value) => value == null);
      final url = _dio.options.baseUrl + '/images';
      final uri = Uri.parse(url).replace(
        queryParameters: queryParameters.map((k, v) => MapEntry(k, v.toString())),
      );
      debugPrint('Requesting URL: $uri');
      final response = await _dio.get(
        '/images',
        queryParameters: queryParameters,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.data is Map<String, dynamic>) {
        debugPrint('Civitai API Response: ${response.data.toString().substring(0, 200)}');
        return response.data;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Invalid response format: Expected a JSON object.',
        );
      }
    } on DioException catch (e, stackTrace) {
      debugPrint('DioException in fetchImages: $e\n$stackTrace');
      rethrow;
    } catch (e, stackTrace) {
      debugPrint('Error in fetchImages: $e\n$stackTrace');
      throw DioException(
        requestOptions: RequestOptions(path: '/images'),
        error: e,
        message: 'An unexpected error occurred in ApiService.',
      );
    }
  }
}
