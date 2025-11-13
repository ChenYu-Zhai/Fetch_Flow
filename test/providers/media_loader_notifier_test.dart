// test/media_loader_notifier_test.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// A. 定义需要测试的原始类 (通常从你的项目中 import)
// ---------------------------------------------------------------------------

class MediaLoadRequest {
  final String imageUrl;
  final VoidCallback onLoad;
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

// ---------------------------------------------------------------------------
// B. 创建一个可测试版本的 Notifier
// 复制你的全部逻辑，但将硬编码的常量改为构造函数参数
// ---------------------------------------------------------------------------

class TestableMediaLoaderNotifier extends StateNotifier<MediaLoaderState> {
  final int maxConcurrent;
  final int maxQueueSize;
  int activeLoads = 0;

  TestableMediaLoaderNotifier({this.maxConcurrent = 3, this.maxQueueSize = 100})
    : super(
        MediaLoaderState(
          activeRequests: {},
          pendingRequests: [],
          loadedUrls: {},
          loadingInProgress: {},
        ),
      );

  // --- 这里的逻辑与你提供的代码完全相同 ---
  void addRequest(MediaLoadRequest request) {
    if (state.loadedUrls.contains(request.imageUrl)) {
      request.onLoad();
      return;
    }

    if (state.loadingInProgress.contains(request.imageUrl)) {
      debugPrint(
        '[Test] Elevating priority for existing pending request: ${request.imageUrl}',
      );
      final newList = state.pendingRequests
          .where((r) => r.imageUrl != request.imageUrl)
          .toList();

      newList.add(request);
      state = state.copyWith(pendingRequests: newList);
      _processQueue();
      return;
    }

    final updatedList = [...state.pendingRequests, request];

    if (updatedList.length > maxQueueSize) {
      final removed = updatedList.removeAt(0);
      if (!state.loadedUrls.contains(removed.imageUrl)) {
        removed.onCancel();
      }
    }

    final completer = Completer<void>();
    state = state.copyWith(
      activeRequests: {...state.activeRequests, request.imageUrl: completer},
      pendingRequests: updatedList,
      loadingInProgress: {...state.loadingInProgress, request.imageUrl},
    );

    _processQueue();
  }

  void _processQueue() {
    while (activeLoads < maxConcurrent && state.pendingRequests.isNotEmpty) {
      final request = state.pendingRequests.last;
      final completer = state.activeRequests[request.imageUrl];

      if (completer == null || completer.isCompleted) {
        final newRequests = state.pendingRequests
            .where((r) => r.imageUrl != request.imageUrl)
            .toList();
        state = state.copyWith(pendingRequests: newRequests);
        continue;
      }

      request.onLoad();
      activeLoads++;

      final newRequests = state.pendingRequests
          .where((r) => r.imageUrl != request.imageUrl)
          .toList();
      state = state.copyWith(pendingRequests: newRequests);
    }
  }

  void completeLoad(String imageUrl) {
    if (state.loadingInProgress.contains(imageUrl)) {
      state = state.copyWith(
        activeRequests: Map.from(state.activeRequests)..remove(imageUrl),
        loadingInProgress: Set.from(state.loadingInProgress)..remove(imageUrl),
        loadedUrls: {...state.loadedUrls, imageUrl},
      );

      if (activeLoads > 0) {
        activeLoads--;
      }
      _processQueue();
    }
  }
}

// ---------------------------------------------------------------------------
// C. 测试用例
// ---------------------------------------------------------------------------

// Helper function to create mock requests for testing
MediaLoadRequest createMockRequest(
  String url, {
  required VoidCallback onLoad,
  required VoidCallback onCancel,
}) {
  return MediaLoadRequest(
    imageUrl: url,
    onLoad: onLoad,
    onCancel: onCancel,
    addedAt: DateTime.now(),
  );
}

void main() {
  group('MediaLoaderNotifier Logic Tests', () {
    test('LIFO Behavior: Processes the last queued request first', () {
      final loadedOrder = <String>[];
      final notifier = TestableMediaLoaderNotifier(maxConcurrent: 1);

      notifier.addRequest(
        createMockRequest(
          'A',
          onLoad: () => loadedOrder.add('A'),
          onCancel: () {},
        ),
      );
      notifier.addRequest(
        createMockRequest(
          'B',
          onLoad: () => loadedOrder.add('B'),
          onCancel: () {},
        ),
      );
      notifier.addRequest(
        createMockRequest(
          'C',
          onLoad: () => loadedOrder.add('C'),
          onCancel: () {},
        ),
      );

      // Initially, only A has loaded. B and C are in the queue.
      expect(loadedOrder, ['A']);
      expect(notifier.state.pendingRequests.map((r) => r.imageUrl).toList(), [
        'B',
        'C',
      ]);

      // Complete A. The notifier should process the last item from the queue ('C').
      notifier.completeLoad('A');
      expect(loadedOrder, ['A', 'C']);
      expect(notifier.state.pendingRequests.map((r) => r.imageUrl).toList(), [
        'B',
      ]);

      // Complete C. The notifier should process the remaining item ('B').
      notifier.completeLoad('C');
      expect(loadedOrder, ['A', 'C', 'B']);
      expect(notifier.state.pendingRequests.isEmpty, isTrue);
    });

    test(
      'Max Queue Size: Discards the oldest request when limit is exceeded',
      () {
        final cancelledUrls = <String>[];
        final notifier = TestableMediaLoaderNotifier(
          maxConcurrent: 0,
          maxQueueSize: 2,
        ); // No active loads to test queue only

        notifier.addRequest(
          createMockRequest(
            'A',
            onLoad: () {},
            onCancel: () => cancelledUrls.add('A'),
          ),
        );
        notifier.addRequest(
          createMockRequest(
            'B',
            onLoad: () {},
            onCancel: () => cancelledUrls.add('B'),
          ),
        );

        expect(notifier.state.pendingRequests.length, 2);

        notifier.addRequest(
          createMockRequest(
            'C',
            onLoad: () {},
            onCancel: () => cancelledUrls.add('C'),
          ),
        );

        expect(cancelledUrls, ['A']);
        expect(notifier.state.pendingRequests.map((r) => r.imageUrl).toList(), [
          'B',
          'C',
        ]);
      },
    );

    test(
      'Priority Elevation: Moves an existing request to the front of the LIFO queue',
      () {
        final loadedOrder = <String>[];
        final notifier = TestableMediaLoaderNotifier(maxConcurrent: 1);

        notifier.addRequest(
          createMockRequest(
            'A',
            onLoad: () => loadedOrder.add('A'),
            onCancel: () {},
          ),
        );
        notifier.addRequest(
          createMockRequest(
            'B',
            onLoad: () => loadedOrder.add('B'),
            onCancel: () {},
          ),
        );
        notifier.addRequest(
          createMockRequest(
            'C',
            onLoad: () => loadedOrder.add('C'),
            onCancel: () {},
          ),
        );
        notifier.addRequest(
          createMockRequest(
            'B',
            onLoad: () => loadedOrder.add('B'),
            onCancel: () {},
          ),
        );

        expect(notifier.state.pendingRequests.map((r) => r.imageUrl).toList(), [
          'C',
          'B',
        ]);

        notifier.completeLoad('A');
        expect(loadedOrder, ['A', 'B']);

        notifier.completeLoad('B');
        expect(loadedOrder, ['A', 'B', 'C']);
      },
    );

    test('Concurrency Limit: Does not start more loads than maxConcurrent', () {
      final loadedUrls = <String>[];
      final notifier = TestableMediaLoaderNotifier(maxConcurrent: 2);

      notifier.addRequest(
        createMockRequest(
          'A',
          onLoad: () => loadedUrls.add('A'),
          onCancel: () {},
        ),
      );
      notifier.addRequest(
        createMockRequest(
          'B',
          onLoad: () => loadedUrls.add('B'),
          onCancel: () {},
        ),
      );
      notifier.addRequest(
        createMockRequest(
          'C',
          onLoad: () => loadedUrls.add('C'),
          onCancel: () {},
        ),
      );
      notifier.addRequest(
        createMockRequest(
          'D',
          onLoad: () => loadedUrls.add('D'),
          onCancel: () {},
        ),
      );

      // With concurrency of 2, 'A' and 'B' should have started loading.
      expect(loadedUrls, ['A', 'B']);
      expect(notifier.activeLoads, 2);
      // 'C' and 'D' should be waiting in the queue.
      expect(notifier.state.pendingRequests.map((r) => r.imageUrl).toList(), [
        'C',
        'D',
      ]);

      // Complete 'A'. A slot opens up. The last queued item ('D') should start.
      notifier.completeLoad('A');
      expect(loadedUrls, ['A', 'B', 'D']);
      expect(notifier.activeLoads, 2);
      expect(notifier.state.pendingRequests.map((r) => r.imageUrl).toList(), [
        'C',
      ]);
    });

    test(
      'Already Loaded: Immediately calls onLoad for an already loaded URL',
      () {
        var onLoadCalled = false;
        final notifier = TestableMediaLoaderNotifier();

        // Manually set state to simulate 'A' is already loaded.
        notifier.state = notifier.state.copyWith(loadedUrls: {'A'});

        // Add a request for the already loaded URL.
        notifier.addRequest(
          createMockRequest(
            'A',
            onLoad: () => onLoadCalled = true,
            onCancel: () {},
          ),
        );

        // onLoad should be called instantly.
        expect(onLoadCalled, isTrue);
        // Nothing should be queued or in progress.
        expect(notifier.state.pendingRequests.isEmpty, isTrue);
        expect(notifier.activeLoads, 0);
      },
    );
  });
}
