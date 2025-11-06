import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/rule34_post_model.dart';
import '../models/unified_post_model.dart';
import '../services/base_repository.dart';
import '../services/parsing_service.dart';
import '../services/rule34_api_service.dart';

List<Rule34PostModel> _parseRule34Posts(List<dynamic> items) {
  if (items.isEmpty) {
    return [];
  }
  return items.map((json) => Rule34PostModel.fromJson(json)).toList();
}

final rule34RepositoryProvider = Provider<Rule34RepositoryAdapter>((ref) {
  final apiService = ref.watch(rule34ApiServiceProvider);
  final parsingService = ref.watch(parsingServiceProvider);
  return Rule34RepositoryAdapter(apiService, parsingService);
});

class Rule34RepositoryAdapter implements BaseRepository {
  final Rule34ApiService _apiService;
  final ParsingService _parsingService;

  Rule34RepositoryAdapter(this._apiService, this._parsingService);

  @override
  Future<RepositoryResponse> getPosts({
    Object? paginationToken,
    Map<String, dynamic>? filters,
  }) async {
    final page = paginationToken as int? ?? 0;
    final tags = filters?['tags'] as String? ?? '';
    debugPrint('[Rule34Repository] Getting posts... Page: $page, Tags: $tags');

    final postList = await _apiService.fetchPostsAsList(page: page, tags: tags);
    debugPrint('[Rule34Repository] Fetched raw data. Items: ${postList.length}');

    // Parse the JSON string in a background isolate.
    // 在后台 Isolate 中解析 JSON 字符串。
    final rule34Posts = await _parsingService.parseDataInBackground(
      postList,
      _parseRule34Posts, // Pass the top-level parsing function.
    );
    debugPrint('[Rule34Repository] Parsed ${rule34Posts.length} posts.');

    final unifiedPosts = rule34Posts.map(_transform).toList();

    final nextToken = rule34Posts.isNotEmpty ? page + 1 : null;
    debugPrint('[Rule34Repository] Transformed to ${unifiedPosts.length} unified posts. Next token: $nextToken');

    return (unifiedPosts, nextToken);
  }

  // Defines the transformation from Rule34PostModel to UnifiedPostModel.
  // 定义从 Rule34PostModel 到 UnifiedPostModel 的转换函数。
  UnifiedPostModel _transform(Rule34PostModel post) {
    return UnifiedPostModel(
      id: 'rule34-${post.id}',
      source: 'rule34',
      previewImageUrl: _createProxyUrl(post.sampleUrl),
      fullImageUrl: _createProxyUrl(post.fileUrl),
      width: post.width,
      height: post.height,
      score: post.score,
      mediaType: _getMediaTypeFromUrl(post.fileUrl),
      tags: post.tags.split(' ').where((t) => t.isNotEmpty).toList(),
      detailsUrl: 'https://rule34.xxx/index.php?page=post&s=view&id=${post.id}',
      originalData: post.toJson(),
    );
  }

  // Helper function to determine the media type from the URL.
  // 辅助函数：根据URL判断媒体类型。
  MediaType _getMediaTypeFromUrl(String url) {
    final lowercasedUrl = url.toLowerCase();
    if (lowercasedUrl.endsWith('.mp4') || lowercasedUrl.endsWith('.webm')) {
      return MediaType.video;
    }
    if (lowercasedUrl.endsWith('.gif')) {
      return MediaType.gif;
    }
    return MediaType.image;
  }

  // Modify the private method to use your own Worker.
  // 将私有方法修改为使用您自己的 Worker。
  String _createProxyUrl(String originalUrl) {
    if (kIsWeb) {
      const proxyBaseUrl =
          'https://purple-mud-3f6b.a2512312054.workers.dev';

      return '$proxyBaseUrl?url=${Uri.encodeComponent(originalUrl)}';
    }
    return originalUrl;
  }
}
