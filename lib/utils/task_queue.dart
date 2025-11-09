// lib/utils/task_queue.dart

import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';

/// 控制并发度的信号量工具
class Semaphore {
  final int _maxConcurrency;
  int _currentConcurrency = 0;
  final Queue<Completer<void>> _queue = Queue();

  Semaphore(this._maxConcurrency);

  Future<void> acquire() async {
    if (_currentConcurrency < _maxConcurrency) {
      _currentConcurrency++;
      return;
    } else {
      final completer = Completer<void>();
      _queue.add(completer);
      await completer.future;
    }
  }

  void release() {
    if (_queue.isNotEmpty) {
      final completer = _queue.removeFirst();
      completer.complete();
    } else {
      _currentConcurrency--;
    }
  }
}

/// 简单的任务派发池
class PreloadTaskQueue {
  static final _singleton = PreloadTaskQueue._();
  static PreloadTaskQueue get instance => _singleton;

  PreloadTaskQueue._() {
    _initWorkers();
  }

  final StreamController<Future<void> Function()> _taskController =
      StreamController.broadcast();

  final _semaphore = Semaphore(4); // 最大并发数设为 4

  StreamSubscription? _subscription;

  void submit(Future<void> Function() task) {
    _taskController.add(task);
  }

  void _initWorkers() {
    _subscription = _taskController.stream.listen((task) async {
      await _semaphore.acquire();
      try {
        await task().timeout(const Duration(seconds: 10), onTimeout: () {
          debugPrint("⏰ Task timeout");
          return null;
        });
      } catch (e, s) {
        debugPrint('🚨 Preload task error: $e\n$s');
      } finally {
        _semaphore.release();
      }
    });
  }

  void dispose() {
    _subscription?.cancel();
    _taskController.close();
  }
}