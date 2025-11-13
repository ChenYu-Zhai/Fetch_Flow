// lib/providers/floating_preview_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:featch_flow/models/unified_post_model.dart';
import 'package:flutter_riverpod/legacy.dart';

final floatingPostProvider = StateProvider<UnifiedPostModel?>((_) => null);

void openFloatingPreview(WidgetRef ref, UnifiedPostModel post) {
  ref.read(floatingPostProvider.notifier).state = post;
}

void closeFloatingPreview(WidgetRef ref) {
  ref.read(floatingPostProvider.notifier).state = null;
}
