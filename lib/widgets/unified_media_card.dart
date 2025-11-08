import 'dart:async';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:featch_flow/models/unified_post_model.dart';
import 'package:featch_flow/providers/floating_preview_provider.dart';
import 'package:featch_flow/providers/settings_provider.dart';
import 'package:featch_flow/widgets/download_button.dart';
import 'package:featch_flow/widgets/intelligent_video_player.dart'; // ✅ 【重要】导入我们新的 Widget
import 'package:featch_flow/widgets/show_tag_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:featch_flow/providers/cache_manager_provider.dart';
import 'package:visibility_detector/visibility_detector.dart';


// ✅ 整个 State 都变得非常简单
class UnifiedMediaCard extends ConsumerWidget { // ⬅️ 可以考虑转为 ConsumerWidget，因为大部分 state 没了
  final UnifiedPostModel post;
  const UnifiedMediaCard({super.key, required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardHeight = ref.watch(cardHeightProvider);
    final isHovering = ValueNotifier<bool>(false); // 可以在 build 方法内创建

    // Badge 和 Hover Text 的逻辑可以移到这里
    final String badgeText = '${post.mediaType.toString().split('.').last.toUpperCase()} • ${post.width}×${post.height}';
    final String hoverInfoText = post.tags?.take(5).join(', ') ?? '';

    return SizedBox(
      height: cardHeight,
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
          border: Border.all(color: Colors.grey.withAlpha(25), width: 0.5),
        ),
        child: Column(
          children: [
            Expanded(
              child: _MediaArea(
                post: post,
                isHovering: isHovering,
                onTap: () => openFloatingPreview(ref, post),
                // ❌ 不再需要 onVisibilityChanged 回调
                // onVisibilityChanged: _handleVisibilityChange, 
                badgeText: badgeText,
                hoverInfoText: hoverInfoText,
                child: Hero(
                  tag: post.id,
                  // ✅ 核心修改在这里
                  child: Center(child: _buildMediaContent()),
                ),
              ),
            ),
            SizedBox(
              height: 44,
              child: _buildButtonBar(),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ 媒体构建逻辑变得极其简单
  Widget _buildMediaContent() {
    if (post.mediaType == MediaType.video && post.fullImageUrl.isNotEmpty) {
      // 如果是视频，直接使用 IntelligentVideoPlayer
      return IntelligentVideoPlayer(
        videoUrl: post.fullImageUrl, // ⬅️ 使用 videoUrl
        previewImageUrl: post.previewImageUrl,
      );
    }

    // 否则，使用 ImageRenderer
    return ImageRenderer(
      imageUrl: post.previewImageUrl,
      fit: BoxFit.contain,
      alignment: Alignment.center,
    );
  }

  Widget _buildButtonBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ShowTagButton(post: post),
        DownloadButton(post: post),
      ],
    );
  }
}


// ✅ _MediaArea Widget
// 移除了不再需要的 onVisibilityChanged 参数
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
        // ❌ _MediaArea 不再需要 VisibilityDetector，
        // 因为 IntelligentVideoPlayer 内部已经有了。
        // 对于图片，也不需要它。
        child: Stack(
          fit: StackFit.expand, // 确保 Stack 填满
          children: [
            child, // child (Hero -> IntelligentVideoPlayer/ImageRenderer)
            // ... 你的渐变、Badge、HoverText 逻辑保持不变 ...
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
                        colors: [ Colors.black.withOpacity(0.7), Colors.transparent ],
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
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
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
            child: Text(text, maxLines: 99, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 12)),
          ),
        );
      },
    );
  }
}

class ImageRenderer extends ConsumerWidget {
  final String imageUrl;
  final Alignment alignment;
  final BoxFit fit; // ✅ 新增
  const ImageRenderer({super.key, 
    required this.imageUrl,
    this.alignment = Alignment.center,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cacheManager = ref.watch(customCacheManagerProvider);
    return CachedNetworkImage(
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
    );
  }
}

// ✅ FIXED: 修正所有问题
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
          // --- “复制全部”按钮：使用 TextButton，但自定义样式 ---
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: items.join(', ')));
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('已复制到剪贴板')));
            },
            style: TextButton.styleFrom(
              // 2. 设置前景色（文本和图标颜色）
              // 使用一个比默认更柔和的颜色，或者使用强调色
              foregroundColor: theme.textTheme.bodyLarge?.color?.withOpacity(
                0.8,
              ),

              // 3. 设置按钮的形状，增加圆角
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),

              // 4. 增加内边距，让按钮看起来更大、更易于点击
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: const Text('复制全部'),
          ),

          const SizedBox(width: 8),

          // --- “关闭”按钮：使用 ElevatedButton，并应用主题色 ---
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              // 5. 设置背景色
              // 使用 colorScheme.primary，使其与应用的主色调保持一致
              backgroundColor: theme.colorScheme.primary,

              // 6. 设置前景色（文本颜色）
              // primary 颜色上的文本应该是亮色
              foregroundColor: theme.colorScheme.onPrimary,

              // 7. 设置阴影颜色和大小
              elevation: 2,
              shadowColor: Colors.black.withOpacity(0.2),

              // 8. 同样设置形状和内边距
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
