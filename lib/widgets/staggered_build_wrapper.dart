// lib/widgets/staggered_build_wrapper.dart

import 'dart:async';
import 'package:flutter/material.dart';

// 定义一个 Widget 构建器的函数类型
typedef StaggeredItemBuilder<T> = Widget Function(BuildContext context, T item);

class StaggeredBuildWrapper<T> extends StatefulWidget {
  // 原始的数据列表
  final List<T> items;
  // 构建单个列表项的函数
  final StaggeredItemBuilder<T> itemBuilder;
  // ListView, GridView 等的构建器
  final Widget Function(BuildContext context, int itemCount, IndexedWidgetBuilder itemBuilder) builder;
  // 每帧构建的组件数量
  final int itemsPerFrame;
  
  const StaggeredBuildWrapper({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.builder,
    this.itemsPerFrame = 1, // 默认每帧构建2个
  });

  @override
  State<StaggeredBuildWrapper<T>> createState() => _StaggeredBuildWrapperState<T>();
}

class _StaggeredBuildWrapperState<T> extends State<StaggeredBuildWrapper<T>> {
  // 已经构建好的 Widget 列表
  final List<Widget> _builtItems = [];
  // 待处理的任务队列
  final List<T> _pendingItems = [];
  
  // 用于周期性调度的 Timer
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // 初始时，将所有 item 加入待处理队列
    _pendingItems.addAll(widget.items);
    // 启动构建调度器
    _startScheduler();
  }

  @override
  void didUpdateWidget(covariant StaggeredBuildWrapper<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当外部传入的 item 列表变化时（例如，刷新或加载了新数据）
    // 我们需要重置状态
    if (widget.items != oldWidget.items) {
      _timer?.cancel();
      _builtItems.clear();
      _pendingItems.clear();
      _pendingItems.addAll(widget.items);
      _startScheduler();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startScheduler() {
    // 使用 Timer.periodic 来模拟一个接近“每帧”的调度
    // 16ms 约等于 60fps
    _timer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (_pendingItems.isEmpty) {
        timer.cancel(); // 队列为空，停止调度
        return;
      }
      
      // 【核心逻辑】
      // 计算本轮要构建多少个 item
      final count = _pendingItems.length > widget.itemsPerFrame 
                    ? widget.itemsPerFrame 
                    : _pendingItems.length;
                    
      // 从待处理队列中取出任务
      final itemsToBuild = _pendingItems.sublist(0, count);
      _pendingItems.removeRange(0, count);
      
      // 构建 Widget 并添加到已构建列表
      final newWidgets = itemsToBuild.map((item) => widget.itemBuilder(context, item));
      
      // 触发 UI 更新
      if(mounted) {
        setState(() {
          _builtItems.addAll(newWidgets);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 使用 widget.builder 来构建真正的列表视图
    return widget.builder(
      context,
      _builtItems.length, // itemCount 是已构建的数量
      (context, index) => _builtItems[index], // itemBuilder 直接返回已构建的 Widget
    );
  }
}