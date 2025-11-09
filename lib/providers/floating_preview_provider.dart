// lib/providers/floating_preview_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:featch_flow/models/unified_post_model.dart';
import 'package:flutter_riverpod/legacy.dart';
/// ✅ 核心Provider: 存储当前正在悬浮预览的 post。
/// 如果值为 null，表示预览窗口已关闭。
/// 这个 Provider 保持不变，它是正确的。
final floatingPostProvider = StateProvider<UnifiedPostModel?>((_) => null);

// ❌ 移除所有手动缓存逻辑。它们是内存泄漏的来源且已被 autoDispose 替代。
// final _videoCacheProvider = StateProvider<Map<String, VideoController>>((_) => {});
// VideoController? getCachedController(WidgetRef ref, UnifiedPostModel post) { ... }


/// ✅ 简化后的 "打开" 函数
/// 它的唯一职责就是更新状态，告诉UI“现在请展示这个post”。
/// UI层 (FloatingPreviewContent) 会负责获取和管理它自己需要的 VideoController。
void openFloatingPreview(WidgetRef ref, UnifiedPostModel post) {
  ref.read(floatingPostProvider.notifier).state = post;
}


/// ✅ 简化后的 "关闭" 函数
/// 它的唯一职责就是更新状态，告诉UI“关闭预览窗口”。
/// 当UI消失时，Riverpod的 autoDispose 会自动清理与该视频关联的Player和Controller。
void closeFloatingPreview(WidgetRef ref) {
  ref.read(floatingPostProvider.notifier).state = null;
}