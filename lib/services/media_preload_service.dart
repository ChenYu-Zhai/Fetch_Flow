// lib/services/media_preload_service.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/unified_post_model.dart';
import '../providers/video_controller_provider.dart';
import 'dart:developer' as developer;

// 1. 【核心改造】Provider 现在需要注入 Ref
final mediaPreloadServiceProvider = Provider<MediaPreloadService>((ref) {
  // 将 ref 注入到 Service 的构造函数中
  return MediaPreloadService(ref);
});

class MediaPreloadService {
  final Ref _ref; // 2. Service 持有 Ref
  final _preloadedUrls = <String>{};
  final _cacheManager = DefaultCacheManager();

  // 3. 修改构造函数
  MediaPreloadService(this._ref);

  void preload(UnifiedPostModel post) {
    final preloadUrl = post.previewImageUrl;

    if (_preloadedUrls.contains(preloadUrl) || preloadUrl.isEmpty) {
      return;
    }
    _preloadedUrls.add(preloadUrl);
    debugPrint(
      '[MediaPreloadService] Preloading media for post: ${post.id}, url: $preloadUrl',
    );

    switch (post.mediaType) {
      case MediaType.image:
      case MediaType.gif:
        _safeDownloadFile(preloadUrl);
        break;
      case MediaType.video:
        _safePreloadVideo(post.fullImageUrl, _ref);
        break;
    }
  }

  Future<void> _safeDownloadFile(String url) async {
    try {
      if (kIsWeb) {
        await _cacheManager
            .getFileStream(url)
            .timeout(const Duration(seconds: 10));
      } else {
        await _cacheManager.downloadFile(url);
      }
      debugPrint('[MediaPreloadService] Successfully preloaded file: $url');
    } catch (e, stack) {
      developer.log('Failed to preload media from $url: $e');
      if (kDebugMode) {
        print('Stack trace: $stack');
      }
      debugPrint(
        '[MediaPreloadService] Failed to preload file: $url, error: $e',
      );
      _preloadedUrls.remove(url);
    }
  }
  void preloadPosts(Iterable<UnifiedPostModel> posts) {
    for (final post in posts) {
      preload(post);
    }
  }
  void _safePreloadVideo(String videoUrl, Ref ref) {
    try {
      debugPrint('[MediaPreloadService] Preloading video: $videoUrl');
      if (kIsWeb) {
        _preloadVideoForWeb(videoUrl, ref);
      } else {
        ref.read(
          videoControllerProvider(
            VideoPlayerConfig(videoUrl: videoUrl, autoplay: true, loop: true),
          ),
        );
      }
    } catch (e, stack) {
      developer.log('Failed to preload video from $videoUrl: $e');
      if (kDebugMode) {
        developer.log('Stack trace: $stack');
      }
      debugPrint(
        '[MediaPreloadService] Failed to preload video: $videoUrl, error: $e',
      );
      _preloadedUrls.remove(videoUrl);
    }
  }

  void _preloadVideoForWeb(String videoUrl, Ref ref) {
    debugPrint('[MediaPreloadService] Preloading video for web: $videoUrl');
    ref.read(
      videoControllerProvider(
        VideoPlayerConfig(videoUrl: videoUrl, autoplay: true, loop: true),
      ),
    );
  }

  void clearCache() {
    debugPrint('[MediaPreloadService] Clearing preload cache.');
    _preloadedUrls.clear();
  }

  bool hasPreloaded(String url) {
    return _preloadedUrls.contains(url);
  }
}
