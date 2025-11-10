// lib/widgets/fullscreen_preview_content.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:featch_flow/models/unified_post_model.dart';
import 'package:featch_flow/providers/video_controller_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class FullscreenPreviewContent extends ConsumerStatefulWidget {
  final UnifiedPostModel post;
  final VoidCallback onClose;

  const FullscreenPreviewContent({
    super.key,
    required this.post,
    required this.onClose,
  });

  @override
  ConsumerState<FullscreenPreviewContent> createState() =>
      _FullscreenPreviewContentState();
}

class _FullscreenPreviewContentState
    extends ConsumerState<FullscreenPreviewContent> {
  VideoController? _controller;
  bool _isLoadingVideo = false;
  String? _error;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()..requestFocus();

    if (widget.post.mediaType == MediaType.video) {
      setState(() => _isLoadingVideo = true);
      _initializePlayer();
    }
  }

  Future<void> _initializePlayer() async {
    try {
      final controller = await ref.read(
        videoControllerProvider(widget.post.fullImageUrl),
      );

      if (!mounted) return;

      setState(() {
        _controller = controller;
        _isLoadingVideo = false;
      });

      // 配置播放器
      controller.player.setVolume(100.0);
      controller.player.setPlaylistMode(PlaylistMode.single);
    } catch (e) {
      debugPrint('❌ 视频加载失败: $e');
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoadingVideo = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.player.setVolume(0.0);
    _focusNode.dispose();
    _controller = null; // 断开引用，由 Provider 管理释放
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shortcuts = <ShortcutActivator, VoidCallback>{
      const SingleActivator(LogicalKeyboardKey.escape): widget.onClose,
    };

    return CallbackShortcuts(
      bindings: shortcuts,
      child: FocusScope(
        autofocus: true,
          child: Stack(
            children: [
              Positioned.fill(child: _buildMedia()),
              Positioned(
                top: 40,
                right: 16,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: widget.onClose,
                ),
              ),
            ],
          ),
      ),
    );
  }

  Widget _buildMedia() {
    if (widget.post.mediaType == MediaType.video) {
      if (_isLoadingVideo) {
        return const Center(child: CircularProgressIndicator());
      }

      if (_error != null) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 48),
              const SizedBox(height: 16),
              Text(
                '视频加载失败: $_error',
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      if (_controller == null) return const SizedBox.shrink();

      return Video(controller: _controller!, fit: BoxFit.contain);
    }

    // 图片
    return InteractiveViewer(
      panEnabled: true,
      scaleFactor: 800,
      minScale: 0.5,
      maxScale: 12.0,
      child: CachedNetworkImage(
        imageUrl: widget.post.fullImageUrl,
        fit: BoxFit.contain,
        placeholder: (_, __) =>
            const Center(child: CircularProgressIndicator()),
        errorWidget: (_, __, ___) =>
            const Icon(Icons.broken_image, color: Colors.white),
      ),
    );
  }
}
