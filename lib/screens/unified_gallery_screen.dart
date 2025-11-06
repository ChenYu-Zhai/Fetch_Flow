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

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    debugPrint('[UnifiedGalleryScreen] Initialized for source: ${widget.sourceId}');
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
    debugPrint('[UnifiedGalleryScreen] Disposed for source: ${widget.sourceId}');
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.6) {
      final state = ref.read(unifiedGalleryProvider(widget.sourceId));
      if (state.asData != null && state.asData!.value.hasMore) {
        debugPrint('[UnifiedGalleryScreen] Scrolled to bottom, fetching next page for source: ${widget.sourceId}');
        ref
            .read(unifiedGalleryProvider(widget.sourceId).notifier)
            .fetchNextPage();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final galleryStateAsync = ref.watch(
      unifiedGalleryProvider(widget.sourceId),
    );
    ref.listen(unifiedGalleryProvider(widget.sourceId), (_, next) {
      debugPrint('[UnifiedGalleryScreen] Gallery state changed for source: ${widget.sourceId}, hasValue: ${next.hasValue}');
    });

    return galleryStateAsync.when(
      data: (state) {
        debugPrint('[UnifiedGalleryScreen] Building grid view for source: ${widget.sourceId}, post count: ${state.posts.length}');
        return _buildGridView(state);
      },
      error: (e, st) {
        debugPrint('[UnifiedGalleryScreen] Error for source: ${widget.sourceId}, error: $e');
        return Center(child: Text('Error: $e'));
      },
      loading: () {
        debugPrint('[UnifiedGalleryScreen] Loading state for source: ${widget.sourceId}');
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
        debugPrint('[UnifiedGalleryScreen] Refreshing for source: ${widget.sourceId}');
        return ref.read(unifiedGalleryProvider(widget.sourceId).notifier).refresh();
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

          const preloadOffset = 60;
          if (index + preloadOffset < state.posts.length) {
            final postToPreload = state.posts[index + preloadOffset];
            ref.read(mediaPreloadServiceProvider).preload(postToPreload, ref);
          }

          final post = state.posts[index];
          return UnifiedMediaCard(post: post);
        },
      ),
    );
  }
}
