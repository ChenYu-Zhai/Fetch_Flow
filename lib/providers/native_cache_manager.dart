// lib/providers/native_cache_manager.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/io_client.dart';

/// CacheManager Provider implementation for native platforms (Mobile/Desktop).
/// 原生平台 (Mobile/Desktop) 的 CacheManager Provider 实现。
Provider<BaseCacheManager> getCacheManagerProvider() {
  // This is the logic we previously wrote for the desktop.
  // 这是我们之前为桌面端编写的逻辑。
  return Provider<BaseCacheManager>((ref) {
    const browserUserAgent =
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36';

    // Debugging information: Print a log when the cache manager is created in development mode.
    // In a production environment, these logs are usually removed or disabled through build configurations.
    // 调试信息：在开发模式下打印缓存管理器创建的日志。
    // 在生产环境中，这些日志通常会被移除或通过构建配置禁用。
    debugPrint('[NativeCacheManager] Creating CacheManager with user agent: $browserUserAgent');

    return CacheManager(
      Config(
        'customImageCacheKey',
        stalePeriod: const Duration(days: 15),
        maxNrOfCacheObjects: 200,
        fileService: HttpFileService(
          httpClient: IOClient(HttpClient()..userAgent = browserUserAgent),
        ),
      ),
    );
  });
}
