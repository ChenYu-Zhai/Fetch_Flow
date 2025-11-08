import 'dart:async';
import 'dart:math';
import 'package:featch_flow/models/unified_post_model.dart';
import 'package:featch_flow/providers/floating_preview_provider.dart';
import 'package:featch_flow/providers/unified_gallery_provider.dart';
import 'package:featch_flow/widgets/floating_preview_content.dart';
import 'package:featch_flow/widgets/placeholder_card.dart';
import 'package:featch_flow/widgets/staggered_build_wrapper.dart';
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
  bool _isScrolling = false;
  bool _isDragging = false; // ✅ 新增：用于跟踪用户是否在拖拽滚动条
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    debugPrint(
      '[UnifiedGalleryScreen] Initialized for source: ${widget.sourceId}',
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fetchThrottleTimer?.cancel();
    _preloadThrottleTimer?.cancel();
    super.dispose();
    debugPrint(
      '[UnifiedGalleryScreen] Disposed for source: ${widget.sourceId}',
    );
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      _fetchNextPageThrottled();
      _scheduleMediaPreload();
    }
  }

  void _scheduleMediaPreload() {
    if (_preloadThrottleTimer?.isActive ?? false) return;
    final delay = ref.watch(preloadDelayProvider);
    _preloadThrottleTimer = Timer(Duration(milliseconds: delay), () async {
      final state = ref
          .read(unifiedGalleryProvider(widget.sourceId))
          .asData
          ?.value;
      if (state == null) return;

      final cardHeight = ref.watch(cardHeightProvider);
      final firstIndex =
          (_scrollController.position.pixels / cardHeight).floor() * 2;
      if (firstIndex < _lastPreloadIndex) return;

      final start = max(0, firstIndex - 10);
      final end = min(state.posts.length, firstIndex + 10);
      _lastPreloadIndex = firstIndex;

      await ref
          .read(mediaPreloadServiceProvider)
          .preloadPosts(state.posts.sublist(start, end));
    });
  }

  void _fetchNextPageThrottled() {
    if (_fetchThrottleTimer?.isActive ?? false) return;
    _fetchThrottleTimer = Timer(const Duration(milliseconds: 500), () {
      final state = ref.read(unifiedGalleryProvider(widget.sourceId));
      if (state.asData?.value.hasMore == true &&
          state.asData?.value.isLoadingNextPage == false) {
        ref
            .read(unifiedGalleryProvider(widget.sourceId).notifier)
            .fetchNextPage();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final galleryStateAsync = ref.watch(
      unifiedGalleryProvider(widget.sourceId),
    );
    final floatingPost = ref.watch(floatingPostProvider);

    return Scaffold(
      body: Stack(
        children: [
          // ✅ 原有内容
          galleryStateAsync.when(
            data: (state) => _buildGridView(state),
            error: (e, st) => Center(child: Text('Error: $e')),
            loading: () {
              final oldState = ref
                  .read(unifiedGalleryProvider(widget.sourceId))
                  .asData
                  ?.value;
              return oldState != null
                  ? _buildGridView(oldState, isRefreshing: true)
                  : const Center(child: CircularProgressIndicator());
            },
          ),

          // ✅ 悬浮预览层（覆盖在最上方）
          if (floatingPost != null) ...[
            // 半透明遮罩
            GestureDetector(
              onTap: () => closeFloatingPreview(ref),
              child: Container(color: Colors.black87),
            ),

            // 内容区
            Center(
              child: FullscreenPreviewContent(
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
    // --- 布局参数计算 (保持不变) ---
    final crossAxisCount = ref.watch(crossAxisCountNotifierProvider);
    final cardHeight = ref.watch(cardHeightProvider);
    const crossAxisSpacing = 4.0;
    const mainAxisSpacing = 4.0;

    if (state.posts.isEmpty && !isRefreshing) {
      return const Center(child: Text('No posts found.'));
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth =
        (screenWidth -
            (crossAxisSpacing * (crossAxisCount - 1)) -
            16) / // 减去 ListView 的 padding
        crossAxisCount;
    final childAspectRatio = cardWidth / cardHeight;

    // --- 【核心修复】彻底移除 StaggeredBuildWrapper ---
    // 我们直接构建 RefreshIndicator 和 GridView

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(unifiedGalleryProvider(widget.sourceId).notifier).refresh(),
      child: NotificationListener<ScrollNotification>(
        onNotification: (scrollNotification) {
          // ✅ 当用户开始用手指或鼠标拖拽时触发
          if (scrollNotification is ScrollStartNotification) {
            // dragDetails 不为 null 表示这是一个拖拽手势，而不是代码触发的滚动
            if (scrollNotification.dragDetails != null) {
              if (mounted) setState(() => _isDragging = true);
            }
          }
          // ✅ 当用户停止拖拽，或者惯性滚动结束时触发
          else if (scrollNotification is ScrollEndNotification) {
            if (mounted) setState(() => _isDragging = false);

            // 当拖拽结束，立即触发一次预加载检查，以防停在一个需要加载的位置
            _onScroll();
          }
          return false;
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

          // 【重要】itemCount 直接来自 state.posts
          itemCount: state.hasMore
              ? state.posts.length + 1
              : state.posts.length,
          itemBuilder: (context, index) {
            // 加载指示器的逻辑保持不变
            if (index >= state.posts.length) {
              // 使用 >= 更安全
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final post = state.posts[index];

            // 【重要】我们在这里使用 StaggeredBuildCard
            return StaggeredBuildCard(
              placeholder: ImageRenderer(imageUrl: post.previewImageUrl),
              buildSteps: 3,
              aspectRatio: childAspectRatio, // 使用帖子的真实宽高比
              shouldStartBuilding: !_isDragging,
              child: RepaintBoundary(
                key: ValueKey(post.id),
                child: UnifiedMediaCard(post: post),
              ),
            );
          },
        ),
      ),
    );
  }
}
