// lib/providers/floating_preview_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:featch_flow/models/unified_post_model.dart';
import 'package:featch_flow/providers/video_controller_provider.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:media_kit_video/media_kit_video.dart';

/// 当前正在悬浮预览的 post（null = 关闭）
final floatingPostProvider = StateProvider<UnifiedPostModel?>((_) => null);

/// 缓存的视频控制器（key = post.id）
final _videoCacheProvider = StateProvider<Map<String, VideoController>>((_) => {});

/// 获取或创建缓存的控制器
VideoController? getCachedController(WidgetRef ref, UnifiedPostModel post) {
  final cache = ref.watch(_videoCacheProvider);
  return cache[post.id];
}

/// 打开悬浮预览
void openFloatingPreview(WidgetRef ref, UnifiedPostModel post) {
  ref.read(floatingPostProvider.notifier).state = post;
  
  // 视频类型：提前创建控制器并缓存
  if (post.mediaType == MediaType.video) {
    final cfg = VideoPlayerConfig(
      videoUrl: post.fullImageUrl,
      autoplay: true, // 立即播放
      loop: true,
    );
    final provider = videoControllerProvider(cfg);
    final asyncCtrl = ref.read(provider);
    
    asyncCtrl.when(
      data: (ctrl) {
        ref.read(_videoCacheProvider.notifier).update((map) {
          map[post.id] = ctrl;
          return map;
        });
      },
      loading: () {},
      error: (_, __) {},
    );
  }
}

/// 关闭悬浮预览
void closeFloatingPreview(WidgetRef ref) {
  final post = ref.read(floatingPostProvider);
  if (post == null) return;
  
  // 仅隐藏，不销毁控制器
  ref.read(floatingPostProvider.notifier).state = null;
}