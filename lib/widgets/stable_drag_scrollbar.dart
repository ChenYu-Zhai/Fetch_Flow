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
    this.timeToFade = const Duration(
      milliseconds: 5000,
    ), // Adjusted for a more reasonable default
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

  // State variables for dragging logic
  double _dragStartPosition = 0.0;
  double _scrollOffsetAtDragStart = 0.0;
  bool _isDragging = false; // Internal flag to track drag state

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: widget.fadeDuration,
    );
    // Add a listener that ONLY handles the fade animation.
    // It does NOT call setState, thus preventing layout rebuilds.
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

        // Only build the scrollbar if it's actually possible to scroll.
        if (position == null || position.maxScrollExtent <= 0) {
          scrollbar = const SizedBox.shrink();
        } else {
          // Calculate the scrollbar thumb's size and position based on the current scroll offset.
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

          // The visible scrollbar widget.
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

        // The final layout: a Stack containing the non-rebuilt child and the lightweight scrollbar.
        return Stack(
          children: [
            child!, // The cached `widget.child` is placed here.
            FadeTransition(opacity: _fadeController, child: scrollbar),
          ],
        );
      },
    );
  }

  void _handleDragStart(DragStartDetails details) {
    _isDragging = true;
    _fadeoutTimer?.cancel();
    _fadeController.forward(); // Ensure scrollbar is fully visible on drag.

    _dragStartPosition = details.globalPosition.dy;
    _scrollOffsetAtDragStart = widget.controller.position.pixels;
    widget.onDragStart?.call();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    // This uses the "total displacement" model, which is more robust and intuitive.
    // It calculates how far the user's finger has moved from the start of the drag
    // and maps that distance to the scrollable content area.

    final RenderBox? scrollbarRenderBox =
        _scrollbarKey.currentContext?.findRenderObject() as RenderBox?;
    if (scrollbarRenderBox == null || !scrollbarRenderBox.hasSize) return;

    final double scrollbarTrackExtent = scrollbarRenderBox.size.height;
    if (scrollbarTrackExtent <= 0) return;

    // 1. Calculate the total vertical distance the user's finger has moved.
    final double dragDisplacement =
        details.globalPosition.dy - _dragStartPosition;

    // 2. Calculate the ratio of content scroll range to scrollbar track height.
    final double scrollRatio =
        widget.controller.position.maxScrollExtent / scrollbarTrackExtent;

    // 3. Determine how much the content should scroll based on the finger's movement.
    final double scrollDelta = dragDisplacement * scrollRatio;

    // 4. Calculate the new scroll offset and clamp it within valid bounds.
    final double targetOffset = (_scrollOffsetAtDragStart + scrollDelta).clamp(
      0.0,
      widget.controller.position.maxScrollExtent,
    );

    widget.controller.jumpTo(targetOffset);
  }

  void _handleDragEnd(DragEndDetails details) {
    _isDragging = false;
    // After dragging, restart the fade-out timer.
    _showAndScheduleFadeOut();
    widget.onDragEnd?.call();
  }
}
