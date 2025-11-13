// lib/services/rule34_api_service.dart

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

final rule34DioProvider = Provider(
  (ref) => Dio(BaseOptions(baseUrl: 'https://api.rule34.xxx')),
);

final rule34ApiServiceProvider = Provider<Rule34ApiService>((ref) {
  final dio = ref.watch(rule34DioProvider);
  return Rule34ApiService(dio, ref);
});

class Rule34ApiService {
  final Dio _dio;
  final Ref _ref;

  Rule34ApiService(this._dio, this._ref);

  /// Fetches a list of posts from the Rule34 API.
  /// Rule34 returns a JSON Array string directly, which is ideal for background parsing.
  /// 从 Rule34 API 获取帖子列表。
  /// Rule34 直接返回一个 JSON Array 字符串，非常适合后台解析。
  Future<List<dynamic>> fetchPostsAsList({
    required int page,
    required String tags,
  }) async {
    final authState = _ref.read(authProvider);
    final apiKey = authState.rule34Token;
    final userId = authState.rule34UserId;

    try {
      final queryParameters = {
        'page': 'dapi',
        's': 'post',
        'q': 'index',
        'json': 1,
        'pid': page,
        'limit': 200,
        'tags': tags,
        'api_key': apiKey,
        'user_id': userId,
      };
      final uri = Uri.parse(_dio.options.baseUrl + '/index.php').replace(
        queryParameters: queryParameters.map(
          (k, v) => MapEntry(k, v.toString()),
        ),
      );
      debugPrint('Requesting URL: $uri');
      final response = await _dio.get<List<dynamic>>(
        '/index.php',
        queryParameters: queryParameters,
        options: Options(responseType: ResponseType.json),
      );
      debugPrint(
        'Rule34 API Response: ${response.data.toString().substring(0, 200)}',
      );
      return response.data ?? [];
    } on DioException catch (e, stackTrace) {
      debugPrint('DioException in fetchPostsAsList: $e\n$stackTrace');
      return [];
    }
  }
}
