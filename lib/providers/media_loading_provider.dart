// media_loading_provider.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';

class MediaLoadRequest {
  final String imageUrl;
  final VoidCallback onLoad;
  final VoidCallback onCancel;
  final DateTime addedAt; // 新增字段用于追踪优先级

  MediaLoadRequest({
    required this.imageUrl,
    required this.onLoad,
    required this.onCancel,
    required this.addedAt,
  });

  @override
  String toString() => 'MediaLoadRequest(imageUrl: $imageUrl)';
}

class MediaLoaderState {
  final Map<String, Completer<void>> activeRequests;
  final List<MediaLoadRequest> pendingRequests;
  final Set<String> loadedUrls;
  final Set<String> loadingInProgress;

  MediaLoaderState({
    required this.activeRequests,
    required this.pendingRequests,
    required this.loadedUrls,
    required this.loadingInProgress,
  });

  MediaLoaderState copyWith({
    Map<String, Completer<void>>? activeRequests,
    List<MediaLoadRequest>? pendingRequests,
    Set<String>? loadedUrls,
    Set<String>? loadingInProgress,
  }) {
    return MediaLoaderState(
      activeRequests: activeRequests ?? this.activeRequests,
      pendingRequests: pendingRequests ?? this.pendingRequests,
      loadedUrls: loadedUrls ?? this.loadedUrls,
      loadingInProgress: loadingInProgress ?? this.loadingInProgress,
    );
  }
}

final mediaLoaderProvider =
    StateNotifierProvider<MediaLoaderNotifier, MediaLoaderState>(
  (ref) => MediaLoaderNotifier(),
);

class MediaLoaderNotifier extends StateNotifier<MediaLoaderState> {
  static const int maxConcurrent = 8;
  static const int maxQueueSize = 40;
  int activeLoads = 0;

  MediaLoaderNotifier()
      : super(
          MediaLoaderState(
            activeRequests: {},
            pendingRequests: [],
            loadedUrls: {},
            loadingInProgress: {},
          ),
        );

  /// 优先加载“较新加入的任务”，支持最大队列长度和去重/优先级调整
  void addRequest(MediaLoadRequest request) {
    if (state.loadingInProgress.contains(request.imageUrl)) {
      // 如果在队列中且未开始加载，则将其移到最前（提升优先级）
      debugPrint('[MediaLoader] Elevating priority for existing pending request: ${request.imageUrl}');
      final newList = state.pendingRequests
          .where((r) => r.imageUrl != request.imageUrl)
          .toList();

      newList.add(request); // 插入到列表末尾 → 实际会是下一个处理项（因为 LIFO）
      state = state.copyWith(pendingRequests: newList);
      _processQueue();
      return;
    }

    // 正常添加到 pending 队列头部（模拟 LIFO）
    final updatedList = [...state.pendingRequests, request];

    // 保证不超过最大长度
    if (updatedList.length > maxQueueSize) {
      final removed = updatedList.removeAt(0); // 移除最早的项
      if (!state.loadedUrls.contains(removed.imageUrl)) {
        removed.onCancel(); // 回调通知取消
      }
    }

    // 提交到加载状态
    final completer = Completer<void>();
    state = state.copyWith(
      activeRequests: {...state.activeRequests, request.imageUrl: completer},
      pendingRequests: updatedList,
      loadingInProgress: {...state.loadingInProgress, request.imageUrl},
    );

    debugPrint('[MediaLoader] Added new request: ${request.imageUrl}');
    _processQueue();
  }

  void removeRequest(String imageUrl) {
    final newRequests = state.pendingRequests
        .where((r) => r.imageUrl != imageUrl)
        .toList();

    state = state.copyWith(pendingRequests: newRequests);
    debugPrint('[MediaLoader] Removed pending request: $imageUrl');
  }

  void _processQueue() {
    debugPrint('[MediaLoader] Processing queue, active loads: $activeLoads / $maxConcurrent');

    while (activeLoads < maxConcurrent && state.pendingRequests.isNotEmpty) {
      // 取队尾（即最后一个添加进来的），实现 LIFO
      final request = state.pendingRequests.last;
      final completer = state.activeRequests[request.imageUrl];

      if (completer == null || completer.isCompleted) {
        // 无法启动的任务应从列表中清除
        debugPrint('[MediaLoader] Skipping invalid/complete request: ${request.imageUrl}');
        final newRequests = state.pendingRequests
            .where((r) => r.imageUrl != request.imageUrl)
            .toList();
        state = state.copyWith(pendingRequests: newRequests);
        continue;
      }

      debugPrint('[MediaLoader] Starting load for: ${request.imageUrl}');
      request.onLoad();
      activeLoads++;

      // 移除已启动项
      final newRequests = state.pendingRequests
          .where((r) => r.imageUrl != request.imageUrl)
          .toList();
      state = state.copyWith(
        pendingRequests: newRequests,
        loadedUrls: {...state.loadedUrls, request.imageUrl},
      );
    }
  }

  void completeLoad(String imageUrl) {
    final completer = state.activeRequests[imageUrl];

    if (completer != null && !completer.isCompleted) {
      debugPrint('[MediaLoader] Completing load for: $imageUrl');
      completer.complete();
    } else {
      debugPrint('[MediaLoader] Skipped completion (already done): $imageUrl');
    }

    state = state.copyWith(
      activeRequests: Map.from(state.activeRequests)..remove(imageUrl),
      loadingInProgress: Set.from(state.loadingInProgress)..remove(imageUrl),
    );

    if (activeLoads > 0) {
      activeLoads--;
    }

    debugPrint('[MediaLoader] ActiveLoads decremented, now: $activeLoads');
    _processQueue();
  }
}