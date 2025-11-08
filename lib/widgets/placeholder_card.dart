// lib/widgets/staggered_build_card.dart (建议重命名)

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class StaggeredBuildCard extends StatefulWidget {
  final Widget child;
  final double aspectRatio;
  final int buildSteps;
  // 【新】一个布尔值，用于从外部控制是否开始构建
  final bool shouldStartBuilding;
  final Widget? placeholder;
  const StaggeredBuildCard({
    super.key,
    required this.child,
    required this.aspectRatio,
    this.buildSteps = 2,
    this.shouldStartBuilding = true, // 默认立即开始
    this.placeholder, // 新增参数
  });

  @override
  State<StaggeredBuildCard> createState() => _StaggeredBuildCardState();
}

class _StaggeredBuildCardState extends State<StaggeredBuildCard> {
  int _currentBuildStep = 0;
  bool _hasStarted = false; // 追踪是否已经启动过

  @override
  void initState() {
    super.initState();
    // 如果初始状态就是应该构建，则立即启动
    if (widget.shouldStartBuilding) {
      _startBuilding();
    }
  }

  // 【核心改造】
  @override
  void didUpdateWidget(covariant StaggeredBuildCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当 shouldStartBuilding 从 false 变为 true 时，启动构建过程
    if (widget.shouldStartBuilding && !oldWidget.shouldStartBuilding) {
      _startBuilding();
    }
  }

  void _startBuilding() {
    // 防止重复启动
    if (_hasStarted) return;
    _hasStarted = true;
    _scheduleNextStep();
  }

  void _scheduleNextStep() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _currentBuildStep++;
      });
      if (_currentBuildStep < widget.buildSteps) {
        _scheduleNextStep();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).canvasColor,
        borderRadius: BorderRadius.zero,
      ),
      child: AspectRatio(
        aspectRatio: widget.aspectRatio,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 100),
          child: _buildContentForStep(),
        ),
      ),
    );
  }

  Widget _buildContentForStep() {
    if (_currentBuildStep >= widget.buildSteps) {
      return KeyedSubtree(
        key: const ValueKey('final_child'),
        child: widget.child,
      );
    }

    // 【核心改造】
    // 如果调用者提供了自定义占位符，我们就使用它
    if (widget.placeholder != null) {
      // 我们可以让骨架屏和初始占位符都使用这个 placeholder
      return Container(
        child: KeyedSubtree(
          key: const ValueKey('custom_placeholder'),
          child: widget.placeholder!,
        ),
      );
    }

    // 如果没有提供，则回退到之前的默认行为
    if (_currentBuildStep >= 1) {
      return Container(
        key: const ValueKey('skeleton'),
        color: Theme.of(context).canvasColor.withOpacity(0.5),
        child: Center(
          child: Icon(
            Icons.image_outlined,
            color: Colors.grey.shade400,
            size: 40,
          ),
        ),
      );
    }

    return Container(
      key: const ValueKey('placeholder'),
      color: Colors.grey.shade300,
    );
  }
}
