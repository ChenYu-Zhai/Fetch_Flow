// lib/providers/cache_manager_provider.dart

// Use conditional import to provide the correct cache manager for each platform.
// 使用条件导入为每个平台提供正确的缓存管理器。
import 'native_cache_manager.dart'
    if (dart.library.html) 'web_cache_manager.dart';

// This provider is now a proxy, and its concrete implementation is determined by the conditional import above.
// 这个 Provider 现在是一个代理，它的具体实现由上面的条件导入决定。
final customCacheManagerProvider = getCacheManagerProvider();
