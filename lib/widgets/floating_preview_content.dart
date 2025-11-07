import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:featch_flow/models/unified_post_model.dart';
import 'package:featch_flow/providers/floating_preview_provider.dart';
import 'package:featch_flow/providers/video_controller_provider.dart';
import 'package:featch_flow/widgets/download_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:media_kit_video/media_kit_video.dart';

class FloatingPreviewContent extends ConsumerStatefulWidget {
  final UnifiedPostModel post;
  final VoidCallback onClose;
  const FloatingPreviewContent({super.key, required this.post, required this.onClose});

  @override
  ConsumerState<FloatingPreviewContent> createState() => _FloatingPreviewContentState();
}

class _FloatingPreviewContentState extends ConsumerState<FloatingPreviewContent> {
  /* 异步控制器 */
  VideoController? _controller;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  Future<void> _initController() async {
    if (widget.post.mediaType != MediaType.video) return; // 图片无需控制器
    try {
      // 用 ref.read 拿到 provider，然后 await 它
      final asyncCtrl = await ref.read(
        videoControllerProvider(
          VideoPlayerConfig(
            videoUrl: widget.post.fullImageUrl,
            autoplay: true,
            loop: true,
          ),
        ).future,
      );
      if (mounted) {
        setState(() {
          _controller = asyncCtrl;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    /* 弹窗销毁时让 provider 自己决定是否释放 */
    super.dispose();
  }

  /* --------------- UI --------------- */
  @override
  Widget build(BuildContext context) {
    final isVideo = widget.post.mediaType == MediaType.video;

    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: min(600, MediaQuery.of(context).size.width * 0.9),
            maxHeight: min(800, MediaQuery.of(context).size.height * 0.9),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).cardColor,
          ),
          child: Stack(
            children: [
              /* ① 媒体区域：统一处理 */
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildMedia(),
                ),
              ),

              /* ② 关闭按钮 */
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.close,
                      color: Colors.white,
                      shadows: [Shadow(color: Colors.black, blurRadius: 2)]),
                  onPressed: widget.onClose,
                ),
              ),

              /* ③ 底部操作栏 */
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.center,
                      colors: [Colors.black87, Colors.transparent],
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.post.tags.take(3).join(', '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 8),
                      DownloadButton(post: widget.post),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMedia() {
    /* 图片：直接渲染 */
    if (widget.post.mediaType != MediaType.video) {
      return CachedNetworkImage(
        imageUrl: widget.post.fullImageUrl,
        fit: BoxFit.contain,
        alignment: Alignment.center,
        placeholder: (_, __) => const SizedBox.shrink(),
        errorWidget: (_, __, ___) => const Icon(Icons.broken_image),
      );
    }

    /* 视频：三种状态 */
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null || _controller == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 36),
            const SizedBox(height: 8),
            Text('加载失败: $_error', style: const TextStyle(color: Colors.white)),
          ],
        ),
      );
    }

    return Video(controller: _controller!);
  }
}