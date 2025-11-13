// lib/widgets/stable_drag_scrollbar.dart

import 'dart:async';
import 'package:flutter/material.dart';

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
    this.timeToFade = const Duration(milliseconds: 5000),
    this.onDragStart,
    this.onDragEnd,
  });

  @override
  State<StableDragScrollbar> createState() => _StableDragScrollbarState();
}

class _StableDragScrollbarState extends State<StableDragScrollbar>
    with SingleTickerProviderStateMixin {
  final GlobalKey _scrollbarKey = GlobalKey();
  late final AnimationController _fadeController;
  Timer? _fadeoutTimer;

  double _dragStartPosition = 0.0;
  double _scrollOffsetAtDragStart = 0.0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: widget.fadeDuration,
    );
    widget.controller.addListener(_showAndScheduleFadeOut);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_showAndScheduleFadeOut);
    _fadeoutTimer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  void _showAndScheduleFadeOut() {
    _fadeController.forward();

    _fadeoutTimer?.cancel();
    _fadeoutTimer = Timer(widget.timeToFade, () {
      if (mounted) {
        _fadeController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      child: widget.child,
      builder: (context, child) {
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
        final bool isScrollbarVisible = scrollbar is! SizedBox;
        return Stack(
          children: [
            child!,
            // ✅ 解决方案：只有在滚动条可见时，才将其添加到 Stack 中
            if (isScrollbarVisible)
              FadeTransition(opacity: _fadeController, child: scrollbar),
          ],
        );
      },
    );
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    final RenderBox? scrollbarRenderBox =
        _scrollbarKey.currentContext?.findRenderObject() as RenderBox?;
    if (scrollbarRenderBox == null || !scrollbarRenderBox.hasSize) return;

    final double scrollbarTrackExtent = scrollbarRenderBox.size.height;
    if (scrollbarTrackExtent <= 0) return;

    final position = widget.controller.position;
    final double viewportDimension = position.viewportDimension;
    final double maxScrollExtent = position.maxScrollExtent;
    final double contentDimension = viewportDimension + maxScrollExtent;
    final double thumbHeight =
        (viewportDimension / contentDimension) * viewportDimension;
    final double finalThumbHeight = thumbHeight.clamp(24.0, viewportDimension);
    final double thumbMovableExtent = scrollbarTrackExtent - finalThumbHeight;

    if (thumbMovableExtent <= 0) return;

    final double scrollRatio = maxScrollExtent / thumbMovableExtent;

    final double scrollDelta = details.delta.dy * scrollRatio;

    const double maxScrollPerFrame = 10000.0;
    final double clampedScrollDelta = scrollDelta.clamp(
      -maxScrollPerFrame,
      maxScrollPerFrame,
    );

    final double newScrollOffset =
        (widget.controller.offset + clampedScrollDelta).clamp(
          0.0,
          maxScrollExtent,
        );

    widget.controller.jumpTo(newScrollOffset);
  }

  void _handleDragStart(DragStartDetails details) {
    _isDragging = true;
    _fadeoutTimer?.cancel();
    _fadeController.forward();

    _dragStartPosition = details.globalPosition.dy;
    _scrollOffsetAtDragStart = widget.controller.position.pixels;
    widget.onDragStart?.call();
  }

  void _handleDragEnd(DragEndDetails details) {
    _isDragging = false;
    _showAndScheduleFadeOut();
    widget.onDragEnd?.call();
  }
}
