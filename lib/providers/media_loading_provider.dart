// media_loading_provider.dart

import 'dart:collection';
import 'package:async/async.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';

class MediaLoadRequest {
  final String imageUrl;
  final CancelableOperation<void> Function() onLoad;
  final VoidCallback onCancel;

  MediaLoadRequest({
    required this.imageUrl,
    required this.onLoad,
    required this.onCancel,
  });

  @override
  String toString() => 'MediaLoadRequest(imageUrl: $imageUrl)';
}

class MediaLoaderState {
  final LinkedHashSet<String> loadedUrls;
  final Map<String, CancelableOperation<void>> activeRequests;
  final List<MediaLoadRequest> pendingRequests;
  final int cacheHits;
  final int totalRequests;

  int get activeLoads => activeRequests.length;
  int get pendingCount => pendingRequests.length;
  double get cacheHitRate =>
      totalRequests == 0 ? 0.0 : cacheHits / totalRequests;

  MediaLoaderState({
    required this.loadedUrls,
    required this.activeRequests,
    required this.pendingRequests,
    this.cacheHits = 0,
    this.totalRequests = 0,
  });

  MediaLoaderState copyWith({
    LinkedHashSet<String>? loadedUrls,
    Map<String, CancelableOperation<void>>? activeRequests,
    List<MediaLoadRequest>? pendingRequests,
    int? cacheHits,
    int? totalRequests,
  }) {
    return MediaLoaderState(
      loadedUrls: loadedUrls ?? this.loadedUrls,
      activeRequests: activeRequests ?? this.activeRequests,
      pendingRequests: pendingRequests ?? this.pendingRequests,
      cacheHits: cacheHits ?? this.cacheHits,
      totalRequests: totalRequests ?? this.totalRequests,
    );
  }
}

final mediaLoaderProvider =
    StateNotifierProvider.autoDispose<MediaLoaderNotifier, MediaLoaderState>(
      (ref) => MediaLoaderNotifier(),
    );

class MediaLoaderNotifier extends StateNotifier<MediaLoaderState> {
  static const int maxConcurrent = 8;
  static const int maxQueueSize = 50;
  static const int maxCacheSize = 1000;

  MediaLoaderNotifier()
    : super(
        MediaLoaderState(
          loadedUrls: LinkedHashSet<String>(),
          activeRequests: {},
          pendingRequests: [],
        ),
      );

  @override
  void dispose() {
    debugPrint('[MediaLoader] Disposing notifier and cancelling all tasks...');
    for (final request in state.pendingRequests) {
      request.onCancel();
    }
    for (final operation in state.activeRequests.values) {
      operation.cancel();
    }
    super.dispose();
  }

  void addRequest(MediaLoadRequest request) {
    final url = request.imageUrl;

    if (state.loadedUrls.contains(url)) {
      state.loadedUrls
        ..remove(url)
        ..add(url);
      request.onLoad().value;
      state = state.copyWith(
        cacheHits: state.cacheHits + 1,
        totalRequests: state.totalRequests + 1,
      );
      return;
    }

    if (state.activeRequests.containsKey(url)) {
      return;
    }

    final pendingIndex = state.pendingRequests.indexWhere(
      (r) => r.imageUrl == url,
    );
    List<MediaLoadRequest> updatedPending = List.from(state.pendingRequests);

    if (pendingIndex != -1) {
      debugPrint('[MediaLoader] Elevating priority for: $url');
      updatedPending.removeAt(pendingIndex).onCancel();
    }
    updatedPending.add(request);

    if (updatedPending.length > maxQueueSize) {
      final removed = updatedPending.removeAt(0);
      removed.onCancel();
    }

    state = state.copyWith(
      pendingRequests: updatedPending,
      totalRequests: state.totalRequests + 1,
    );

    debugPrint(
      '[MediaLoader] Added request for: $url. Queue size: ${state.pendingCount}',
    );

    Future.microtask(_processQueue);
  }

  void _processQueue() {
    while (state.activeLoads < maxConcurrent &&
        state.pendingRequests.isNotEmpty) {
      final request = state.pendingRequests.removeLast();
      final url = request.imageUrl;

      debugPrint('[MediaLoader] Starting load for: $url');

      final operation = request.onLoad();

      state = state.copyWith(
        activeRequests: {...state.activeRequests, url: operation},
        pendingRequests: state.pendingRequests,
      );

      operation.value
          .then((_) {
            _completeLoad(url, success: true);
          })
          .catchError((error) {
            if (!operation.isCanceled) {
              debugPrint('❌ [MediaLoader] Load failed for $url: $error');
            }
            _completeLoad(url, success: false);
          });
    }
  }

  void _completeLoad(String imageUrl, {required bool success}) {
    final newActiveRequests = Map<String, CancelableOperation<void>>.from(
      state.activeRequests,
    );
    newActiveRequests.remove(imageUrl);

    LinkedHashSet<String> newLoadedUrls = state.loadedUrls;
    if (success) {
      newLoadedUrls = LinkedHashSet.from(state.loadedUrls);
      newLoadedUrls.add(imageUrl);
      if (newLoadedUrls.length > maxCacheSize) {
        newLoadedUrls.remove(newLoadedUrls.first);
      }
    }

    state = state.copyWith(
      activeRequests: newActiveRequests,
      loadedUrls: newLoadedUrls,
    );

    debugPrint(
      '[MediaLoader] Completed load for: $imageUrl. Active loads: ${state.activeLoads}',
    );

    Future.microtask(_processQueue);
  }
}
