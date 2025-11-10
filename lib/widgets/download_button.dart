// lib/widgets/download_button.dart

import 'package:featch_flow/services/download_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/unified_post_model.dart';

class DownloadButton extends ConsumerWidget {
  final UnifiedPostModel post;

  const DownloadButton({super.key, required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to the download status of a specific post.
    // 监听特定帖子的下载状态。
    final downloadInfo = ref.watch(downloadNotifierProvider)[post.id] ?? const DownloadInfo();
    
    // Build different UI based on the status.
    // 根据状态构建不同的 UI。
    return SizedBox(
      width: 40,
      height: 40,
      child: _buildButtonContent(context, ref, downloadInfo),
    );
  }

  Widget _buildButtonContent(BuildContext context, WidgetRef ref, DownloadInfo info) {
    switch (info.status) {
      case DownloadStatus.notDownloaded:
        return IconButton(
          icon: const Icon(Icons.download_for_offline_outlined, size: 20),
          onPressed: () => ref.read(downloadNotifierProvider.notifier).downloadPost(post),
          tooltip: 'Download',
        );

      case DownloadStatus.fetching:
        return const Padding(
          padding: EdgeInsets.all(8.0),
          child: CircularProgressIndicator(strokeWidth: 2),
        );

      case DownloadStatus.downloading:
        return Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(
              value: info.progress,
              strokeWidth: 2,
              backgroundColor: Colors.grey.shade700,
            ),
            Text(
              '${(info.progress * 100).toInt()}%',
              style: const TextStyle(fontSize: 10, color: Colors.white),
            ),
          ],
        );

      case DownloadStatus.downloaded:
        return const Icon(Icons.check_circle, color: Colors.green, size: 24);
    }
  }


}