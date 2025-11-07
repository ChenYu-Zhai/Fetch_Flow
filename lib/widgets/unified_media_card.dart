import 'dart:async';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:featch_flow/models/unified_post_model.dart';
import 'package:featch_flow/providers/floating_preview_provider.dart';
import 'package:featch_flow/providers/settings_provider.dart';
import 'package:featch_flow/providers/video_controller_provider.dart';
import 'package:featch_flow/widgets/download_button.dart';
import 'package:featch_flow/widgets/media_preview_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:featch_flow/providers/cache_manager_provider.dart';
import 'package:visibility_detector/visibility_detector.dart';

class UnifiedMediaCard extends ConsumerStatefulWidget {
  final UnifiedPostModel post;
  const UnifiedMediaCard({super.key, required this.post});

  @override
  ConsumerState<UnifiedMediaCard> createState() => _UnifiedMediaCardState();
}

class _UnifiedMediaCardState extends ConsumerState<UnifiedMediaCard> {
  final _isHovering = ValueNotifier<bool>(false);
  bool _isVisible = false;
  late String _currentPostId;
  Timer? _disposeTimer;

  String get _hoverInfoText {
    if (widget.post.source == 'civitai') {
      return widget.post.originalData['meta']?['prompt'] ??
          widget.post.tags.take(5).join(', ');
    }
    return widget.post.tags.take(5).join(', ');
  }

  String get _badgeText {
    final type = widget.post.mediaType.toString().split('.').last.toUpperCase();
    final resolution = '${widget.post.width}×${widget.post.height}';
    return '$type • $resolution';
  }

  @override
  void initState() {
    super.initState();
    _currentPostId = widget.post.id;
    debugPrint('🎬 [UnifiedMediaCard] INIT: ${widget.post.id}');
  }

  @override
  void didUpdateWidget(UnifiedMediaCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.post.id != _currentPostId) {
      debugPrint(
        '🔄 [UnifiedMediaCard] POST CHANGED: $_currentPostId -> ${widget.post.id}',
      );
      _currentPostId = widget.post.id;
      _isVisible = false;
      _disposeTimer?.cancel();
      _isHovering.value = false;
    }
  }

  @override
  void dispose() {
    debugPrint('🗑️ [UnifiedMediaCard] DISPOSE: $_currentPostId');
    _disposeTimer?.cancel();
    _isHovering.dispose();
    super.dispose();
  }
  // lib/widgets/unified_media_card.dart

  @override
  Widget build(BuildContext context) {
    // ✅ 使用配置：卡片高度
    final cardHeight = ref.watch(cardHeightProvider);

    return SizedBox(
      height: cardHeight, // ✅ 动态高度
      child: Container(
        margin: const EdgeInsets.all(2.0),
        decoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
          border: Border.all(
            color: Colors.grey.withValues(alpha: 0.1),
            width: 0.5,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              // ✅ 媒体区域自适应
              child: _MediaArea(
                post: widget.post,
                isHovering: _isHovering,
                onTap: () => _showPreview(context),
                onVisibilityChanged: _handleVisibilityChange,
                badgeText: _badgeText,
                hoverInfoText: _hoverInfoText,
                child: Hero(tag: widget.post.id, child: _buildMediaContent()),
              ),
            ),
            const SizedBox(height: 44.0), // ✅ Footer 固定高度 44px
          ],
        ),
      ),
    );
  }

  // ✅ 简化：移除高度计算逻辑
  Widget _buildMediaContent() {
    if (widget.post.mediaType == MediaType.video) {
      final videoProvider = videoControllerProvider(
        VideoPlayerConfig(
          videoUrl: widget.post.fullImageUrl,
          autoplay: false,
          loop: true,
        ),
      );
      final asyncController = ref.watch(videoProvider);

      return asyncController.when(
        data: (controller) {
          if (_isVisible)
            controller.player.play();
          else
            controller.player.pause();
          return Video(controller: controller);
        },
        loading: () => _ImageRenderer(
          imageUrl: widget.post.previewImageUrl,
          fit: BoxFit.contain, // ✅ 保持原比例
          alignment: Alignment.center, // ✅ 明确居中
        ),
        error: (error, stack) =>
            const Center(child: Icon(Icons.error, size: 20)),
      );
    }

    return _ImageRenderer(
      imageUrl: widget.post.previewImageUrl,
      fit: BoxFit.contain, // ✅ 保持原比例
      alignment: Alignment.center, // ✅ 明确居中
    );
  }

  void _handleVisibilityChange(VisibilityInfo info) {
    final visibleFraction = info.visibleFraction;
    debugPrint(
      '👁️ [UnifiedMediaCard] Visibility: ${widget.post.id} = $visibleFraction',
    );

    if (visibleFraction < 0.1) {
      _disposeTimer?.cancel();
      _disposeTimer = Timer(const Duration(seconds: 2), () {
        if (!mounted) return;
        if (_isVisible) {
          setState(() => _isVisible = false);
          debugPrint('🔄 [${widget.post.id}] Set _isVisible = false');
        }
      });
    } else {
      _disposeTimer?.cancel();
      if (!_isVisible && mounted) {
        setState(() => _isVisible = true);
        debugPrint('🔄 [${widget.post.id}] Set _isVisible = true');
      }
    }
  }

  void _showPreview(BuildContext context) {
    // ✅ 改为打开悬浮预览
    openFloatingPreview(ref, widget.post);
  }
}

class _MediaArea extends StatelessWidget {
  final UnifiedPostModel post;
  final ValueNotifier<bool> isHovering;
  final VoidCallback onTap;
  final Function(VisibilityInfo) onVisibilityChanged;
  final String badgeText;
  final String hoverInfoText;
  final Widget child;

  const _MediaArea({
    required this.post,
    required this.isHovering,
    required this.onTap,
    required this.onVisibilityChanged,
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
        child: VisibilityDetector(
          key: Key(post.id),
          onVisibilityChanged: onVisibilityChanged,
          child: Stack(
            children: [
              child,
              ValueListenableBuilder<bool>(
                valueListenable: isHovering,
                builder: (context, hovering, __) {
                  return AnimatedOpacity(
                    duration: const Duration(milliseconds: 100),
                    opacity: hovering ? 0.15 : 0.0,
                    child: Container(color: Colors.black),
                  );
                },
              ),
              Positioned(top: 4, right: 4, child: _buildBadge(badgeText)),
              _buildHoverText(hoverInfoText, isHovering),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.7)),
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
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
          ),
        );
      },
    );
  }
}

class _ImageRenderer extends ConsumerWidget {
  final String imageUrl;
  final Alignment alignment;
  final BoxFit fit; // ✅ 新增
  const _ImageRenderer({
    required this.imageUrl,
    this.alignment = Alignment.center,
    this.fit = BoxFit.contain,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cacheManager = ref.watch(customCacheManagerProvider);
    return Center(
      child: FittedBox(
        fit: BoxFit.contain,
        child: CachedNetworkImage(
          cacheManager: cacheManager,
          imageUrl: imageUrl,
          fit: BoxFit.contain,
          alignment: alignment,
          fadeInDuration: const Duration(milliseconds: 50),
          fadeOutDuration: const Duration(milliseconds: 20),
          placeholder: (context, url) => const SizedBox.shrink(),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey.shade300,
            child: const Icon(Icons.broken_image, size: 16),
          ),
        ),
      ),
    );
  }
}

// ✅ FIXED: 修正所有问题
class TagDetailsDialog extends StatelessWidget {
  final UnifiedPostModel post;
  const TagDetailsDialog({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final dynamic meta = post.originalData['meta'];
    String? prompt;
    if (post.source == 'civitai' &&
        meta is Map<String, dynamic> &&
        meta['prompt'] is String &&
        (meta['prompt'] as String).trim().isNotEmpty) {
      prompt = meta['prompt'] as String;
    }

    final String content = (prompt != null && prompt.isNotEmpty)
        ? prompt
        : post.tags.join(', ');

    final items = content
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    return Dialog(
      backgroundColor: Theme.of(context).cardColor,
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
                      .toList(), // ✅ FIXED
                ),
              ),
            ),
            _buildDialogActions(context, items),
          ],
        ),
      ),
    );
  }

  // ✅ FIXED: 定义为实例方法
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

  // ✅ FIXED: 定义为实例方法
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
    return Padding(
      padding: const EdgeInsets.only(top: 8),
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
            child: const Text('复制全部'),
          ),
          const SizedBox(width: 6),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}
