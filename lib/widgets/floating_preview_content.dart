// lib/widgets/fullscreen_preview_content.dart

import 'dart:math';
import 'package:featch_flow/config/network_config.dart';
import 'package:featch_flow/models/unified_post_model.dart';
import 'package:featch_flow/providers/video_controller_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:photo_view/photo_view.dart';

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
  bool _isLoadingVideo = true;
  bool _isDisposed = false;
  String? _error;
  late VideoController controller;
  @override
  void initState() {
    super.initState();
    if (widget.post.mediaType == MediaType.video) {
      setState(() {
        _isLoadingVideo = true;
      });
    }
  }

  Future<void> _initializePlayer() async {
    if (_isDisposed) {
      controller.player.setVolume(0.0);
      return;
    }

    try {
      controller = ref.watch(videoControllerProvider(widget.post.fullImageUrl));
      if (_isDisposed) return;

      try {
        controller.player.setVolume(100.0);
        controller.player.setPlaylistMode(PlaylistMode.single);
      } catch (e) {
        debugPrint('⚠️ 配置播放器失败: $e');
      }

      if (_isDisposed) return;

      if (mounted) {
        setState(() => _isLoadingVideo = false);
      }
    } catch (e) {
      debugPrint('❌ 视频加载失败: ${widget.post.fullImageUrl}, error: $e');
      if (!_isDisposed && mounted) {
        setState(() {
          _error = e.toString();
          _isLoadingVideo = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    controller.player.setVolume(0.0);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isDisposed) return const SizedBox();

    // 定义快捷键映射表
    final shortcuts = <ShortcutActivator, VoidCallback>{
      const SingleActivator(LogicalKeyboardKey.escape): widget.onClose,
    };

    return CallbackShortcuts(
      bindings: shortcuts,
      child: FocusScope(
        autofocus: true,
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
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
      ),
    );
  }

  Widget _buildMedia() {
    final mediaType = widget.post.mediaType;

    Widget content;
    if (mediaType == MediaType.video) {
      content = Video(controller: controller, fit: BoxFit.contain);
    } else {
      content = CachedNetworkImage(
        imageUrl: widget.post.fullImageUrl,
        fit: BoxFit.contain,
        placeholder: (_, __) =>
            const Center(child: CircularProgressIndicator()),
        errorWidget: (_, __, ___) => const Icon(Icons.broken_image),
      );
    }

    if (mediaType != MediaType.video) {
      return InteractiveViewer(
        panEnabled: true,
        scaleFactor: 800,
        minScale: 0.5,
        maxScale: 12.0,
        child: content,
      );
    }

    return content;
  }
}
