// lib/repositories/civitai_repository.dart

import 'dart:convert';
import 'package:featch_flow/services/parsing_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/civitai_image_model.dart';
import '../models/unified_post_model.dart';
import '../services/base_repository.dart';
import '../services/civitai_api_service.dart';

// The Repository Provider now depends on the ApiService Provider.
// Repository Provider 现在依赖 ApiService Provider。
final civitaiRepositoryProvider = Provider<CivitaiRepositoryAdapter>((ref) {
  final apiService = ref.watch(civitaiApiServiceProvider);
  final parsingService = ref.watch(parsingServiceProvider);
  return CivitaiRepositoryAdapter(apiService, parsingService);
});

List<CivitaiImageModel> _parseCivitaiImages(Map<String, dynamic> data) {
  final items = data['items'] as List;
  return items.map((json) => CivitaiImageModel.fromJson(json)).toList();
}

// The repository now implements our generic BaseRepository interface.
// Repository 现在实现我们的通用接口 BaseRepository。
class CivitaiRepositoryAdapter implements BaseRepository {
  final CivitaiApiService _apiService;
  final ParsingService _parsingService;

  CivitaiRepositoryAdapter(this._apiService, this._parsingService);

  @override
  Future<RepositoryResponse> getPosts({
    Object? paginationToken,
    Map<String, dynamic>? filters,
  }) async {
    debugPrint(
      '[CivitaiRepository] Getting posts... Token: $paginationToken, Filters: $filters',
    );
    final rawDataMap = await _apiService.fetchImages(
      cursor: paginationToken as String?,
      filters: filters ?? {},
    );
    debugPrint(
      '[CivitaiRepository] Fetched raw data. Items: ${(rawDataMap['items'] as List).length}',
    );

    // Move the parsing of the Map to the background.
    // We now pass the raw Map and the `_parseCivitaiImages` function.
    // 将解析 Map 的过程放到后台。
    // 现在我们传递的是原始 Map 和 `_parseCivitaiImages` 函数。
    final civitaiImages = await _parsingService.parseDataInBackground(
      rawDataMap,
      _parseCivitaiImages,
    );
    debugPrint('[CivitaiRepository] Parsed ${civitaiImages.length} images.');

    final unifiedPosts = civitaiImages.map(_transform).toList();
    final nextCursor = rawDataMap['metadata']?['nextCursor'].toString();
    debugPrint(
      '[CivitaiRepository] Transformed to ${unifiedPosts.length} unified posts. Next cursor: $nextCursor',
    );

    return (unifiedPosts, nextCursor);
  }

  // The transformation function remains unchanged; it is responsible for converting a specific model to a unified model.
  // 转换函数保持不变，它负责将一个具体模型转换为统一模型。
  UnifiedPostModel _transform(CivitaiImageModel image) {
    List<String> extractedTags = [];
    final String? prompt = image.meta?.prompt;
    if (prompt != null && prompt.isNotEmpty) {
      // 简单的解析逻辑：按逗号分割，并清理每个标签
      extractedTags = prompt
          .split(',')
          .map((tag) => tag.trim()) // 去除首尾空格
          // 移除 AI 绘图中的权重符号和括号
          .map((tag) => tag.replaceAll(RegExp(r'[\(\)\[\]\{\}:<>]'), ''))
          .where((tag) => tag.isNotEmpty) // 过滤掉空标签
          .toList();
    }
    // 2. 如果从 prompt 中没有提取到标签，则使用 meta.tags 作为备用
    if (extractedTags.isEmpty) {
      extractedTags = image.meta?.tags ?? [];
    }

    final pureJsonData = jsonDecode(jsonEncode(image.toJson()));
    return UnifiedPostModel(
      id: 'civitai-${image.id}',
      source: 'civitai',
      previewImageUrl: image.thumbnailUrl, // Use your defined smart getter.
      fullImageUrl: image.url,
      width: image.width,
      height: image.height,
      mediaType: image.type,
      tags: extractedTags,
      author: image.username,
      score: image.stats?.likeCount ?? 0,
      detailsUrl: 'https://civitai.com/images/${image.id}',
      originalData: pureJsonData,
    );
  }
}
