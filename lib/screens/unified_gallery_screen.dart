import 'dart:async';
import 'dart:math';
import 'dart:math' as math;
import 'package:featch_flow/models/unified_post_model.dart';
import 'package:featch_flow/providers/floating_preview_provider.dart';
import 'package:featch_flow/providers/unified_gallery_provider.dart';
import 'package:featch_flow/utils/image_renderer.dart';
import 'package:featch_flow/widgets/floating_preview_content.dart';
import 'package:featch_flow/widgets/placeholder_card.dart';
import 'package:featch_flow/widgets/stable_drag_scrollbar.dart';
import 'package:featch_flow/widgets/staggered_build_wrapper.dart';
import 'package:featch_flow/widgets/unified_media_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:featch_flow/services/media_preload_service.dart';
import 'package:featch_flow/providers/settings_provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:riverpod/src/framework.dart';

const double kCardFooterHeight = 44.0;

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
  // bool _isDragging = false;
  final ValueNotifier<bool> _isDraggingNotifier = ValueNotifier<bool>(
    false,
  ); // <<< 替换为这行
  late final PageStorageKey _gridKey;
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _gridKey = PageStorageKey(widget.sourceId);
    debugPrint(
      '[UnifiedGalleryScreen] Initialized for source: ${widget.sourceId}',
    );
  }

  @override
  void dispose() {
    _isDraggingNotifier.dispose();
    _scrollController.dispose();
    _fetchThrottleTimer?.cancel();
    _preloadThrottleTimer?.cancel();
    super.dispose();
    debugPrint(
      '[UnifiedGalleryScreen] Disposed for source: ${widget.sourceId}',
    );
  }

  Timer? _scrollThrottleTimer;
  void _onScroll() {
    if (_isDraggingNotifier.value) return;
    _scrollThrottleTimer?.cancel();
    _scrollThrottleTimer = Timer(
      Duration(milliseconds: ref.watch(preloadDelayProvider)),
      () {
        if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.9) {
          debugPrint("[_onScroll] 触发分页");
          _fetchNextPageThrottled();
        }
        debugPrint("[_onScroll] 触发预加载");
        // _scheduleMediaPreload();
      },
    );
  }

  int _findItemIndexAtPixel(double targetPixel, List<UnifiedPostModel> posts) {
    double accumulatedHeight = 0.0;
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = ref.read(crossAxisCountNotifierProvider);

    // 瀑布流横向间距、padding 与 item 宽度计算（同你的 itemBuilder 一致）
    const crossAxisSpacing = 4.0;
    const padding = 8.0 * 2;
    final cardWidth =
        (screenWidth - padding - crossAxisSpacing * (crossAxisCount - 1)) /
        crossAxisCount;

    for (int i = 0; i < posts.length; i++) {
      final post = posts[i];

      if (post.width == 0 || post.height == 0) {
        accumulatedHeight += cardWidth; // fallback to minimum estimate
        continue;
      }

      final mediaHeight = cardWidth / (post.width / post.height);
      final totalCardHeight = mediaHeight + kCardFooterHeight;

      accumulatedHeight += totalCardHeight + 4.0; // + mainAxisSpacing

      if (accumulatedHeight >= targetPixel) {
        return i;
      }
    }

    return posts.length;
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
    //final floatingPost = ref.watch(floatingPostProvider);

    return Scaffold(
      body: Stack(
        children: [
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
          const _FloatingPreviewOverlay(),
        ],
      ),
    );
  }

  Widget _buildGridView(GalleryState state, {bool isRefreshing = false}) {
    final crossAxisCount = ref.watch(crossAxisCountNotifierProvider);

    if (state.posts.isEmpty && !isRefreshing) {
      return const Center(child: Text('No posts found.'));
    }

    return StableDragScrollbar(
      controller: _scrollController,

      onDragStart: () {
        _isDraggingNotifier.value = true;
      },
      onDragEnd: () {
        _isDraggingNotifier.value = false;
        _onScroll(); // 在拖拽滚动条结束时额外调用
      },
      child: RefreshIndicator(
        onRefresh: () => ref
            .read(unifiedGalleryProvider(widget.sourceId).notifier)
            .refresh(),
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: MasonryGridView.builder(
            key: _gridKey,
            controller: _scrollController,
            padding: const EdgeInsets.all(8.0),
            gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
            ),
            mainAxisSpacing: 4.0,
            crossAxisSpacing: 4.0,
            cacheExtent: MediaQuery.of(context).size.height * 2.5,
            itemCount: state.hasMore
                ? state.posts.length + 1
                : state.posts.length,
            itemBuilder: (context, index) {
              debugPrint("[itemBuilder] itemBuilder正在构建:索引 $index");
              if (index >= state.posts.length) {
                debugPrint("[itemBuilder] 加载指示器索引: $index");
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final post = state.posts[index];

              // 1. 计算媒体部分本身的宽高比
              final mediaAspectRatio = post.width / post.height;

              // 2. 估算卡片的总宽高比
              //    我们需要知道卡片的宽度来计算总高度
              final crossAxisCount = ref.read(crossAxisCountNotifierProvider);
              final screenWidth = MediaQuery.of(context).size.width;
              const crossAxisSpacing = 4.0;
              const padding = 8.0 * 2; // GridView 的 padding
              final cardWidth =
                  (screenWidth -
                      padding -
                      crossAxisSpacing * (crossAxisCount - 1)) /
                  crossAxisCount;

              // 媒体部分的高度
              final mediaHeight = cardWidth / mediaAspectRatio;
              // 卡片总高度
              final totalCardHeight = mediaHeight + kCardFooterHeight;
              // 卡片总宽高比
              final totalAspectRatio = cardWidth / totalCardHeight;

              // vvv --- 这里是核心修改 --- vvv
              return AspectRatio(
                key: ValueKey(post.id),
                aspectRatio: totalAspectRatio,
                // 我们不再使用 Container 包裹，因为 UnifiedMediaCard 自己会处理好布局
                child: UnifiedMediaCard(
                  post: post,
                  isDraggingNotifier: _isDraggingNotifier, // 将拖拽状态传递进去
                ),
              );
              // ^^^ --- 这里是核心修改 --- ^^^
            },
          ),
        ),
      ),
    );
  }
}

class _FloatingPreviewOverlay extends ConsumerWidget {
  const _FloatingPreviewOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 【注意】在这里监听 floatingPostProvider，而不是在父 Widget 中
    final floatingPost = ref.watch(floatingPostProvider);

    if (floatingPost == null) {
      return const SizedBox.shrink(); // 没有浮动预览时，不显示任何东西
    }

    return Container(
      color: const Color.fromARGB(128, 0, 0, 0),
      child: Center(
        child: GestureDetector(
          onTap: () {}, // 阻止点击穿透到下面的画廊
          child: FullscreenPreviewContent(
            post: floatingPost,
            onClose: () => closeFloatingPreview(ref),
          ),
        ),
      ),
    );
  }
}
