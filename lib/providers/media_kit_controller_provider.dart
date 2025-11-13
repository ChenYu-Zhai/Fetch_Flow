import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';

final mediaKitControllerProvider = FutureProvider.autoDispose.family<Player, String>((
  ref,
  videoUrl,
) async {
  // Debugging information: Print logs for player creation and media opening in development mode.
  // In a production environment, these logs are usually removed or disabled through build configurations.
  // 调试信息：在开发模式下打印播放器创建和媒体打开的日志。
  // 在生产环境中，这些日志通常会被移除或通过构建配置禁用。
  debugPrint('[MediaKitControllerProvider] Creating player for: $videoUrl');
  final player = Player();
  await player.open(Media(videoUrl));
  debugPrint('[MediaKitControllerProvider] Opened media: $videoUrl');
  ref.onDispose(() {
    debugPrint('[MediaKitControllerProvider] Disposing player for: $videoUrl');
    player.dispose();
  });
  return player;
});
