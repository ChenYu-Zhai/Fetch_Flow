// media_loading_provider.dart

import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:async/async.dart';
import 'package:flutter_riverpod/legacy.dart';

class MediaLoadRequest {
  final String imageUrl;
  final Future<void> Function() onLoad;
  final VoidCallback onCancel;
  final DateTime addedAt;

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
  final Map<String, CancelableOperation<void>> activeRequests;
  final Queue<MediaLoadRequest> pendingQueue;
  final LinkedHashSet<String> loadedUrls;
  final bool isProcessing;

  const MediaLoaderState({
    required this.activeRequests,
    required this.pendingQueue,
    required this.loadedUrls,
    required this.isProcessing,
  });

  MediaLoaderState copyWith({
    Map<String, CancelableOperation<void>>? activeRequests,
    Queue<MediaLoadRequest>? pendingQueue,
    LinkedHashSet<String>? loadedUrls,
    bool? isProcessing,
  }) {
    return MediaLoaderState(
      activeRequests: activeRequests ?? this.activeRequests,
      pendingQueue: pendingQueue ?? this.pendingQueue,
      loadedUrls: loadedUrls ?? this.loadedUrls,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }

  int get activeLoadCount => activeRequests.length;
}

final mediaLoaderProvider =
    StateNotifierProvider<MediaLoaderNotifier, MediaLoaderState>((ref) {
      final notifier = MediaLoaderNotifier();
      ref.onDispose(() {
        notifier._dispose();
      });
      return notifier;
    });

class MediaLoaderNotifier extends StateNotifier<MediaLoaderState> {
  static const int maxConcurrent = 8;
  static const int maxQueueSize = 40;
  static const int maxLoadedUrlHistory = 1000;

  MediaLoaderNotifier()
    : super(
        MediaLoaderState(
          activeRequests: {},
          pendingQueue: Queue(),
          loadedUrls: LinkedHashSet(),
          isProcessing: false,
        ),
      );

  void addRequest(MediaLoadRequest request) {
    final url = request.imageUrl;

    // 三重去重检查
    if (state.loadedUrls.contains(url)) {
      debugPrint('[MediaLoader] Skip: Already loaded $url');
      return;
    }
    if (state.activeRequests.containsKey(url)) {
      debugPrint('[MediaLoader] Skip: Already loading $url');
      return;
    }
    if (state.pendingQueue.any((r) => r.imageUrl == url)) {
      debugPrint('[MediaLoader] Elevate: Move existing $url to front');
      _moveToFront(url);
      return;
    }

    // 添加到队列头部（LIFO）
    final newQueue = Queue<MediaLoadRequest>.from(state.pendingQueue)
      ..addFirst(request);

    // 超限淘汰
    while (newQueue.length > maxQueueSize) {
      final removed = newQueue.removeLast();
      debugPrint('[MediaLoader] Evict: Queue full, cancel ${removed.imageUrl}');
      removed.onCancel();
    }

    state = state.copyWith(pendingQueue: newQueue);
    debugPrint('[MediaLoader] Enqueue: $url (queue: ${newQueue.length})');
    _processQueue();
  }

  void removePending(String imageUrl) {
    final newQueue = Queue<MediaLoadRequest>.from(state.pendingQueue)
      ..removeWhere((r) => r.imageUrl == imageUrl);

    if (newQueue.length != state.pendingQueue.length) {
      state = state.copyWith(pendingQueue: newQueue);
      debugPrint('[MediaLoader] Remove: $imageUrl from queue');
    }
  }

  void _processQueue() {
    if (state.isProcessing) return;

    Future.microtask(() {
      if (!mounted) return;

      int availableSlots = maxConcurrent - state.activeLoadCount;
      if (availableSlots <= 0 || state.pendingQueue.isEmpty) {
        state = state.copyWith(isProcessing: false);
        return;
      }

      state = state.copyWith(isProcessing: true);

      for (
        int i = 0;
        i < availableSlots && state.pendingQueue.isNotEmpty;
        i++
      ) {
        final request = state.pendingQueue.removeFirst(); // LIFO: 取最新
        _startLoad(request);
      }

      if (state.pendingQueue.isNotEmpty &&
          state.activeLoadCount < maxConcurrent) {
        _processQueue();
      } else {
        state = state.copyWith(isProcessing: false);
      }
    });
  }

  void _startLoad(MediaLoadRequest request) {
    final url = request.imageUrl;
    debugPrint(
      '[MediaLoader] Start: $url (active: ${state.activeLoadCount + 1})',
    );

    // 创建可取消的操作
    final completer = CancelableCompleter<void>(
      onCancel: () {
        debugPrint('[MediaLoader] Cancel: $url');
        request.onCancel();
      },
    );

    // 启动加载任务
    request.onLoad().then(
      (_) => completer.complete(),
      onError: completer.completeError, // ✅ 正确传递错误
    );

    // ✅ 超时控制（使用Timer）
    final timer = Timer(const Duration(seconds: 10), () {
      if (!completer.isCompleted && !completer.isCanceled) {
        debugPrint('[MediaLoader] Timeout: $url');
        completer.completeError(TimeoutException('Load timeout for $url'));
      }
    });

    final operation = completer.operation;

    operation.then(
      (_) {
        timer.cancel(); 
        _onLoadSuccess(url);
      },
      onError: (error, stackTrace) {
        timer.cancel();
        _onLoadFailed(url, error);
      },
    );

    state = state.copyWith(
      activeRequests: {...state.activeRequests, url: operation},
    );
  }

  void _onLoadSuccess(String imageUrl) {
    debugPrint('[MediaLoader] Success: $imageUrl');
    _completeLoad(imageUrl);
    _markAsLoaded(imageUrl);
  }

  void _onLoadFailed(String imageUrl, dynamic error) {
    debugPrint('[MediaLoader] Failed: $imageUrl, error: $error');
    _completeLoad(imageUrl);
  }

  void _completeLoad(String imageUrl) {
    final operation = state.activeRequests[imageUrl];
    if (operation != null) {
      if (!operation.isCompleted && !operation.isCanceled) {
        operation.cancel();
      }

      state = state.copyWith(
        activeRequests: {...state.activeRequests}..remove(imageUrl),
      );
    }

    debugPrint(
      '[MediaLoader] Complete: $imageUrl (active: ${state.activeLoadCount})',
    );
    _processQueue();
  }

  void _markAsLoaded(String imageUrl) {
    final newLoaded = LinkedHashSet<String>.from(state.loadedUrls)
      ..remove(imageUrl)
      ..add(imageUrl);

    if (newLoaded.length > maxLoadedUrlHistory) {
      final oldest = newLoaded.first;
      debugPrint('[MediaLoader] LRU Evict: $oldest from history');
      newLoaded.remove(oldest);
    }

    state = state.copyWith(loadedUrls: newLoaded);
  }

  void _moveToFront(String imageUrl) {
    final existing = state.pendingQueue
        .where((r) => r.imageUrl == imageUrl)
        .toList();

    if (existing.isNotEmpty) {
      final newQueue = Queue<MediaLoadRequest>.from(state.pendingQueue)
        ..removeWhere((r) => r.imageUrl == imageUrl)
        ..addFirst(existing.first);

      state = state.copyWith(pendingQueue: newQueue);
    }
  }

  void _dispose() {
    debugPrint(
      '[MediaLoader] Dispose: Cleaning up ${state.activeLoadCount} active requests',
    );

    // ✅ 取消所有活跃请求
    for (final operation in state.activeRequests.values) {
      if (!operation.isCompleted && !operation.isCanceled) {
        operation.cancel();
      }
    }

    // 通知待处理请求取消
    for (final request in state.pendingQueue) {
      request.onCancel();
    }
  }
}
