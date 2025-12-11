import 'dart:async';
import 'package:featch_flow/providers/floating_preview_provider.dart';
import 'package:featch_flow/providers/unified_gallery_provider.dart';
import 'package:featch_flow/widgets/floating_preview_content.dart';
import 'package:featch_flow/widgets/stable_drag_scrollbar.dart';
import 'package:featch_flow/widgets/unified_media_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  Timer? _fetchThrottleTimer;
  Timer? _preloadThrottleTimer;
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
    // ✅ 在构建 Stack 之前，先监听 provider 的状态
    final floatingPost = ref.watch(floatingPostProvider);

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
          // ✅ 解决方案：仅当 floatingPost 不为 null 时，才构建并添加 _FloatingPreviewOverlay
          if (floatingPost != null) const _FloatingPreviewOverlay(),
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
              return UnifiedMediaCard(
                key: ValueKey(post.id), // Key 移到这里
                post: post,
                isDraggingNotifier: _isDraggingNotifier,
              );
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
    final floatingPost = ref.watch(floatingPostProvider);

    if (floatingPost == null) {
      return const SizedBox.shrink();
    }

    return Container(
      color: const Color.fromARGB(128, 0, 0, 0),
      child: Center(
        child: GestureDetector(
          onTap: () {},
          child: FullscreenPreviewContent(
            post: floatingPost,
            onClose: () => closeFloatingPreview(ref),
          ),
        ),
      ),
    );
  }
}
