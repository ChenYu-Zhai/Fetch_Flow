// lib/widgets/intelligent_video_player.dart

import 'package:featch_flow/config/network_config.dart';

import 'package:featch_flow/widgets/unified_media_card.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
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
  ConsumerState<IntelligentVideoPlayer> createState() =>
      _IntelligentVideoPlayerState();
}

class _IntelligentVideoPlayerState
    extends ConsumerState<IntelligentVideoPlayer> {
  bool _isInitialized = false;
  bool _isLoading = true;
  bool _hasError = false;
  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> _initializePlayer(VideoController controller) async {
    if (_isInitialized || _isDisposed) return;
    _isInitialized = true;

    try {
      await controller.player.open(
        Media(widget.videoUrl, httpHeaders: kIsWeb ? null : nativeHttpHeaders),
        play: false,
      );

      if (_isDisposed) return;

      controller.player.setVolume(0);
      controller.player.setPlaylistMode(PlaylistMode.single);

      if (_isDisposed) return;

      if (mounted) {
        setState(() => _isLoading = false);
        controller.player.play();
      }
    } catch (e) {
      debugPrint('❌ Failed to initialize: $e');
      if (!_isDisposed && mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  void _handleVisibilityChanged(
    VisibilityInfo info,
    VideoController? controller,
  ) {
    if (_isDisposed) return;

    if (info.visibleFraction > 0.7 && !_isInitialized && controller != null) {
      _initializePlayer(controller);
    }

    if (info.visibleFraction < 0.1 && controller != null) {
      try {
        controller.player.pause();
      } catch (_) {} // Silently ignore disposed player errors
    }

    if (info.visibleFraction > 0.7 &&
        _isInitialized &&
        !_isLoading &&
        !_hasError &&
        controller != null) {
      try {
        controller.player.play();
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isDisposed) return const SizedBox();

    final controller = ref.watch(videoControllerProvider(widget.videoUrl));

    return VisibilityDetector(
      key: ValueKey(widget.videoUrl),
      onVisibilityChanged: (info) => _handleVisibilityChanged(info, controller),
      child: Container(
        color: Colors.black,
        child: _buildPlayerContent(controller),
      ),
    );
  }

  Widget _buildPlayerContent(VideoController? controller) {
    if (_hasError) {
      return const Center(
        child: Icon(Icons.error_outline, color: Colors.red, size: 48),
      );
    }

    // Show placeholder until fully initialized
    if (!_isInitialized || _isLoading || controller == null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          ImageRenderer(imageUrl: widget.previewImageUrl),
          if (_isInitialized)
            const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
        ],
      );
    }

    return Video(controller: controller, fit: BoxFit.contain);
  }
}
