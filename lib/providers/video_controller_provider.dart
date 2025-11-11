// lib/providers/video_controller_provider.dart

import 'package:featch_flow/config/network_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

final playerProvider = Provider.autoDispose.family<Player, String>((
  ref,
  videoUrl,
) {
  debugPrint('✅ [PlayerProvider] Creating instance for: $videoUrl');
  final player = Player();

  ref.onDispose(() {
    debugPrint('🗑️ [PlayerProvider] Disposing instance for: $videoUrl');
    try {
      player.dispose();
    } catch (e) {
      debugPrint(
        '❌ [PlayerProvider] Failed to dispose player for $videoUrl: $e',
      );
    }
  });

  return player;
});

final videoControllerProvider = Provider.autoDispose
    .family<VideoController, String>((ref, videoUrl) {
      final player = ref.watch(playerProvider(videoUrl));
      final controller = VideoController(player);
      debugPrint(
        '✅ [VideoControllerProvider] Created controller for: $videoUrl',
      );
      return controller;
    });
final videoLoaderProvider = FutureProvider.autoDispose.family<void, String>((
  ref,
  videoUrl,
) async {
  final player = ref.watch(playerProvider(videoUrl));

  debugPrint('⏳ [VideoLoaderProvider] Opening media for: $videoUrl');
  await player.open(
    Media(videoUrl, httpHeaders: kIsWeb ? null : nativeHttpHeaders),
    play: false,
  );
  debugPrint(
    '✅ [VideoLoaderProvider] Media opened successfully for: $videoUrl',
  );

  player.setVolume(0);
  player.setPlaylistMode(PlaylistMode.single);
  player.play();
});

final videoActivationProvider = StateProvider.autoDispose.family<bool, String>((ref, videoUrl) {
  // 默认情况下，视频是不激活的。
  return false;
});
