// lib/utils/downloader.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'mobile_desktop_downloader_impl.dart'
    if (dart.library.html) 'web_downloader_impl.dart';

// Defines a contract for downloading media and text files.
// 定义一个用于下载媒体和文本文件的契约。
abstract class Downloader {
  Future<void> downloadMedia(String url, String fileName, {String? path});
  Future<void> downloadText(
    String textContent,
    String fileName, {
    String? path,
  });
}

// Provider for the Downloader, which is conditionally imported based on the platform.
// Downloader 的 Provider，根据平台条件导入。
final downloaderProvider = Provider<Downloader>((ref) {
  return getDownloader();
});
