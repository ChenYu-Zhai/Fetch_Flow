import 'package:cached_network_image/cached_network_image.dart';
import 'package:featch_flow/models/unified_post_model.dart';
import 'package:featch_flow/providers/video_controller_provider.dart';
import 'package:featch_flow/widgets/download_button.dart';
import 'package:featch_flow/widgets/media_preview_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:flutter/services.dart';
import 'package:featch_flow/services/download_service.dart';
import 'package:featch_flow/providers/cache_manager_provider.dart';

import 'package:visibility_detector/visibility_detector.dart';

class UnifiedMediaCard extends ConsumerStatefulWidget {
  final UnifiedPostModel post;
  const UnifiedMediaCard({super.key, required this.post});

  @override
  ConsumerState<UnifiedMediaCard> createState() => _UnifiedMediaCardState();
}

// 【改动 2】将 State -> ConsumerState<UnifiedMediaCard>
class _UnifiedMediaCardState extends ConsumerState<UnifiedMediaCard> {
  bool _isHovering = false;
  // 【新】增加 state 变量来管理可见性和视频控制器
  bool _isVisible = false;
  VideoController? _videoController;

  String get _infoText {
    if (widget.post.source == 'civitai') {
      return widget.post.originalData['meta']?['prompt'] ??
          widget.post.tags.take(5).join(', ');
    } else {
      return widget.post.tags.take(5).join(', ');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.all(6.0),
      elevation: 4.0,
      color: Theme.of(context).canvasColor,
      child: Column(
        children: [
          MouseRegion(
            onEnter: (_) {
              setState(() => _isHovering = true);
              debugPrint(
                '[UnifiedMediaCard] Hovering on post: ${widget.post.id}',
              );
            },
            onExit: (_) {
              setState(() => _isHovering = false);
              debugPrint(
                '[UnifiedMediaCard] Not hovering on post: ${widget.post.id}',
              );
            },
            child: InkWell(
              onTap: () {
                debugPrint(
                  '[UnifiedMediaCard] Tapped on post: ${widget.post.id}',
                );
                _showPreview(context);
              },
              child: VisibilityDetector(
                key: Key(widget.post.id),
                onVisibilityChanged: (visibilityInfo) {
                  final isVisible = visibilityInfo.visibleFraction > 0.5;
                  if (_isVisible != isVisible) {
                    if (!mounted) {
                      return; // 如果 Widget 已经被销毁，则直接返回，不做任何操作
                    }
                    setState(() {
                      _isVisible = isVisible;
                    });
                    debugPrint(
                      '[UnifiedMediaCard] Post ${widget.post.id} visibility changed: $isVisible',
                    );
                    if (isVisible) {
                      _videoController?.player.play();
                      debugPrint(
                        '[UnifiedMediaCard] Playing video for post: ${widget.post.id}',
                      );
                    } else {
                      _videoController?.player.pause();
                      debugPrint(
                        '[UnifiedMediaCard] Pausing video for post: ${widget.post.id}',
                      );
                    }
                  }
                },
                child: Stack(
                  children: [
                    Hero(
                      tag: widget.post.id,
                      child: _buildMediaWithAspectRatio(),
                    ),
                    Positioned.fill(child: _buildAnimatedGradientMask()),
                    _buildAnimatedInfoText(),
                  ],
                ),
              ),
            ),
          ),
          _CardFooter(post: widget.post),
        ],
      ),
    );
  }

  Widget _buildMediaWithAspectRatio() {
    final post = widget.post;
    final aspectRatio = post.width > 0 && post.height > 0
        ? post.width / post.height
        : 1.0;
    const maxAspectRatio = 3.0;
    final isTooLong = post.height > post.width * maxAspectRatio;

    return AspectRatio(
      aspectRatio: isTooLong
          ? (post.width / (post.width * maxAspectRatio))
          : aspectRatio,
      child: ConstrainedBox(
        constraints: const BoxConstraints.expand(),
        child: ClipRect(child: _buildMediaContent(isCropped: isTooLong)),
      ),
    );
  }

  Widget _buildMediaContent({bool isCropped = false}) {
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
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _videoController = controller;
              if (_isVisible) {
                _videoController?.player.setVolume(0.0); // 预览视频静音
                _videoController?.player.play();
              }
            }
          });
          return Video(controller: controller);
        },
        loading: () => _ImageRenderer(
          imageUrl: widget.post.previewImageUrl,
          alignment: isCropped ? Alignment.topCenter : Alignment.center,
        ),
        error: (error, stack) {
          debugPrint(
            '[UnifiedMediaCard] Error loading video for post ${widget.post.id}: $error',
          );
          return const Center(child: Icon(Icons.error));
        },
      );
    }

    // 对于图片或GIF，行为保持不变
    return _ImageRenderer(
      imageUrl: widget.post.previewImageUrl,
      alignment: isCropped ? Alignment.topCenter : Alignment.center,
    );
  }

  Widget _buildAnimatedGradientMask() {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: _isHovering ? 1.0 : 0.0,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.transparent,
              Color.fromARGB(139, 0, 0, 0),
            ],
            stops: [0.0, 0.8, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedInfoText() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      bottom: _isHovering ? 16.0 : -60.0,
      left: 16.0,
      right: 16.0,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: _isHovering ? 1.0 : 0.0,
        child: Text(
          _infoText,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            shadows: [Shadow(blurRadius: 2.0, color: Colors.black)],
          ),
        ),
      ),
    );
  }

  void _showPreview(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black.withOpacity(0.8),
        pageBuilder: (context, _, __) {
          return MediaPreviewDialog(post: widget.post);
        },
        transitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }
}

class _MediaRenderer extends ConsumerWidget {
  final UnifiedPostModel post;
  final bool isHovering;

  const _MediaRenderer({required this.post, required this.isHovering});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aspectRatio = post.width > 0 && post.height > 0
        ? post.width / post.height
        : 1.0;

    const maxAspectRatio = 3.0;
    final isTooLong = post.height > post.width * maxAspectRatio;

    return AspectRatio(
      aspectRatio: isTooLong
          ? (post.width / (post.width * maxAspectRatio))
          : aspectRatio,
      child: ConstrainedBox(
        constraints: const BoxConstraints.expand(),
        child: ClipRect(
          child: _buildMediaContent(isCropped: isTooLong, ref: ref),
        ),
      ),
    );
  }

  Widget _buildMediaContent({bool isCropped = false, required WidgetRef ref}) {
    if (post.mediaType == MediaType.video && isHovering) {
      final videoController = ref.watch(
        videoControllerProvider(
          VideoPlayerConfig(
            videoUrl: post.fullImageUrl,
            autoplay: true,
            loop: true,
          ),
        ),
      );

      return videoController.when(
        data: (controller) => Video(controller: controller),
        loading: () => _ImageRenderer(
          imageUrl: post.previewImageUrl,
          alignment: isCropped ? Alignment.topCenter : Alignment.center,
        ),
        error: (error, stack) => const Center(child: Icon(Icons.error)),
      );
    }

    return _ImageRenderer(
      imageUrl: post.previewImageUrl,
      alignment: isCropped ? Alignment.topCenter : Alignment.center,
    );
  }
}

class _ImageRenderer extends ConsumerWidget {
  final String imageUrl;
  final Alignment alignment;

  const _ImageRenderer({
    required this.imageUrl,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cacheManager = ref.watch(customCacheManagerProvider);
    return CachedNetworkImage(
      cacheManager: cacheManager,
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      alignment: alignment,
      placeholder: (context, url) => Container(color: Colors.grey.shade300),
      errorWidget: (context, url, error) {
        debugPrint(
          '[UnifiedMediaCard] Error loading image: $url, error: $error',
        );
        return Container(
          color: Colors.grey.shade300,
          child: const Icon(Icons.broken_image, color: Colors.grey),
        );
      },
    );
  }
}

class _CardFooter extends ConsumerWidget {
  final UnifiedPostModel post;
  const _CardFooter({required this.post});

  Future<void> _copyInfo(BuildContext context) async {
    try {
      String textToCopy = _getTextToCopy();
      if (textToCopy.isNotEmpty) {
        await Clipboard.setData(ClipboardData(text: textToCopy));
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Copied to clipboard!')));
        }
        debugPrint('[UnifiedMediaCard] Copied info for post: ${post.id}');
      }
    } catch (e) {
      debugPrint('[UnifiedMediaCard] Failed to copy to clipboard: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to copy.')));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 4, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Wrap(
              spacing: 4.0,
              runSpacing: 2.0,
              children: post.tags.take(3).map((tag) {
                return Chip(
                  label: Text(tag, style: const TextStyle(fontSize: 10)),
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                );
              }).toList(),
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.copy_all_outlined, size: 20),
                onPressed: () => _copyInfo(context),
                tooltip: 'Copy Info',
              ),
              DownloadButton(post: post),
            ],
          ),
        ],
      ),
    );
  }

  String _getTextToCopy() {
    if (post.source == 'civitai') {
      return post.originalData['meta']?['prompt'] ?? post.tags.join(', ');
    } else {
      return post.tags.join(', ');
    }
  }
}
