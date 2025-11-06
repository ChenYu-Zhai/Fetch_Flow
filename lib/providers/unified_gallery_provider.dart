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

// Defines the generic state for the gallery.
// 定义通用的 GalleryState。
@freezed
class GalleryState with _$GalleryState {
  const factory GalleryState({
    @Default([]) List<UnifiedPostModel> posts,
    Object? nextToken,
    @Default(true) bool hasMore,
    @Default({}) Map<String, dynamic> filters,
    @Default(false) bool isLoadingNextPage,
  }) = _GalleryState;
}

// Defines the generic UnifiedGalleryNotifier.
// 定义通用的 UnifiedGalleryNotifier。
class UnifiedGalleryNotifier extends StateNotifier<AsyncValue<GalleryState>> {
  final BaseRepository _repository;
  final String _sourceId;
  final Map<String, dynamic> _initialFilters;

  UnifiedGalleryNotifier(
    this._repository,
    this._sourceId,
    this._initialFilters,
  ) : super(const AsyncValue.loading()) {
    initialize();
  }

  void initialize() {
    applyFiltersAndRefresh(_initialFilters);
  }

  Future<void> fetchFirstPage() async {
    if (!mounted) return;
    state = const AsyncValue.loading();
    await _fetchData(isRefreshing: true);
  }

  Future<void> fetchNextPage() async {
    if (state.asData == null ||
        !state.asData!.value.hasMore ||
        state.asData!.value.isLoadingNextPage) {
      return;
    }
    state = AsyncValue.data(
      state.asData!.value.copyWith(isLoadingNextPage: true),
    );
    await _fetchData(isRefreshing: false);
  }

  Future<void> applyFiltersAndRefresh(Map<String, dynamic> newFilters) async {
    if (!mounted) return;
    state = AsyncValue.loading();
    await _fetchData(newFilters: newFilters, isRefreshing: true);
  }

  Future<void> refresh() async {
    if (!mounted) return;

    final Map<String, dynamic> filtersToUse =
        state.asData?.value.filters ?? _initialFilters;

    state = AsyncValue.loading();

    await _fetchData(newFilters: filtersToUse, isRefreshing: true);
  }

  Future<void> _fetchData({
    Map<String, dynamic>? newFilters,
    bool isRefreshing = false,
  }) async {
    debugPrint(
      '[_fetchData] Source: $_sourceId, Refreshing: $isRefreshing, NewFilters: $newFilters',
    );
    const maxRetries = 3;
    const initialDelay = Duration(seconds: 1);

    for (int attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        final oldState = state.asData?.value;
        final token = isRefreshing ? null : oldState?.nextToken;
        final filters = newFilters ?? oldState?.filters ?? {};

        debugPrint(
          '[_fetchData] Attempt: $attempt, Token: $token, Filters: $filters',
        );
        final (newPosts, nextToken) = await _repository.getPosts(
          paginationToken: token,
          filters: filters,
        );
        debugPrint(
          '[_fetchData] Success on attempt $attempt. New posts: ${newPosts.length}, NextToken: $nextToken',
        );

        if (mounted) {
          if (isRefreshing) {
            final newState = GalleryState(
              posts: newPosts,
              nextToken: nextToken,
              hasMore: newPosts.isNotEmpty && nextToken != null,
              filters: filters,
              isLoadingNextPage: false,
            );
            state = AsyncValue.data(newState);
          } else {
            if (oldState != null) {
              state = AsyncValue.data(
                oldState.copyWith(
                  posts: [...oldState.posts, ...newPosts],
                  nextToken: nextToken,
                  hasMore: newPosts.isNotEmpty && nextToken != null,
                  isLoadingNextPage: false,
                ),
              );
            }
          }
        }
        return;
      } catch (e, st) {
        debugPrint('[_fetchData] Failed on attempt $attempt. Error: $e');

        if (attempt == maxRetries) {
          if (mounted) {
            if (isRefreshing || state.asData == null) {
              state = AsyncValue.error(e, st);
            } else {
              state = AsyncValue.data(
                state.asData!.value.copyWith(isLoadingNextPage: false),
              );
            }
          }
          return;
        }

        final delay = initialDelay * pow(2, attempt);
        debugPrint('[_fetchData] Retrying after $delay...');
        await Future.delayed(delay);
      }
    }
  }
}

// Dynamically creates a repository based on the source ID.
// 根据 sourceId 动态创建 Repository。
final repositoryProviderFactory = Provider.family<BaseRepository, String>((
  ref,
  sourceId,
) {
  switch (sourceId) {
    case 'civitai':
      return ref.watch(civitaiRepositoryProvider);
    case 'rule34':
      return ref.watch(rule34RepositoryProvider);
    default:
      throw UnimplementedError('No repository found for source: $sourceId');
  }
});

// The final, externally exposed generic provider.
// 最终的、对外暴露的通用 Provider。
final unifiedGalleryProvider = StateNotifierProvider.autoDispose
    .family<UnifiedGalleryNotifier, AsyncValue<GalleryState>, String>((
      ref,
      sourceId,
    ) {
      final repository = ref.watch(repositoryProviderFactory(sourceId));
      Map<String, dynamic> initialFilters = {};
      // Be sure to provide initial data when adding a new data source.
      // 务必在新添加数据源时提供初始化数据。
      if (sourceId == 'civitai') {
        initialFilters = const CivitaiFilterState().toApiParams();
      }
      else if (sourceId == 'rule34') {
        initialFilters = {'tags': ''};
      }
      return UnifiedGalleryNotifier(repository, sourceId, initialFilters);
    });
