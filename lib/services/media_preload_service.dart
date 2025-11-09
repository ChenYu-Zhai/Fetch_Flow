// lib/services/media_preload_service.dart

import 'dart:async';
import 'dart:ui';
import 'package:collection/collection.dart';
import 'package:featch_flow/utils/task_queue.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/unified_post_model.dart';
import '../providers/video_controller_provider.dart';
import 'dart:developer' as developer;

final mediaPreloadServiceProvider = Provider<MediaPreloadService>((ref) {
  final service = MediaPreloadService(ref);

  ref.listen(appLifecycleProvider, (prev, next) {
    if (next == AppLifecycleState.paused) {
      service.clearCache();
    }
  });

  return service;
});

final appLifecycleProvider = StateProvider<AppLifecycleState>((ref) {
  return AppLifecycleState.resumed;
});

class MediaPreloadService {
  final Ref _ref;

  final _preloadCache = <String, DateTime>{};

  final _loadingUrls = <String>{};

  final _stats = PreloadStats();

  static const int _maxCacheSize = 200; // 增加缓存上限
  static const int _batchSize = 5;

  static final _cacheManager = DefaultCacheManager();

  MediaPreloadService(this._ref);

  /// ✅ 核心方法：预加载单个媒体 → 改为使用队列提交
  Future<void> preload(UnifiedPostModel post) async {
    final String url = post.previewImageUrl;
    if (url.isEmpty) return;

    if (await _isAlreadyPreloaded(url)) {
      _stats.hitCount++;
      debugPrint('📦 [MediaPreloadService] Cache HIT: ${post.id}');
      return;
    }

    if (_loadingUrls.contains(url)) {
      debugPrint('⏳ [MediaPreloadService] Already loading: ${post.id}');
      return;
    }

    // 提交给并发池，不阻塞主线程
    PreloadTaskQueue.instance.submit(() async {
      _loadingUrls.add(url);
      _stats.missCount++;

      try {
        switch (post.mediaType) {
          case MediaType.image:
          case MediaType.gif:
            await _preloadImage(url);
            break;
          case MediaType.video:
            debugPrint(
              '⏭️ [MediaPreloadService] SKIP video preload: ${post.id}',
            );
            break;
        }

        _preloadCache[url] = DateTime.now();
        _enforceCacheLimit();

        debugPrint(
          '✅ [MediaPreloadService] Preloaded successfully: ${post.id}',
        );
      } catch (e, s) {
        debugPrint(
          '❌ [MediaPreloadService] Failed to preload ${post.id}: $e\n$s',
        );
        _preloadCache.remove(url);
      } finally {
        _loadingUrls.remove(url);
      }
    });
  }

  /// ⏱️ 不再 delay，一次性全部提交
  Future<void> preloadPosts(Iterable<UnifiedPostModel> posts) async {
    final eligiblePosts = posts.where(
      (p) => p.previewImageUrl.isNotEmpty && p.mediaType != MediaType.video,
    );

    if (eligiblePosts.isEmpty) return;

    debugPrint(
      '📦 [MediaPreloadService] Batch preload: Submitting ${eligiblePosts.length} items',
    );

    for (final post in eligiblePosts) {
      // 直接提交到异步队列，避免阻塞
      PreloadTaskQueue.instance.submit(() => preload(post));
    }
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
