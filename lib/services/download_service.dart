// lib/services/download_service.dart

import 'package:featch_flow/models/civitai_image_model.dart';
import 'package:featch_flow/providers/settings_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/unified_post_model.dart';
import '../utils/downloader.dart';
import 'package:featch_flow/utils/path_helper.dart';

enum DownloadStatus { notDownloaded, fetching, downloading, downloaded }

@immutable
class DownloadInfo {
  final DownloadStatus status;
  final double progress;

  const DownloadInfo({
    this.status = DownloadStatus.notDownloaded,
    this.progress = 0.0,
  });
}

class DownloadNotifier extends StateNotifier<Map<String, DownloadInfo>> {
  final Dio _dio = Dio();
  final Downloader downloader;
  DownloadNotifier(this.downloader) : super({});

  Future<void> downloadPost(UnifiedPostModel post) async {
    if (state[post.id]?.status == DownloadStatus.downloading ||
        state[post.id]?.status == DownloadStatus.downloaded) {
      return;
    }
    _updateStatus(post.id, DownloadStatus.fetching);

    try {
      final baseFileName = _createBaseFileName(post);
      final fileExtension = _getFileExtension(post);
      final mediaFileName = '$baseFileName.$fileExtension';

      if (kIsWeb) {
        await downloader.downloadMedia(post.fullImageUrl, mediaFileName);
      } else {
        final saveDirectoryPath = await getDownloadPath();
        if (saveDirectoryPath == null) {
          throw Exception(
            "Could not determine download path on this platform.",
          );
        }
        final savePath = '$saveDirectoryPath/$mediaFileName';

        await _dio.download(
          post.fullImageUrl,
          savePath,
          onReceiveProgress: (received, total) {
            if (total != -1) {
              final progress = received / total;
              _updateStatus(
                post.id,
                DownloadStatus.downloading,
                progress: progress,
              );
            }
          },
        );
      }

      final textContent = _getTextToCopy(post);
      if (textContent.isNotEmpty) {
        await downloader.downloadText(textContent, baseFileName);
      }

      _updateStatus(post.id, DownloadStatus.downloaded);
    } catch (e) {
      print('Download failed for ${post.id}: $e');
      _updateStatus(post.id, DownloadStatus.notDownloaded);
    }
  }

  void _updateStatus(
    String postId,
    DownloadStatus status, {
    double progress = 0.0,
  }) {
    state = {
      ...state,
      postId: DownloadInfo(status: status, progress: progress),
    };
  }

  Future<String> _getMediaSavePath(String fileName) async {
    return "path/to/downloads/$fileName";
  }

  String _createBaseFileName(UnifiedPostModel post) => post.id;
  String _getFileExtension(UnifiedPostModel post) {
    try {
      final uri = Uri.parse(post.fullImageUrl);
      final path = uri.path;
      final lastDotIndex = path.lastIndexOf('.');
      final lastSlashIndex = path.lastIndexOf('/');

      if (lastDotIndex > lastSlashIndex && lastDotIndex < path.length - 1) {
        return path.substring(lastDotIndex + 1);
      }
    } catch (_) {}

    switch (post.mediaType) {
      case MediaType.video:
        return 'mp4';
      case MediaType.gif:
        return 'gif';
      default:
        return 'jpg';
    }
  }

  String _getTextToCopy(UnifiedPostModel post) {
    if (post.source == 'civitai' && post.originalData.isNotEmpty) {
      try {
        final civitaiModel = CivitaiImageModel.fromJson(post.originalData);
        print(civitaiModel.meta?.prompt);
        return civitaiModel.meta?.prompt ?? post.tags.join(', ');
      } catch (e) {
        print('Failed to re-parse CivitaiImageModel from originalData: $e');
        return post.tags.join(', ');
      }
    } else {
      return post.tags.join(', ');
    }
  }
}

// Modify the Provider's creation logic to perform dependency injection.
// 修改 Provider 的创建逻辑，执行依赖注入。
final downloadNotifierProvider =
    StateNotifierProvider<DownloadNotifier, Map<String, DownloadInfo>>((ref) {
      final downloader = ref.watch(downloaderProvider);
      return DownloadNotifier(downloader);
    });
