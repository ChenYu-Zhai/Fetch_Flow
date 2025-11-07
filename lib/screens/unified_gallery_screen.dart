// lib/screens/unified_gallery_screen.dart

import 'dart:async';
import 'dart:math';
import 'package:featch_flow/providers/floating_preview_provider.dart';
import 'package:featch_flow/providers/unified_gallery_provider.dart';
import 'package:featch_flow/widgets/floating_preview_content.dart';
import 'package:featch_flow/widgets/unified_media_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:featch_flow/services/media_preload_service.dart';
import 'package:featch_flow/providers/settings_provider.dart';

class UnifiedGalleryScreen extends ConsumerStatefulWidget {
  final String sourceId;
  const UnifiedGalleryScreen({super.key, required this.sourceId});

  @override
  ConsumerState<UnifiedGalleryScreen> createState() =>
      _UnifiedGalleryScreenState();
}

class _UnifiedGalleryScreenState extends ConsumerState<UnifiedGalleryScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isFetching = false;
  Timer? _fetchThrottleTimer;
  Timer? _preloadThrottleTimer;
  int _lastPreloadIndex = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    debugPrint(
      '[UnifiedGalleryScreen] ✅ Initialized for source: ${widget.sourceId}',
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fetchThrottleTimer?.cancel();
    _preloadThrottleTimer?.cancel();
    debugPrint(
      '[UnifiedGalleryScreen] 🗑️ Disposed for source: ${widget.sourceId}',
    );
    super.dispose();
  }

  void _onScroll() {
    // ✅ 添加滚动位置调试
    final pixels = _scrollController.position.pixels;
    final maxPixels = _scrollController.position.maxScrollExtent;
    
    if (pixels >= maxPixels * 0.7) {
      debugPrint('📜 [UnifiedGalleryScreen] Scroll threshold reached: ${(pixels/maxPixels*100).toStringAsFixed(1)}%');
      _fetchNextPageThrottled();
      _scheduleMediaPreload();
    }
  }

  void _scheduleMediaPreload() {
    if (_preloadThrottleTimer?.isActive ?? false) return;
    
    final delay = ref.watch(preloadDelayProvider);
    debugPrint('⏱️ [UnifiedGalleryScreen] Scheduling preload after ${delay}ms');
    
    _preloadThrottleTimer = Timer(Duration(milliseconds: delay), () async {
      final state = ref.read(unifiedGalleryProvider(widget.sourceId)).asData?.value;
      if (state == null) {
        debugPrint('⚠️ [UnifiedGalleryScreen] Skip preload: state is null');
        return;
      }

      // ✅ 空值检查：确保列表不为空
      if (state.posts.isEmpty) {
        debugPrint('⚠️ [UnifiedGalleryScreen] Skip preload: posts list is empty');
        return;
      }

      final cardHeight = ref.watch(cardHeightProvider);
      final firstIndex = (_scrollController.position.pixels / cardHeight).floor() * 2;
      
      if (firstIndex < _lastPreloadIndex) {
        debugPrint('⏭️ [UnifiedGalleryScreen] Skip preload: index not advanced');
        return;
      }

      final start = max(0, firstIndex - 5);
      final end = min(state.posts.length, firstIndex + 10);
      
      // ✅ 安全截取子列表
      if (start >= end || start >= state.posts.length) {
        debugPrint('⚠️ [UnifiedGalleryScreen] Invalid preload range: $start..$end');
        return;
      }

      _lastPreloadIndex = firstIndex;
      final postsToPreload = state.posts.sublist(start, end);

      debugPrint('🎯 [UnifiedGalleryScreen] Preloading posts $start..$end (${postsToPreload.length} items)');

      // ✅ 过滤无效帖子（id 或 url 为 null）
      final validPosts = postsToPreload.where((post) {
        final isValid = post.id != null && post.fullImageUrl != null;
        if (!isValid) {
          debugPrint('🚫 [UnifiedGalleryScreen] Skipping invalid post: id=${post.id}, url=${post.fullImageUrl}');
        }
        return isValid;
      }).toList();

      if (validPosts.isNotEmpty) {
        await Future.microtask(() {
          ref.read(mediaPreloadServiceProvider).preloadPosts(validPosts);
        });
        debugPrint('✅ [UnifiedGalleryScreen] Preloaded ${validPosts.length} valid posts');
      } else {
        debugPrint('⚠️ [UnifiedGalleryScreen] No valid posts to preload');
      }
    });
  }

  void _fetchNextPageThrottled() {
    if (_fetchThrottleTimer?.isActive ?? false) return;
    
    _fetchThrottleTimer = Timer(const Duration(milliseconds: 500), () {
      final state = ref.read(unifiedGalleryProvider(widget.sourceId));
      
      // ✅ 更健壮的 null 检查
      final hasMore = state.asData?.value.hasMore ?? false;
      final isLoading = state.asData?.value.isLoadingNextPage ?? false;
      
      debugPrint('📡 [UnifiedGalleryScreen] Fetch check: hasMore=$hasMore, isLoading=$isLoading');
      
      if (hasMore && !isLoading) {
        debugPrint('⬇️ [UnifiedGalleryScreen] Fetching next page...');
        ref.read(unifiedGalleryProvider(widget.sourceId).notifier).fetchNextPage();
      } else {
        debugPrint('⏭️ [UnifiedGalleryScreen] Skip fetch: hasMore=$hasMore, isLoading=$isLoading');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final galleryStateAsync = ref.watch(unifiedGalleryProvider(widget.sourceId));
    final floatingPost = ref.watch(floatingPostProvider);

    return Scaffold(
      body: Stack(
        children: [
          // ✅ 使用 when() 处理异步状态
          galleryStateAsync.when(
            data: (state) {
              debugPrint('📊 [UnifiedGalleryScreen] Building with ${state.posts.length} posts');
              return _buildGridView(state);
            },
            error: (e, st) {
              debugPrint('❌ [UnifiedGalleryScreen] Error: $e');
              debugPrint('❌ [UnifiedGalleryScreen] Stack: $st');
              return Center(child: Text('Error: $e'));
            },
            loading: () {
              final oldState = ref.read(unifiedGalleryProvider(widget.sourceId)).asData?.value;
              debugPrint('⏳ [UnifiedGalleryScreen] Loading... oldState: ${oldState != null ? 'EXISTS' : 'NULL'}');
              return oldState != null
                  ? _buildGridView(oldState, isRefreshing: true)
                  : const Center(child: CircularProgressIndicator());
            },
          ),

          // ✅ 悬浮预览层
          if (floatingPost != null) ...[
            // ✅ 遮罩点击关闭
            GestureDetector(
              onTap: () => closeFloatingPreview(ref),
              child: Container(color: Colors.black87),
            ),

            // ✅ 内容区
            Center(
              child: FloatingPreviewContent(
                post: floatingPost,
                onClose: () => closeFloatingPreview(ref),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGridView(GalleryState state, {bool isRefreshing = false}) {
    final crossAxisCount = ref.watch(crossAxisCountNotifierProvider);
    final cardHeight = ref.watch(cardHeightProvider);
    const crossAxisSpacing = 4.0;
    const mainAxisSpacing = 4.0;

    // ✅ 空列表检查
    if (state.posts.isEmpty && !isRefreshing) {
      debugPrint('📭 [UnifiedGalleryScreen] No posts to display');
      return const Center(child: Text('No posts found.'));
    }

    // ✅ 调试打印前10个帖子的关键信息
    if (state.posts.isNotEmpty) {
      debugPrint('📋 [UnifiedGalleryScreen] First 3 posts:');
      for (int i = 0; i < min(3, state.posts.length); i++) {
        final post = state.posts[i];
        debugPrint('  [$i] id: ${post.id}, url: ${post.fullImageUrl}, source: ${post.source}');
      }
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - crossAxisSpacing * (crossAxisCount - 1)) / crossAxisCount;
    final childAspectRatio = cardWidth / cardHeight;

    return RefreshIndicator(
      onRefresh: () async {
        debugPrint('🔄 [UnifiedGalleryScreen] Refresh triggered');
        await ref.read(unifiedGalleryProvider(widget.sourceId).notifier).refresh();
        debugPrint('✅ [UnifiedGalleryScreen] Refresh completed');
      },
      child: GridView.builder(
        controller: _scrollController,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: childAspectRatio,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
        ),
        cacheExtent: MediaQuery.of(context).size.height * 2.5,
        itemCount: state.hasMore ? state.posts.length + 1 : state.posts.length,
        itemBuilder: (context, index) {
          // ✅ 加载更多指示器
          if (index == state.posts.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final post = state.posts[index];
          
          // ✅ **关键**：验证单个帖子数据完整性
          if (post.id == null || post.fullImageUrl == null) {
            debugPrint('🚫 [UnifiedGalleryScreen] Invalid post at index $index: id=${post.id}, url=${post.fullImageUrl}');
            return const SizedBox.shrink(); // 返回空组件避免崩溃
          }

          return RepaintBoundary(
            child: UnifiedMediaCard(post: post),
          );
        },
      ),
    );
  }
}