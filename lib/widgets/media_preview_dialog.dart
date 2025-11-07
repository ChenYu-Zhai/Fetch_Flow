// lib/widgets/media_preview_dialog.dart

import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:featch_flow/models/unified_post_model.dart';
import 'package:featch_flow/providers/video_controller_provider.dart';
import 'package:featch_flow/services/download_service.dart';
import 'package:featch_flow/widgets/download_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:photo_view/photo_view.dart';

class MediaPreviewDialog extends ConsumerWidget {
  final UnifiedPostModel post;

  const MediaPreviewDialog({super.key, required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('[MediaPreviewDialog] Building for post: ${post.id}');
    return GestureDetector(
      onTap: () {
        debugPrint('[MediaPreviewDialog] Closing dialog.');
        Navigator.of(context).pop();
      },
      child: Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Media content display area.
            // 媒体内容展示区。
            Center(
              child: Hero(
                tag: post.id,
                flightShuttleBuilder: (
                  flightContext,
                  animation,
                  flightDirection,
                  fromHeroContext,
                  toHeroContext,
                ) {
                  final Hero toHero = toHeroContext.widget as Hero;
                  return toHero.child;
                },
                // Important: Wrap another GestureDetector inside Hero.
                // This prevents click events on the image itself from passing through to the underlying GestureDetector and closing the dialog.
                // --- 重要：在 Hero 内再包裹一个 GestureDetector ---
                //    防止点击图片本身时，事件穿透到底层 GestureDetector 导致关闭。
                child: GestureDetector(
                  onTap: () {}, // An empty onTap consumes the click event.
                  child: _buildFullMedia(context, ref, post),
                ),
              ),
            ),

            // Top action bar (close button).
            // 顶部操作栏 (关闭按钮)。
            Positioned(
              top: 16,
              left: 16,
              child: SafeArea(
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () {
                    debugPrint('[MediaPreviewDialog] Close button pressed.');
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),

            // Bottom action bar (download, copy buttons).
            // 底部操作栏 (下载、复制按钮)。
            Positioned(
              bottom: 30,
              right: 16,
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Copy Prompt/Tags button.
                    // 复制 Prompt/Tags 按钮。
                    FloatingActionButton(
                      heroTag: 'copy_btn',
                      mini: true,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      foregroundColor: Colors.white,
                      onPressed: () {
                        debugPrint('[MediaPreviewDialog] Copy button pressed.');
                        _copyTags(context);
                      },
                      child: const Icon(Icons.copy),
                    ),
                    const SizedBox(height: 16),
                    // Download button.
                    // 下载按钮。
                    DownloadButton(post: post),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullMedia(
    BuildContext context,
    WidgetRef ref,
    UnifiedPostModel post,
  ) {
    switch (post.mediaType) {
      case MediaType.image:
      case MediaType.gif:
        // Use PhotoView directly and remove heroAttributes.
        // --- 【核心修复】直接使用 PhotoView，并且移除 heroAttributes ---
        debugPrint('[MediaPreviewDialog] Loading image: ${post.fullImageUrl}');
        return PhotoView(
          imageProvider: CachedNetworkImageProvider(post.fullImageUrl),
          // Remove heroAttributes: PhotoViewHeroAttributes(tag: post.id),

          // Other configurations remain unchanged, these are key to enabling desktop interaction.
          // 其他配置保持不变，这些是开启桌面交互的关键。
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 3.0,
          backgroundDecoration: const BoxDecoration(color: Colors.transparent),

          loadingBuilder: (context, event) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          },
        );
      case MediaType.video:
        debugPrint(
          '[MediaPreviewDialog] Building video player for: ${post.fullImageUrl}',
        );
        return MediaKitVideoPlayer(videoUrl: post.fullImageUrl);
    }
  }

  void _copyTags(BuildContext context) async {
    // Prioritize copying Civitai's Prompt; if not available, copy Rule34's Tags.
    // 优先尝试复制 Civitai 的 Prompt，如果没有则复制 Rule34 的 Tags。
    String textToCopy =
        post.originalData!['meta']?['prompt'] ?? post.tags!.join(' ');

    if (textToCopy.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: textToCopy));
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Copied to clipboard!')));
      }
      debugPrint('[MediaPreviewDialog] Copied text: $textToCopy');
    }
  }
}

class MediaKitVideoPlayer extends ConsumerStatefulWidget {
  final String videoUrl;

  const MediaKitVideoPlayer({super.key, required this.videoUrl});

  @override
  ConsumerState<MediaKitVideoPlayer> createState() =>
      _MediaKitVideoPlayerState();
}

class _MediaKitVideoPlayerState extends ConsumerState<MediaKitVideoPlayer> {
  // Define a StreamSubscription to cancel listening when the Widget is disposed.
  // 定义一个 StreamSubscription，以便在 Widget 销毁时能够取消监听。
  StreamSubscription<bool>? _bufferingSubscription;

  /// ✅ 关键修复：保存播放器实例以便在 dispose 中释放
  Player? _player;

  @override
  void dispose() {
    // ✅ 核心修复：强制暂停并释放播放器
    debugPrint('[MediaKitVideoPlayer] Disposing and releasing player...');
    
    try {
      // 1. 先暂停播放
      _player?.pause();
      // 2. 等待一小段时间确保音频停止
      Future.delayed(const Duration(milliseconds: 50), () {
        // 3. 释放播放器资源
        _player?.dispose();
      });
    } catch (e) {
      debugPrint('[MediaKitVideoPlayer] Error during dispose: $e');
    }

    // 4. 取消订阅
    _bufferingSubscription?.cancel();
    
    super.dispose();
    debugPrint('[MediaKitVideoPlayer] Fully disposed.');
  }

  @override
  Widget build(BuildContext context) {
    final config = VideoPlayerConfig(
      videoUrl: widget.videoUrl,
      autoplay: true,
      loop: true,
    );

    final providerInstance = videoControllerProvider(config);

    ref.listen<AsyncValue<VideoController>>(providerInstance, (previous, next) {
      if (next is AsyncData) {
        final controller = next.value;
        // ✅ 保存播放器实例
        _player = controller?.player;
        
        if (controller == null || _player == null) return;

        debugPrint(
          "[MediaKitVideoPlayer] Controller ready, setting up listeners.",
        );

        // Listen for playback state changes.
        // 监听是否在播放。
        _player!.stream.playing.listen((playing) {
          debugPrint(
            "[MediaKitVideoPlayer] Playback state changed: isPlaying = $playing",
          );
        });

        // Listen for playback completion.
        // 监听是否播放完毕。
        _player!.stream.completed.listen((completed) {
          debugPrint(
            "[MediaKitVideoPlayer] Playback completed state: isCompleted = $completed",
          );
        });

        // Listen for errors.
        // 监听错误。
        _player!.stream.error.listen((error) {
          debugPrint("[MediaKitVideoPlayer] Player error: $error");
        });

        // The previous buffering listening logic remains unchanged.
        // 之前的缓冲监听逻辑保持不变。
        if (config.autoplay) {
          _bufferingSubscription?.cancel();
          _bufferingSubscription = _player!.stream.buffering.listen((isBuffering) {
            debugPrint(
              "[MediaKitVideoPlayer] Buffering state changed: isBuffering = $isBuffering",
            );
            if (!isBuffering) {
              debugPrint(
                "[MediaKitVideoPlayer] Buffering finished, attempting to play...",
              );
              _player!.setVolume(0.0);
              _player!.play();
              _bufferingSubscription?.cancel();
            }
          });
        }
      } else if (next is AsyncError) {
        debugPrint("[MediaKitVideoPlayer] Controller error: ${next.error}");
      }
    });

    final videoController = ref.watch(providerInstance);

    return videoController.when(
      data: (controller) {
        debugPrint('[MediaKitVideoPlayer] Video controller is ready.');
        return Video(controller: controller);
      },
      loading: () {
        debugPrint('[MediaKitVideoPlayer] Loading video controller...');
        return const Center(child: CircularProgressIndicator());
      },
      error: (error, stack) {
        debugPrint('[MediaKitVideoPlayer] Error: $error');
        return Center(child: Text('Error: $error'));
      },
    );
  }
}