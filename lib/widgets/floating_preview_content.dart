// lib/widgets/floating_preview_content.dart

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:featch_flow/models/unified_post_model.dart';
import 'package:featch_flow/providers/floating_preview_provider.dart';
import 'package:featch_flow/widgets/download_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:media_kit_video/media_kit_video.dart';

class FloatingPreviewContent extends ConsumerWidget {
  final UnifiedPostModel post;
  final VoidCallback onClose;

  const FloatingPreviewContent({super.key, required this.post, required this.onClose});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctrl = getCachedController(ref, post);
    final isVideo = post.mediaType == MediaType.video;

    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: min(600, MediaQuery.of(context).size.width * 0.9),
            maxHeight: min(800, MediaQuery.of(context).size.height * 0.9),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).cardColor,
          ),
          child: Stack(
            children: [
              // ✅ 媒体内容
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: isVideo && ctrl != null
                      ? Video(controller: ctrl)
                      : CachedNetworkImage(
                          imageUrl: post.fullImageUrl,
                          fit: BoxFit.contain,
                          alignment: Alignment.center,
                          placeholder: (_, __) => const SizedBox.shrink(),
                          errorWidget: (_, __, ___) => const Icon(Icons.broken_image),
                        ),
                ),
              ),
              
              // ✅ 关闭按钮
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, shadows: [Shadow(color: Colors.black, blurRadius: 2)]),
                  onPressed: onClose,
                ),
              ),
              
              // ✅ 底部操作栏
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.center,
                      colors: [Colors.black87, Colors.transparent],
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          post.tags.take(3).join(', '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 8),
                      DownloadButton(post: post),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}