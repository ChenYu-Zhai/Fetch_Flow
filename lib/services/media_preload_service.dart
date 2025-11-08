// lib/services/media_preload_service.dart

import 'dart:async';
import 'dart:ui';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/unified_post_model.dart';
import '../providers/video_controller_provider.dart';
import 'dart:developer' as developer;

/// ✅ 增强的 Provider，支持手动清理
final mediaPreloadServiceProvider = Provider<MediaPreloadService>((ref) {
  final service = MediaPreloadService(ref);

  // ✅ 监听应用生命周期，后台时清理资源
  ref.listen(appLifecycleProvider, (prev, next) {
    if (next == AppLifecycleState.paused) {
      service.clearCache();
    }
  });

  return service;
});

/// ✅ 新增：应用生命周期 Provider（需放在全局位置）
final appLifecycleProvider = StateProvider<AppLifecycleState>((ref) {
  return AppLifecycleState.resumed;
});

class MediaPreloadService {
  final Ref _ref;

  /// ✅ LRU 缓存：存储 URL + 时间戳（仅图片）
  final _preloadCache = <String, DateTime>{};

  /// ✅ 正在加载中的 URL 集合（防止重复加载）
  final _loadingUrls = <String>{};

  /// ✅ 缓存统计
  final _stats = PreloadStats();

  static const int _maxCacheSize = 200; // 增加缓存上限
  static const int _batchSize = 5;

  static final _cacheManager = DefaultCacheManager();

  MediaPreloadService(this._ref);

  /// ✅ 核心方法：预加载单个媒体
  Future<void> preload(UnifiedPostModel post) async {
    final String url = post.previewImageUrl;

    if (url.isEmpty) return;

    // 1. 去重检查（内存 + 磁盘）
    if (await _isAlreadyPreloaded(url)) {
      _stats.hitCount++;
      debugPrint('📦 [MediaPreloadService] Cache HIT: ${post.id}');
      return;
    }

    // 2. 避免并发重复加载
    if (_loadingUrls.contains(url)) {
      debugPrint('⏳ [MediaPreloadService] Already loading: ${post.id}');
      return;
    }

    _loadingUrls.add(url);
    _stats.missCount++;
    debugPrint(
      '📥 [MediaPreloadService] Cache MISS: ${post.id}, type: ${post.mediaType}',
    );

    try {
      switch (post.mediaType) {
        case MediaType.image:
        case MediaType.gif:
          await _preloadImage(url);
          break;
        case MediaType.video:

          /// ✅ 关键修复：视频不预加载，跳过
          /// 视频播放完全由 UnifiedMediaCard 控制，避免后台播放
          debugPrint('⏭️ [MediaPreloadService] SKIP video preload: ${post.id}');
          break;
      }

      // ✅ 添加到缓存
      _preloadCache[url] = DateTime.now();
      _enforceCacheLimit(); // 检查缓存上限

      debugPrint('✅ [MediaPreloadService] Preloaded successfully: ${post.id}');
    } catch (e) {
      debugPrint('❌ [MediaPreloadService] Failed to preload ${post.id}: $e');
      _preloadCache.remove(url); // 失败时移除
    } finally {
      _loadingUrls.remove(url);
    }
  }

  /// ✅ 批量预加载（异步，不阻塞UI）
  Future<void> preloadPosts(Iterable<UnifiedPostModel> posts) async {
    final postsToLoad = posts
        .where(
          (p) => p.previewImageUrl.isNotEmpty && p.mediaType != MediaType.video,
        )
        .take(_batchSize);

    if (postsToLoad.isEmpty) return;

    debugPrint(
      '📦 [MediaPreloadService] Batch preload start: ${postsToLoad.length} items',
    );
    for (final post in postsToLoad) {
      // preload 本身是异步的，所以这里会自然地处理事件循环
      await preload(post);
      // 在每个网络请求之间加入一个小的延迟，可以防止瞬间发出大量请求，这是个好习惯
      await Future.delayed(const Duration(milliseconds: 10));
    }

    _stats.batchCount++;
    debugPrint(
      '📦 [MediaPreloadService] Batch preload complete. Stats: $_stats',
    );
  }

  /// ✅ 预加载图片（带超时保护）
  Future<void> _preloadImage(String url) async {
    try {
      if (kIsWeb) {
        await _cacheManager
            .getFileStream(url)
            .timeout(const Duration(seconds: 10))
            .drain();
      } else {
        await _cacheManager
            .downloadFile(url)
            .timeout(const Duration(seconds: 15));
      }
    } on TimeoutException {
      debugPrint('⏱️ [MediaPreloadService] Image preload timeout: $url');
      throw Exception('Preload timeout');
    }
  }

  /// ✅ LRU 缓存淘汰
  void _enforceCacheLimit() {
    if (_preloadCache.length <= _maxCacheSize) return;

    final sorted = _preloadCache.entries.sortedBy((e) => e.value);
    final toRemove = sorted.take(_preloadCache.length - _maxCacheSize).toList();

    for (final entry in toRemove) {
      final url = entry.key;
      _preloadCache.remove(url);
      debugPrint('🗑️ [MediaPreloadService] Evicted cache: $url');
    }
  }

  /// ✅ 手动清理缓存
  void clearCache() {
    debugPrint('🧹 [MediaPreloadService] Clearing all cache...');
    _preloadCache.clear();
    _loadingUrls.clear();
    _stats.reset();
  }

  /// ✅ 缓存状态查询
  bool hasPreloaded(String url) {
    return _preloadCache.containsKey(url) || _loadingUrls.contains(url);
  }

  /// ✅ 检查是否已预加载（内存或磁盘）
  Future<bool> _isAlreadyPreloaded(String url) async {
    // 1. 内存缓存检查
    if (_preloadCache.containsKey(url)) return true;

    // 2. 磁盘缓存检查
    try {
      final file = await _cacheManager.getFileFromCache(url);
      return file != null && file.file.existsSync();
    } catch (_) {
      return false;
    }
  }

  /// ✅ 获取统计信息（用于监控）
  PreloadStats get stats => _stats;
}

/// ✅ 缓存统计类
class PreloadStats {
  int hitCount = 0;
  int missCount = 0;
  int batchCount = 0;

  double get hitRate =>
      (hitCount + missCount) == 0 ? 0 : hitCount / (hitCount + missCount);

  void reset() {
    hitCount = 0;
    missCount = 0;
    batchCount = 0;
  }

  @override
  String toString() =>
      'PreloadStats(hitRate: ${(hitRate * 100).toStringAsFixed(1)}%, '
      'active: $hitCount, missed: $missCount, batches: $batchCount)';
}
