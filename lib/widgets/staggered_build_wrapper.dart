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
  final List<Widget> _builtItems = [];
  final List<T> _pendingItems = [];
  
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pendingItems.addAll(widget.items);
    _startScheduler();
  }

  @override
  void didUpdateWidget(covariant StaggeredBuildWrapper<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
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