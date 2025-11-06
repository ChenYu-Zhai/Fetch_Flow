// lib/providers/web_cache_manager.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// CacheManager Provider implementation for the web platform.
/// Web 平台的 CacheManager Provider 实现。
Provider<BaseCacheManager> getCacheManagerProvider() {
  // On the web, just return a Provider that provides the DefaultCacheManager.
  // 在 Web 上，直接返回一个提供 DefaultCacheManager 的 Provider 即可。
  return Provider<BaseCacheManager>((ref) {
    debugPrint('[WebCacheManager] Creating DefaultCacheManager for web.');
    return DefaultCacheManager();
  });
}
