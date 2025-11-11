import 'package:featch_flow/config/network_config.dart';
import 'package:featch_flow/utils/image_renderer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../providers/video_controller_provider.dart';

class IntelligentVideoPlayer extends ConsumerStatefulWidget {
  final String videoUrl;
  final String previewImageUrl;
  final bool isPausedByDrag;

  const IntelligentVideoPlayer({
    Key? key,
    required this.videoUrl,
    required this.previewImageUrl,
    this.isPausedByDrag = false,
  }) : super(key: key);

  @override
  ConsumerState<IntelligentVideoPlayer> createState() =>
      _IntelligentVideoPlayerState();
}

class _IntelligentVideoPlayerState
    extends ConsumerState<IntelligentVideoPlayer> {
  VisibilityInfo? _lastVisibilityInfo;
  bool _isPlayerActive = false;

  @override
  void didUpdateWidget(IntelligentVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPausedByDrag != oldWidget.isPausedByDrag) {
      _updatePlayerState();
    }
  }

  void _updatePlayerState() {
    if (!mounted || _lastVisibilityInfo == null) return;

    final isVisible = _lastVisibilityInfo!.visibleFraction > 0.05;
    final shouldBeActive = isVisible && !widget.isPausedByDrag;

    if (shouldBeActive != _isPlayerActive) {
      setState(() {
        _isPlayerActive = shouldBeActive;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: ValueKey(widget.videoUrl),
      onVisibilityChanged: (info) {
        _lastVisibilityInfo = info;
        _updatePlayerState();
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
          const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          ),
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
