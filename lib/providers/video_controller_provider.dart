// lib/providers/video_controller_provider.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

// ✅ Provider 1: 只负责创建和销毁 Player 实例。
// 这是一个同步操作，所以UI不会被阻塞。
// 我们使用 videoUrl 作为 family 的 key，确保每个视频都有自己独立的 Player。
final playerProvider = Provider.autoDispose.family<Player, String>((ref, videoUrl) {
  debugPrint('✅ [PlayerProvider] Creating instance for: $videoUrl');
  final player = Player();

  // 当 Provider 被销毁时（例如，因为所有监听它的 Widget 都被 unmount），
  // 自动调用 player.dispose() 来释放资源。
  ref.onDispose(() {
    debugPrint('🗑️ [PlayerProvider] Disposing instance for: $videoUrl');
    try {
      // 在后台安全地释放播放器
      player.dispose();
    } catch (e) {
      debugPrint('❌ [PlayerProvider] Failed to dispose player for $videoUrl: $e');
    }
  });

  return player;
});


// ✅ Provider 2: 只负责创建 VideoController。
// 它依赖于上面的 playerProvider，同样是瞬时完成的同步操作。
final videoControllerProvider = Provider.autoDispose.family<VideoController, String>((ref, videoUrl) {
  // 监听 playerProvider。当 Player 实例被创建时，这里会拿到它。
  final player = ref.watch(playerProvider(videoUrl));

  // 创建 VideoController 是一个轻量级的操作。
  final controller = VideoController(player);

  debugPrint('✅ [VideoControllerProvider] Created controller for: $videoUrl');
  
  return controller;
});