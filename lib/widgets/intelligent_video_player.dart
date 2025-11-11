// lib/widgets/intelligent_video_player.dart

import 'package:featch_flow/utils/image_renderer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../providers/video_controller_provider.dart';

class IntelligentVideoPlayer extends ConsumerStatefulWidget {
  final String videoUrl;
  final String previewImageUrl;
  

  const IntelligentVideoPlayer({
    Key? key,
    required this.videoUrl,
    required this.previewImageUrl,
  }) : super(key: key);

  @override
  ConsumerState<IntelligentVideoPlayer> createState() => _IntelligentVideoPlayerState();
}

class _IntelligentVideoPlayerState extends ConsumerState<IntelligentVideoPlayer> {
  // 唯一需要的状态：是否应该激活播放器？
  bool _isPlayerActive = false;

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: ValueKey(widget.videoUrl),
      onVisibilityChanged: (info) {
        final isVisible = info.visibleFraction >= 0.05;
        
        // 当可见性状态改变时，更新 _isPlayerActive
        if (mounted && isVisible != _isPlayerActive) {
          setState(() {
            _isPlayerActive = isVisible;
          });
        }

        // 无论如何，当不可见时，都尝试暂停播放以节省资源
        if (info.visibleFraction <= 0.04) {
          // 使用 read，因为它只是执行一个动作
          final player = ref.read(playerProvider(widget.videoUrl));
          player.pause();
        }
      },
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (!_isPlayerActive) {
      return ImageRenderer(imageUrl: widget.previewImageUrl);
    }

    final videoLoaderAsync = ref.watch(videoLoaderProvider(widget.videoUrl));

    return videoLoaderAsync.when(
      loading: () => Stack(
        fit: StackFit.expand,
        children: [
          ImageRenderer(imageUrl: widget.previewImageUrl),
          const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
        ],
      ),
      error: (err, stack) => const Center(
        child: Icon(Icons.error_outline, color: Colors.red, size: 48),
      ),
      data: (_) {
        final controller = ref.watch(videoControllerProvider(widget.videoUrl));
        return Video(controller: controller, fit: BoxFit.contain);
      },
    );
  }
}