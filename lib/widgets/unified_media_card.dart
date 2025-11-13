// lib/widgets/unified_media_card.dart

import 'dart:math';

import 'package:featch_flow/models/unified_post_model.dart';
import 'package:featch_flow/providers/floating_preview_provider.dart';
import 'package:featch_flow/utils/image_renderer.dart';
import 'package:featch_flow/widgets/download_button.dart';
import 'package:featch_flow/widgets/intelligent_video_player.dart';
import 'package:featch_flow/widgets/show_tag_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visibility_detector/visibility_detector.dart';

const double kCardFooterHeight = 44.0;

class UnifiedMediaCard extends ConsumerStatefulWidget {
  final UnifiedPostModel post;
  final ValueNotifier<bool> isDraggingNotifier;

  const UnifiedMediaCard({
    super.key,
    required this.post,
    required this.isDraggingNotifier,
  });

  @override
  ConsumerState<UnifiedMediaCard> createState() => _UnifiedMediaCardState();
}

class _UnifiedMediaCardState extends ConsumerState<UnifiedMediaCard> {
  final _isHovering = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _isHovering.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final badgeText =
        '${widget.post.mediaType.toString().split('.').last.toUpperCase()} • ${widget.post.width}×${widget.post.height}';
    final hoverInfoText = widget.post.tags?.take(5).join(', ') ?? '';

    return ValueListenableBuilder<bool>(
      valueListenable: widget.isDraggingNotifier,
      builder: (context, isDragging, __) {
        final mediaContent = _buildMediaContent(isDragging);

        return Container(
          color: Theme.of(context).canvasColor,
          child: RepaintBoundary(
            child: Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Hero(
                          tag: widget.post.id,
                          child: Center(child: mediaContent),
                        ),
                      ),
                      _MediaOverlay(
                        post: widget.post,
                        isVisible: !isDragging,
                        isHovering: _isHovering,
                        onTap: () => openFloatingPreview(ref, widget.post),
                        badgeText: badgeText,
                        hoverInfoText: hoverInfoText,
                      ),
                    ],
                  ),
                ),
                _AnimatedFooter(
                  isVisible: !isDragging,
                  child: _buildButtonBar(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMediaContent(bool isDragging) {
    if (widget.post.mediaType == MediaType.video &&
        widget.post.fullImageUrl.isNotEmpty) {
      return IntelligentVideoPlayer(
        videoUrl: widget.post.fullImageUrl,
        previewImageUrl: widget.post.previewImageUrl,
        isPausedByDrag: isDragging,
      );
    }
    return VisibilityDetector(
      key: ValueKey(widget.post.id),
      onVisibilityChanged: (info) {
        // 你的逻辑
      },
      child: ImageRenderer(
        imageUrl: widget.post.previewImageUrl,
        fit: BoxFit.contain,
        alignment: Alignment.center,
      ),
    );
  }

  Widget _buildButtonBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ShowTagButton(post: widget.post),
        DownloadButton(post: widget.post),
      ],
    );
  }
}

class _MediaOverlay extends StatelessWidget {
  final UnifiedPostModel post;
  final bool isVisible;
  final ValueNotifier<bool> isHovering;
  final VoidCallback onTap;
  final String badgeText;
  final String hoverInfoText;

  const _MediaOverlay({
    required this.post,
    required this.isVisible,
    required this.isHovering,
    required this.onTap,
    required this.badgeText,
    required this.hoverInfoText,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isVisible ? 1.0 : 0.0,
      child: IgnorePointer(
        ignoring: !isVisible,
        child: MouseRegion(
          onEnter: (_) => isHovering.value = true,
          onExit: (_) => isHovering.value = false,
          child: InkWell(
            onTap: onTap,
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ValueListenableBuilder<bool>(
                  valueListenable: isHovering,
                  builder: (_, hovering, __) => AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: hovering ? 1.0 : 0.0,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.7),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.7],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: _buildBadge(context, badgeText),
                ),
                _buildHoverText(context, hoverInfoText),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.7)),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildHoverText(BuildContext context, String text) {
    return ValueListenableBuilder<bool>(
      valueListenable: isHovering,
      builder: (_, hovering, __) => AnimatedPositioned(
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        bottom: hovering ? 8.0 : -40.0,
        left: 8.0,
        right: 8.0,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 100),
          opacity: hovering ? 1.0 : 0.0,
          child: Text(
            text,
            maxLines: 99,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      ),
    );
  }
}

class _AnimatedFooter extends StatelessWidget {
  final bool isVisible;
  final Widget child;

  const _AnimatedFooter({required this.isVisible, required this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: kCardFooterHeight,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        opacity: isVisible ? 1.0 : 0.0,
        child: IgnorePointer(ignoring: !isVisible, child: child),
      ),
    );
  }
}

class TagDetailsDialog extends StatelessWidget {
  final UnifiedPostModel post;
  const TagDetailsDialog({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final dynamic meta = post.originalData!['meta'];
    String? prompt;
    if (post.source == 'civitai' &&
        meta is Map<String, dynamic> &&
        meta['prompt'] is String &&
        (meta['prompt'] as String).trim().isNotEmpty) {
      prompt = meta['prompt'] as String;
    }
    final String content = (prompt != null && prompt.isNotEmpty)
        ? prompt
        : post.tags!.join(', ');
    final items = content
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    return Dialog(
      backgroundColor: Theme.of(context).canvasColor,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
      child: Container(
        width: min(500, MediaQuery.of(context).size.width * 0.9),
        height: min(600, MediaQuery.of(context).size.height * 0.7),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.tag, color: colorScheme.primary),
                const SizedBox(width: 12),
                Text('Tags & Prompt', style: textTheme.titleLarge),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  splashRadius: 20,
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _buildInfoChip(
                  context,
                  'Type',
                  post.mediaType.toString().split('.').last,
                ),
                _buildInfoChip(context, 'Resolution', '${post.width}×${post.height}'),
                _buildInfoChip(context, 'Count', '${items.length} items'),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: items
                      .map((item) => _buildTagChip(context, item))
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 8),
            _buildDialogActions(context, items),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.zero,
      ),
      child: RichText(
        text: TextSpan(
          style: theme.textTheme.bodyMedium,
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(
              text: value,
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagChip(BuildContext context, String item) {
    final theme = Theme.of(context);
    return ActionChip(
      label: Text(
        item,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      ),
      backgroundColor: Theme.of(context).cardColor,
      side: BorderSide(color: theme.colorScheme.secondaryContainer, width: 1.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      onPressed: () {
        Clipboard.setData(ClipboardData(text: item));
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.transparent,
            elevation: 0,

            content: _AnimatedSnackBarContent(message: 'Copied: $item'),
            duration: const Duration(milliseconds: 1500),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            padding: EdgeInsets.zero,
          ),
        );
      },
    );
  }

  Widget _buildDialogActions(BuildContext context, List<String> items) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: items.join(', ')));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('All copied to clipboard'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.onSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: const Text('Copy All'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            ),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _AnimatedSnackBarContent extends StatefulWidget {
  final String message;

  const _AnimatedSnackBarContent({required this.message});

  @override
  State<_AnimatedSnackBarContent> createState() =>
      _AnimatedSnackBarContentState();
}

class _AnimatedSnackBarContentState extends State<_AnimatedSnackBarContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      reverseDuration: const Duration(milliseconds: 200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeIn,
          ),
        );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: theme.snackBarTheme.backgroundColor ?? Colors.grey.shade800,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            widget.message,
            style:
                theme.snackBarTheme.contentTextStyle ??
                const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
