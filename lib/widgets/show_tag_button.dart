// lib/widgets/show_tag_button.dart

import 'package:featch_flow/widgets/unified_media_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/unified_post_model.dart';

final _tagLoadingProvider = StateProvider.family<bool, String>(
  (ref, postId) => false,
);

class ShowTagButton extends ConsumerWidget {
  final UnifiedPostModel post;
  const ShowTagButton({super.key, required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(_tagLoadingProvider(post.id));

    return SizedBox(
      width: 40,
      height: 40,
      child: isLoading
          ? const Padding(
              padding: EdgeInsets.all(8),
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : IconButton(
              icon: const Icon(Icons.local_offer_outlined, size: 20),
              tooltip: 'Show tags',
              onPressed: () => _handleTap(context, ref),
            ),
    );
  }

  Future<void> _handleTap(BuildContext context, WidgetRef ref) async {
    ref.read(_tagLoadingProvider(post.id).notifier).state = true;

    await Future.delayed(const Duration(milliseconds: 300));

    if (!context.mounted) return;
    ref.read(_tagLoadingProvider(post.id).notifier).state = false;

    showDialog(
      context: context,
      builder: (_) => TagDetailsDialog(post: post),
    );
  }
}
