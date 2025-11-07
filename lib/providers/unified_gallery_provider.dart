// lib/providers/unified_gallery_provider.dart

import 'package:featch_flow/models/civitai_filters.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:featch_flow/models/unified_post_model.dart';
import 'package:featch_flow/repositories/civitai_repository.dart';
import 'package:featch_flow/repositories/rule34_repository.dart';
import 'package:featch_flow/services/base_repository.dart';
import 'dart:math';
part 'unified_gallery_provider.freezed.dart';

/// ✅ 定义帖子唯一标识的扩展
/// 使用 source + id 作为唯一键（createdAt 字段不存在）
extension PostIdentity on UnifiedPostModel {
  String get identityKey => '${source}_$id';
}

/// ✅ 定义通用的 GalleryState
@freezed
class GalleryState with _$GalleryState {
  const factory GalleryState({
    @Default([]) List<UnifiedPostModel> posts,
    Object? nextToken,
    @Default(true) bool hasMore,
    @Default({}) Map<String, dynamic> filters,
    @Default(false) bool isLoadingNextPage,
    @Default(0) int totalFetched, // 跟踪总数
    @Default(0) int lastFetchTime, // 上次获取时间（毫秒）
  }) = _GalleryState;

  /// ✅ Freezed 要求：如果类体中有 getter/method，必须添加私有构造函数
  const GalleryState._();

  /// ✅ 计算去重后的帖子（保持原始顺序）
  List<UnifiedPostModel> get deduplicatedPosts {
    final unique = <String, UnifiedPostModel>{};
    int duplicateCount = 0;
    
    for (final post in posts) {
      if (unique.containsKey(post.identityKey)) {
        duplicateCount++;
      } else {
        unique[post.identityKey] = post;
      }
    }
    
    if (duplicateCount > 0) {
      debugPrint('🧹 [GalleryState] Removed $duplicateCount duplicates');
    }
    
    // 保持 API 返回顺序
    return unique.values.toList();
  }

  /// ✅ 获取实际数量（去重后）
  int get effectiveCount => deduplicatedPosts.length;
}

/// ✅ 定义统一的 Gallery Notifier
class UnifiedGalleryNotifier extends StateNotifier<AsyncValue<GalleryState>> {
  final BaseRepository _repository;
  final String _sourceId;
  final Map<String, dynamic> _initialFilters;

  /// ✅ 并发控制锁
  bool _isFetching = false;

  UnifiedGalleryNotifier(
    this._repository,
    this._sourceId,
    this._initialFilters,
  ) : super(const AsyncValue.loading()) {
    initialize();
  }

  void initialize() {
    debugPrint('🚀 [UnifiedGalleryNotifier] Initializing for $_sourceId');
    applyFiltersAndRefresh(_initialFilters);
  }

  /// ✅ 获取第一页（带并发保护）
  Future<void> fetchFirstPage() async {
    if (_isFetching || !mounted) return;
    
    _isFetching = true;
    state = const AsyncValue.loading();
    
    try {
      await _fetchData(isRefreshing: true);
    } finally {
      _isFetching = false;
    }
  }

  /// ✅ 获取下一页（带三重状态检查）
  Future<void> fetchNextPage() async {
    if (_isFetching) {
      debugPrint('⏳ [UnifiedGalleryNotifier] Fetch already in progress');
      return;
    }

    final currentState = state.asData?.value;
    if (currentState == null || 
        !currentState.hasMore || 
        currentState.isLoadingNextPage) {
      debugPrint('⏭️ [UnifiedGalleryNotifier] Skip fetch (state check)');
      return;
    }

    _isFetching = true;
    state = AsyncValue.data(
      currentState.copyWith(isLoadingNextPage: true),
    );

    try {
      await _fetchData(isRefreshing: false);
    } finally {
      _isFetching = false;
    }
  }

  /// ✅ 应用筛选并刷新
  Future<void> applyFiltersAndRefresh(Map<String, dynamic> newFilters) async {
    if (!mounted) return;
    
    debugPrint('🔄 [UnifiedGalleryNotifier] Applying filters: $newFilters');
    state = const AsyncValue.loading();
    
    try {
      await _fetchData(newFilters: newFilters, isRefreshing: true);
    } catch (e) {
      debugPrint('❌ [UnifiedGalleryNotifier] Filter apply failed: $e');
      rethrow;
    }
  }

  /// ✅ 刷新当前筛选
  Future<void> refresh() async {
    if (!mounted) return;

    final filtersToUse = state.asData?.value.filters ?? _initialFilters;
    debugPrint('🔄 [UnifiedGalleryNotifier] Refreshing with filters: $filtersToUse');
    
    state = const AsyncValue.loading();
    
    try {
      await _fetchData(newFilters: filtersToUse, isRefreshing: true);
    } catch (e) {
      debugPrint('❌ [UnifiedGalleryNotifier] Refresh failed: $e');
      rethrow;
    }
  }

  /// ✅ 核心数据获取方法（带重试、去重、并发控制）
  Future<void> _fetchData({
    Map<String, dynamic>? newFilters,
    bool isRefreshing = false,
  }) async {
    debugPrint(
      '📡 [_fetchData] Source: $_sourceId, Refresh: $isRefreshing, Filters: ${newFilters ?? 'null'}',
    );

    const maxRetries = 3;
    const initialDelay = Duration(seconds: 1);

    for (int attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        final oldState = state.asData?.value;
        final token = isRefreshing ? null : oldState?.nextToken;
        final filters = newFilters ?? oldState?.filters ?? {};

        debugPrint(
          '📡 [_fetchData] Attempt: $attempt, Token: ${token != null ? '...${token.toString().substring(max(0, token.toString().length - 10))}' : 'null'}',
        );

        // 打印即将调用的 repository 信息
        debugPrint(
          '📡 [_fetchData] Calling repository.getPosts() with filters: $filters',
        );

        final (newPosts, nextToken) = await _repository.getPosts(
          paginationToken: token,
          filters: filters,
        );

        debugPrint(
          '✅ [_fetchData] Repository call successful. Raw posts count: ${newPosts.length}, NextToken: ${nextToken != null ? 'present' : 'null'}',
        );

        if (!mounted) {
          debugPrint('⚠️ [_fetchData] Widget disposed before state update');
          return;
        }

        // 打印帖子详情（前3个）用于调试
        if (newPosts.isNotEmpty) {
          debugPrint('📋 [_fetchData] Sample posts (first 3):');
          for (int i = 0; i < min(3, newPosts.length); i++) {
            final post = newPosts[i];
            debugPrint(
              '  [$i] id: ${post.id}, source: ${post.source}, mediaType: ${post.mediaType}, url: ${post.fullImageUrl}',
            );
          }
        }

        // ✅ 合并数据并去重
        final combinedPosts = isRefreshing || oldState == null 
            ? newPosts 
            : [...oldState.posts, ...newPosts];
        
        debugPrint('📊 [_fetchData] Before deduplication: ${combinedPosts.length} posts');
        
        final deduplicated = _deduplicatePosts(combinedPosts);
        
        debugPrint('📊 [_fetchData] After deduplication: ${deduplicated.length} posts');

        final newState = GalleryState(
          posts: deduplicated,
          nextToken: nextToken,
          hasMore: newPosts.isNotEmpty && nextToken != null,
          filters: filters,
          isLoadingNextPage: false,
          totalFetched: deduplicated.length,
          lastFetchTime: DateTime.now().millisecondsSinceEpoch,
        );

        state = AsyncValue.data(newState);

        debugPrint(
          '📊 [_fetchData] State updated successfully: ${newState.effectiveCount} effective posts, hasMore: ${newState.hasMore}',
        );

        return;
      } catch (e, st) {
        debugPrint('❌ [_fetchData] Attempt $attempt failed with exception:');
        debugPrint('  Exception Type: ${e.runtimeType}');
        debugPrint('  Exception Message: $e');
        debugPrint('  Stack trace: $st');

        if (attempt == maxRetries) {
          debugPrint('🔥 [_fetchData] Max retries reached. Final failure.');
          
          if (!mounted) {
            debugPrint('⚠️ [_fetchData] Widget disposed after final failure');
            return;
          }
          
          final oldState = state.asData?.value;
          if (isRefreshing || oldState == null) {
            debugPrint('❌ [_fetchData] Setting error state');
            state = AsyncValue.error(e, st);
          } else {
            debugPrint('⚠️ [_fetchData] Keeping old state, marking loading as false');
            state = AsyncValue.data(
              oldState.copyWith(isLoadingNextPage: false),
            );
          }
          return;
        }

        final delay = initialDelay * pow(2, attempt);
        debugPrint('⏱️ [_fetchData] Retrying after $delay...');
        await Future.delayed(delay);
      }
    }
  }
  

  /// ✅ 帖子去重（基于 identityKey）
  List<UnifiedPostModel> _deduplicatePosts(List<UnifiedPostModel> posts) {
    debugPrint('🧹 [_deduplicatePosts] Starting deduplication for ${posts.length} posts');
    
    final unique = <String, UnifiedPostModel>{};
    int duplicateCount = 0;

    for (int i = 0; i < posts.length; i++) {
      final post = posts[i];
      final key = post.identityKey;
      
      if (unique.containsKey(key)) {
        duplicateCount++;
        debugPrint('🧹 [_deduplicatePosts] Duplicate found at index $i: $key');
      } else {
        unique[key] = post;
      }
    }
    
    if (duplicateCount > 0) {
      debugPrint('🧹 [_deduplicatePosts] Removed $duplicateCount duplicates');
    } else {
      debugPrint('🧹 [_deduplicatePosts] No duplicates found');
    }

    return unique.values.toList();
  }

  /// ✅ 清理所有数据
  void clearAll() {
    debugPrint('🧹 [UnifiedGalleryNotifier] Clearing all data for $_sourceId');
    state = const AsyncValue.data(GalleryState());
  }
}

/// ✅ Repository 工厂
final repositoryProviderFactory = Provider.family<BaseRepository, String>((ref, sourceId) {
  debugPrint('🏭 [repositoryProviderFactory] Creating repository for: $sourceId');
  
  switch (sourceId) {
    case 'civitai':
      final repo = ref.watch(civitaiRepositoryProvider);
      debugPrint('🏭 [repositoryProviderFactory] Returning CivitaiRepository');
      return repo;
    case 'rule34':
      final repo = ref.watch(rule34RepositoryProvider);
      debugPrint('🏭 [repositoryProviderFactory] Returning Rule34Repository');
      return repo;
    default:
      debugPrint('🏭 [repositoryProviderFactory] ERROR: No repository for: $sourceId');
      throw UnimplementedError('No repository for: $sourceId');
  }
});

/// ✅ ✅ 关键修复：移除 autoDispose
final unifiedGalleryProvider = StateNotifierProvider
    .family<UnifiedGalleryNotifier, AsyncValue<GalleryState>, String>(
  (ref, sourceId) {
    debugPrint('🏭 [unifiedGalleryProvider] Creating notifier for: $sourceId');
    
    final repository = ref.watch(repositoryProviderFactory(sourceId));
    
    Map<String, dynamic> initialFilters = {};
    if (sourceId == 'civitai') {
      initialFilters = const CivitaiFilterState().toApiParams();
      debugPrint('🏭 [unifiedGalleryProvider] Civitai initial filters: $initialFilters');
    } else if (sourceId == 'rule34') {
      initialFilters = {'tags': ''};
      debugPrint('🏭 [unifiedGalleryProvider] Rule34 initial filters: $initialFilters');
    }

    return UnifiedGalleryNotifier(repository, sourceId, initialFilters);
  },
);