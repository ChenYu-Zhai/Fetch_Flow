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
  final ValueNotifier<bool> isDraggingNotifier; // <<< 1. 添加新参数

  const UnifiedMediaCard({
    super.key,
    required this.post,
    required this.isDraggingNotifier, // <<< 2. 提供默认值
  });

  @override
  ConsumerState<UnifiedMediaCard> createState() => _UnifiedMediaCardState();
}

class _UnifiedMediaCardState extends ConsumerState<UnifiedMediaCard>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // 使用 ValueListenableBuilder 来监听状态变化
    return ValueListenableBuilder<bool>(
      valueListenable: widget.isDraggingNotifier,
      builder: (context, isDragging, child) {

        return Container(
          color: Theme.of(context).canvasColor,
          child: isDragging ? _buildFastScrollView() : _buildFullCardView(),
        );
      },
    );
  }

  /// 快速滚动时的简化版UI
  Widget _buildFastScrollView() {
    return Column(
      children: [
        // 只显示媒体内容
        Expanded(child: _buildMediaContent()),
        // 用一个占位符保持总高度一致，防止布局跳动
        const SizedBox(height: kCardFooterHeight),
      ],
    );
  }

  /// 正常状态下的完整卡片UI
  Widget _buildFullCardView() {
    final isHovering = ValueNotifier<bool>(false);

    final String badgeText =
        '${widget.post.mediaType.toString().split('.').last.toUpperCase()} • ${widget.post.width}×${widget.post.height}';
    final String hoverInfoText = widget.post.tags?.take(5).join(', ') ?? '';

    return RepaintBoundary(
      child: Column(
        children: [
          Expanded(
            child: _MediaArea(
              post: widget.post,
              isHovering: isHovering,
              onTap: () => openFloatingPreview(ref, widget.post),
              badgeText: badgeText,
              hoverInfoText: hoverInfoText,
              child: Hero(
                tag: widget.post.id,
                child: Center(child: _buildMediaContent()),
              ),
            ),
          ),
          SizedBox(height: kCardFooterHeight, child: _buildButtonBar()),
        ],
      ),
    );
  }

  Widget _buildMediaContent() {
    if (widget.post.mediaType == MediaType.video &&
        widget.post.fullImageUrl.isNotEmpty) {
      return IntelligentVideoPlayer(
        videoUrl: widget.post.fullImageUrl,
        previewImageUrl: widget.post.previewImageUrl,
      );
    }
    return VisibilityDetector(
      key: ValueKey(widget.post.id),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.5) {
          // 视口内 ≥ 50% 显示，提升权重
        } else {
          // 减弱或延迟
        }
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

class _MediaArea extends StatelessWidget {
  final UnifiedPostModel post;
  final ValueNotifier<bool> isHovering;
  final VoidCallback onTap;
  // ❌ final Function(VisibilityInfo) onVisibilityChanged;
  final String badgeText;
  final String hoverInfoText;
  final Widget child;

  const _MediaArea({
    required this.post,
    required this.isHovering,
    required this.onTap,
    // required this.onVisibilityChanged,
    required this.badgeText,
    required this.hoverInfoText,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => isHovering.value = true,
      onExit: (_) => isHovering.value = false,
      child: InkWell(
        onTap: onTap,
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        child: Stack(
          fit: StackFit.expand, // 确保 Stack 填满
          children: [
            child,
            ValueListenableBuilder<bool>(
              valueListenable: isHovering,
              builder: (context, hovering, __) {
                return AnimatedOpacity(
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
                );
              },
            ),
            Positioned(top: 4, right: 4, child: _buildBadge(badgeText)),
            _buildHoverText(hoverInfoText, isHovering),
          ],
        ),
      ),
    );
  }

  // _buildBadge 和 _buildHoverText 方法保持不变
  Widget _buildBadge(String text) {
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

  Widget _buildHoverText(String text, ValueNotifier<bool> hovering) {
    return ValueListenableBuilder<bool>(
      valueListenable: hovering,
      builder: (context, isHovering, __) {
        return AnimatedPositioned(
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
          bottom: isHovering ? 8.0 : -40.0,
          left: 8.0,
          right: 8.0,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 100),
            opacity: isHovering ? 1.0 : 0.0,
            child: Text(
              text,
              maxLines: 99,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        );
      },
    );
  }
}

class TagDetailsDialog extends StatelessWidget {
  final UnifiedPostModel post;
  const TagDetailsDialog({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
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
      backgroundColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8), // ← 这里改小
      ),
      child: Container(
        width: min(500, MediaQuery.of(context).size.width * 0.9),
        height: min(600, MediaQuery.of(context).size.height * 0.7),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ FIXED: 内联 header 而不是调用未定义的方法
            Row(
              children: [
                Icon(Icons.tag, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Tags & Prompt',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Wrap(
                spacing: 12,
                children: [
                  _buildInfoChip(
                    context,
                    '类型',
                    post.mediaType.toString().split('.').last,
                  ),
                  _buildInfoChip(
                    context,
                    '分辨率',
                    '${post.width}×${post.height}',
                  ),
                  _buildInfoChip(context, '数量', '${items.length} 个'),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: items
                      .map((item) => _buildTagChip(context, item))
                      .toList(),
                ),
              ),
            ),
            _buildDialogActions(context, items),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, String label, String value) {
    return Chip(
      label: RichText(
        text: TextSpan(
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
      backgroundColor: Theme.of(context).cardColor,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildTagChip(BuildContext context, String item) {
    return ActionChip(
      label: Text(item, style: const TextStyle(fontSize: 13)),
      backgroundColor: Colors.blue.withValues(alpha: 0.1),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      onPressed: () {
        Clipboard.setData(ClipboardData(text: item));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('已复制: $item'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
    );
  }

  Widget _buildDialogActions(BuildContext context, List<String> items) {
    // 1. 获取当前主题，以便访问颜色和文本样式
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(
        top: 16,
        right: 8,
        bottom: 8,
      ), // 增加上下和右侧的 padding
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: items.join(', ')));
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('已复制到剪贴板')));
            },
            style: TextButton.styleFrom(
              foregroundColor: theme.textTheme.bodyLarge?.color?.withOpacity(
                0.8,
              ),

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),

              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: const Text('复制全部'),
          ),

          const SizedBox(width: 8),

          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              elevation: 2,
              shadowColor: Colors.black.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),

              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}
