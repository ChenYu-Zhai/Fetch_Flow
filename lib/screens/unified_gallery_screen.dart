import 'dart:async';
import 'dart:math';

import 'package:featch_flow/providers/unified_gallery_provider.dart';
import 'package:featch_flow/widgets/unified_media_card.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
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
  // --- 【新增】节流相关的状态变量 ---
  bool _isFetching = false; // 一个简单的锁，防止并发
  Timer? _throttleTimer; // 用于节流的计时器
  int _lastPreloadIndex = 0; //用于跟踪上一次预加载的位置，避免重复计算
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
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _throttleTimer?.cancel(); // 【重要】销毁时取消计时器
    super.dispose();
    debugPrint(
      '[UnifiedGalleryScreen] Disposed for source: ${widget.sourceId}',
    );
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.7) {
      final state = ref.read(unifiedGalleryProvider(widget.sourceId));
      if (state.asData != null && state.asData!.value.hasMore) {
        debugPrint(
          '[UnifiedGalleryScreen] Scrolled to bottom, fetching next page for source: ${widget.sourceId}',
        );
        _fetchNextPageThrottled(); // 调用节流版本的获取方法
        //调用媒体预加载调度器
        _scheduleMediaPreload();
      }
    }
  }

  void _scheduleMediaPreload() {
    // 获取当前的数据状态
    final state = ref
        .read(unifiedGalleryProvider(widget.sourceId))
        .asData
        ?.value;
    if (state == null || state.posts.isEmpty) return;

    // 获取瀑布流的 SliverGridState 来计算可见范围
    // 这需要一个 GlobalKey，但 MasonryGridView 不直接暴露
    // 我们采用一种更通用的、基于滚动位置的估算方法。

    // 估算当前屏幕中间的 item 索引
    // (这是一个简化的估算，但对于预加载来说足够了)
    final averageItemHeight = 250; // 假设一个卡片的平均高度
    final screenCenterPosition =
        _scrollController.position.pixels +
        _scrollController.position.viewportDimension / 2;
    final centerItemIndex = (screenCenterPosition / averageItemHeight * 2)
        .floor(); // *2 是因为有两列

    // 如果用户没有向下滚动足够远，就不执行新的预加载
    if (centerItemIndex < _lastPreloadIndex) return;

    // 确定预加载的范围
    final preloadStartIndex = centerItemIndex;
    final preloadEndIndex = min(
      centerItemIndex + 20,
      state.posts.length,
    ); // 向前预加载20个

    // 如果范围有效，则执行批量预加载
    if (preloadStartIndex < preloadEndIndex) {
      // 获取需要预加载的帖子切片
      final postsToPreload = state.posts.sublist(
        preloadStartIndex,
        preloadEndIndex,
      );

      // 调用 Service 的批量接口
      ref.read(mediaPreloadServiceProvider).preloadPosts(postsToPreload);

      // 更新上一次预加载的位置
      _lastPreloadIndex = preloadEndIndex;
    }
  }

  // --- 【核心改造】实现带节流的获取逻辑 ---
  void _fetchNextPageThrottled() {
    // 1. 如果计时器正在运行，说明在节流间隔内，直接返回
    if (_throttleTimer?.isActive ?? false) {
      return;
    }

    // 2. 设置一个节流间隔，例如 500 毫秒
    const throttleDuration = Duration(milliseconds: 500);
    _throttleTimer = Timer(throttleDuration, () {}); // 启动计时器

    // 3. 检查状态并获取数据 (这部分逻辑与您之前的优化方案类似)
    final state = ref.read(unifiedGalleryProvider(widget.sourceId));
    if (state.asData != null &&
        state.asData!.value.hasMore &&
        !state.asData!.value.isLoadingNextPage) {
      ref
          .read(unifiedGalleryProvider(widget.sourceId).notifier)
          .fetchNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final galleryStateAsync = ref.watch(
      unifiedGalleryProvider(widget.sourceId),
    );
    ref.listen(unifiedGalleryProvider(widget.sourceId), (_, next) {
      debugPrint(
        '[UnifiedGalleryScreen] Gallery state changed for source: ${widget.sourceId}, hasValue: ${next.hasValue}',
      );
    });

    return galleryStateAsync.when(
      data: (state) {
        debugPrint(
          '[UnifiedGalleryScreen] Building grid view for source: ${widget.sourceId}, post count: ${state.posts.length}',
        );
        return _buildGridView(state);
      },
      error: (e, st) {
        debugPrint(
          '[UnifiedGalleryScreen] Error for source: ${widget.sourceId}, error: $e',
        );
        return Center(child: Text('Error: $e'));
      },
      loading: () {
        debugPrint(
          '[UnifiedGalleryScreen] Loading state for source: ${widget.sourceId}',
        );
        final oldState = ref
            .read(unifiedGalleryProvider(widget.sourceId))
            .asData
            ?.value;
        if (oldState != null) {
          return _buildGridView(oldState, isRefreshing: true);
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildGridView(GalleryState state, {bool isRefreshing = false}) {
    final crossAxisCount = ref.watch(crossAxisCountNotifierProvider);
    if (state.posts.isEmpty && !isRefreshing) {
      return const Center(child: Text('No posts found.'));
    }

    return RefreshIndicator(
      onRefresh: () {
        debugPrint(
          '[UnifiedGalleryScreen] Refreshing for source: ${widget.sourceId}',
        );
        return ref
            .read(unifiedGalleryProvider(widget.sourceId).notifier)
            .refresh();
      },
      child: MasonryGridView.builder(
        controller: _scrollController,
        cacheExtent: MediaQuery.of(context).size.height * 2.5,
        gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
        ),
        itemCount: state.hasMore ? state.posts.length + 1 : state.posts.length,
        itemBuilder: (context, index) {
          if (index == state.posts.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final post = state.posts[index];
          return RepaintBoundary(child: UnifiedMediaCard(post: post));
        },
      ),
    );
  }
}
