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

  VideoPlayerConfig({
    required this.videoUrl,
    this.loop = true, // Loop by default.
    this.autoplay = true, // Do not autoplay by default.
  });

  // Important: When adding new properties, be sure to update the == and hashCode implementations.
  // This allows Riverpod to correctly determine if the parameters have changed between calls.
  // 重要：当增加新属性后，一定要更新 == 和 hashCode 的实现。
  // 这样 Riverpod 才能正确地判断两次调用的参数是否发生了变化。
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VideoPlayerConfig &&
          runtimeType == other.runtimeType &&
          videoUrl == other.videoUrl &&
          loop == other.loop &&
          autoplay == other.autoplay;

  @override
  int get hashCode => videoUrl.hashCode ^ loop.hashCode ^ autoplay.hashCode;
}

final videoControllerProvider = FutureProvider.autoDispose
    .family<VideoController, VideoPlayerConfig>((ref, config) async {
      debugPrint('[VideoControllerProvider] Creating player for: ${config.videoUrl}');
      final player = Player();
      final controller = VideoController(player);

      // The play command will be issued by the UI.
      // 播放的指令将由 UI 发出。
      player.open(
        Media(config.videoUrl, httpHeaders: kIsWeb ? null : nativeHttpHeaders),
        play: false,
      );
      debugPrint('[VideoControllerProvider] Opened media: ${config.videoUrl}');

      if (config.loop) {
        player.setPlaylistMode(PlaylistMode.single);
      } else {
        player.setPlaylistMode(PlaylistMode.none);
      }

      ref.onDispose(() {
        debugPrint('[VideoControllerProvider] Disposing player for: ${config.videoUrl}');
        _safeDisposePlayer(player, config.videoUrl);
      });

      return controller;
    });

/// A safe player disposal function that considers multithreading and lifecycle.
/// 一个安全的、考虑了多线程和生命周期的 Player 销毁函数。
void _safeDisposePlayer(Player player, String videoUrl) {
  final currentIsolateName = Isolate.current.debugName;

  if (!kIsWeb &&
      currentIsolateName != 'main' &&
      currentIsolateName?.isNotEmpty == true) {
    // If we find ourselves in a background isolate (name is not 'main'),
    // we do not directly call any code related to the Flutter engine,
    // because the main thread may no longer exist. We just print a log and give up.
    // 如果我们发现自己处在一个后台 Isolate 中 (名字不是 'main')，
    // 我们不直接调用任何与 Flutter 引擎相关的代码，
    // 因为此时主线程可能已经不存在了。我们只打印一条日志，然后放弃操作。
    debugPrint(
      '[VideoControllerProvider] Cannot dispose player from background isolate: $currentIsolateName for url: $videoUrl. Letting OS clean up.',
    );
    return;
  }

  // If we are sure we are on the main thread, or on the web platform,
  // continue to use the stable and safe SchedulerBinding scheme.
  // 如果我们确定在主线程上，或者在 Web 平台上，
  // 则继续使用之前稳定、安全的 SchedulerBinding 方案。
  try {
    if (SchedulerBinding.instance.lifecycleState != null) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        player.dispose();
        debugPrint('[VideoControllerProvider] Safely disposed video player on main thread: $videoUrl');
      });
    } else {
      // If ServicesBinding has been detached, it means the application is closing and nothing more needs to be done.
      // 如果 ServicesBinding 已经解绑，说明应用正在关闭，无需再做任何事。
      debugPrint('[VideoControllerProvider] ServicesBinding detached. Skipping disposal for: $videoUrl');
    }
  } catch (e) {
    // Catch any exceptions that may occur during the check.
    // 捕获任何在检查过程中可能发生的异常。
    debugPrint('[VideoControllerProvider] Error during safe disposal scheduling for $videoUrl: $e');
  }
}
