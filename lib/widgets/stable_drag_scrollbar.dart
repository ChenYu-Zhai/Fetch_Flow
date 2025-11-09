// lib/widgets/stable_drag_scrollbar.dart

import 'dart:async';

import 'package:flutter/material.dart';

// 1. 【核心修复】为 State 类添加 SingleTickerProviderStateMixin
class StableDragScrollbar extends StatefulWidget {
  final Widget child;
  final ScrollController controller;
  final double thickness;
  final Radius radius;
  final Duration fadeDuration;
  final Duration timeToFade;
  final VoidCallback? onDragStart;
  final VoidCallback? onDragEnd;
  const StableDragScrollbar({
    super.key,
    required this.child,
    required this.controller,
    this.thickness = 8.0,
    this.radius = const Radius.circular(4.0),
    this.fadeDuration = const Duration(milliseconds: 250),
    this.timeToFade = const Duration(milliseconds: 500),
    this.onDragStart,
    this.onDragEnd,
  });

  @override
  State<StableDragScrollbar> createState() => _StableDragScrollbarState();
}

class _StableDragScrollbarState extends State<StableDragScrollbar>
    with SingleTickerProviderStateMixin {
  final GlobalKey _scrollbarKey = GlobalKey();
  double _dragStartPosition = 0.0;
  double _scrollOffsetAtDragStart = 0.0;

  late final AnimationController _fadeController;
  Timer? _fadeoutTimer;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this, 
      duration: widget.fadeDuration,
    );
    widget.controller.addListener(_handleScroll);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleScroll);
    _fadeoutTimer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    _fadeController.forward();

    _fadeoutTimer?.cancel();
    _fadeoutTimer = Timer(widget.timeToFade, () {
      if (mounted) {
        _fadeController.reverse();
      }
    });

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final ScrollPosition? position = widget.controller.hasClients
        ? widget.controller.position
        : null;
    Widget scrollbar;

    if (position == null || position.maxScrollExtent <= 0) {
      scrollbar = const SizedBox.shrink();
    } else {
      final double viewportDimension = position.viewportDimension;
      final double maxScrollExtent = position.maxScrollExtent;
      final double contentDimension = viewportDimension + maxScrollExtent;

      final double thumbHeight =
          (viewportDimension / contentDimension) * viewportDimension;
      final double finalThumbHeight = thumbHeight.clamp(
        24.0,
        viewportDimension,
      );

      final double thumbOffset =
          (position.pixels / maxScrollExtent) *
          (viewportDimension - finalThumbHeight);

      scrollbar = GestureDetector(
        key: _scrollbarKey,
        onVerticalDragStart: _handleDragStart,
        onVerticalDragUpdate: _handleDragUpdate,
        onVerticalDragEnd: _handleDragEnd,
        child: Container(
          alignment: Alignment.topRight,
          margin: const EdgeInsets.only(right: 2.0),
          child: Container(
            margin: EdgeInsets.only(top: thumbOffset),
            height: finalThumbHeight,
            width: widget.thickness,
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).highlightColor.withAlpha((255 * 0.6).round()),
              borderRadius: BorderRadius.all(widget.radius),
            ),
          ),
        ),
      );
    }

    return Stack(
      children: [
        widget.child,
        FadeTransition(opacity: _fadeController, child: scrollbar),
      ],
    );
  }

  void _handleDragStart(DragStartDetails details) {
    _fadeoutTimer?.cancel();
    _fadeController.forward();
    _dragStartPosition = details.globalPosition.dy;
    _scrollOffsetAtDragStart = widget.controller.position.pixels;
    widget.onDragStart?.call();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    final RenderBox? scrollbarRenderBox =
        _scrollbarKey.currentContext?.findRenderObject() as RenderBox?;
    if (scrollbarRenderBox == null) return;

    final double scrollbarTrackExtent = scrollbarRenderBox.size.height;
    if (scrollbarTrackExtent <= 0) return;

    final double delta = details.delta.dy;

    const double maxDeltaPerFrame = 1.0; 
    final double clampedDelta = delta.clamp(
      -maxDeltaPerFrame,
      maxDeltaPerFrame,
    );

    final double scrollRatio =
        widget.controller.position.maxScrollExtent / scrollbarTrackExtent;

    final double scrollDelta = clampedDelta * scrollRatio;

    final targetOffset = (widget.controller.offset + scrollDelta).clamp(
      0.0,
      widget.controller.position.maxScrollExtent,
    );

    widget.controller.jumpTo(targetOffset);
  }

  void _handleDragEnd(DragEndDetails details) {
    // 通知父 widget 结束拖拽
    widget.onDragEnd?.call();
  }
}
