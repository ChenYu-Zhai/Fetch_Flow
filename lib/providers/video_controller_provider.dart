// lib/providers/video_controller_provider.dart

import 'dart:isolate';
import 'package:featch_flow/config/network_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class VideoPlayerConfig {
  final String videoUrl;
  final bool loop;
  final bool autoplay;

  const VideoPlayerConfig({
    required this.videoUrl,
    this.loop = true,
    this.autoplay = false, // ✅ 关键修复：默认不自动播放，由UI控制
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VideoPlayerConfig &&
          runtimeType == other.runtimeType &&
          videoUrl == other.videoUrl &&
          loop == other.loop &&
          autoplay == other.autoplay;

  @override
  int get hashCode => Object.hash(videoUrl, loop, autoplay);
}

/// 修改为普通 Provider，移除 autoDispose
/// 由 MediaPreloadService 手动管理生命周期
final videoControllerProvider = FutureProvider.family<VideoController, VideoPlayerConfig>(
  (ref, config) async {
    debugPrint('🎬 [VideoControllerProvider] Creating player: ${config.videoUrl}');
    
    final stopwatch = Stopwatch()..start();
    final player = Player();
    final controller = VideoController(player);

    try {
      // 配置播放器参数
      player.setVolume(0); // 预加载时静音
      player.setRate(1.0);

      // 打开媒体资源（不自动播放）
      await player.open(
        Media(config.videoUrl, httpHeaders: kIsWeb ? null : nativeHttpHeaders),
        play: config.autoplay, // ✅ 使用配置参数
      );
      
      if (config.loop) {
        player.setPlaylistMode(PlaylistMode.single);
      } else {
        player.setPlaylistMode(PlaylistMode.none);
      }

      stopwatch.stop();
      debugPrint('✅ [VideoControllerProvider] Initialized in ${stopwatch.elapsedMilliseconds}ms: ${config.videoUrl}');

      // ✅ 关键修复：手动控制生命周期，不依赖 autoDispose
      ref.onDispose(() {
        debugPrint('🗑️ [VideoControllerProvider] Scheduling dispose: ${config.videoUrl}');
        _safeDisposePlayer(player, config.videoUrl);
      });

      return controller;
    } catch (e) {
      debugPrint('❌ [VideoControllerProvider] Failed to create: ${config.videoUrl}, error: $e');
      await player.dispose();
      rethrow;
    }
  },
);

/// ✅ 增强的 dispose 逻辑，添加超时保护
void _safeDisposePlayer(Player player, String videoUrl) async {
  final currentIsolate = Isolate.current.debugName;

  // Web 平台直接 dispose
  if (kIsWeb) {
    try {
      await player.dispose();
      debugPrint('🧹 [VideoControllerProvider] Disposed (web): $videoUrl');
    } catch (e) {
      debugPrint('⚠️ [VideoControllerProvider] Dispose failed (web): $videoUrl, $e');
    }
    return;
  }

  // 非主 Isolate 跳过（理论上不应发生，因为我们在主线程创建）
  if (currentIsolate != 'main') {
    debugPrint('⚠️ [VideoControllerProvider] Non-main isolate dispose skipped: $videoUrl');
    return;
  }

  // 主线程安全 dispose（带超时保护）
  try {
    if (SchedulerBinding.instance.lifecycleState == null) {
      debugPrint('⚠️ [VideoControllerProvider] App closing, skip dispose: $videoUrl');
      return;
    }

    // ✅ 添加超时，防止 dispose 挂起
    await SchedulerBinding.instance.endOfFrame.timeout(
      const Duration(seconds: 2),
      onTimeout: () => debugPrint('⏱️ [VideoControllerProvider] Dispose timeout: $videoUrl'),
    );

    if (SchedulerBinding.instance.lifecycleState != null) {
      SchedulerBinding.instance.addPostFrameCallback((_) async {
        try {
          await player.dispose().timeout(const Duration(seconds: 3));
          debugPrint('✅ [VideoControllerProvider] Safely disposed: $videoUrl');
        } catch (e) {
          debugPrint('❌ [VideoControllerProvider] Dispose error: $videoUrl, $e');
        }
      });
    }
  } catch (e) {
    debugPrint('❌ [VideoControllerProvider] Scheduling error: $videoUrl, $e');
  }
}