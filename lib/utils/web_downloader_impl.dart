// lib/utils/web_downloader_impl.dart

import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'downloader.dart';

/// Concrete implementation of the Downloader for the web platform (using package:web).
/// Web 平台下载器的具体实现 (使用 package:web)。
class WebDownloader implements Downloader {
  @override
  Future<void> downloadMedia(
    String url,
    String fileName, {
    String? path,
  }) async {
    try {
      debugPrint('[WebDownloader] Downloading media from: $url');
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        // Convert the Uint8List returned by http to a JS-compatible type.
        // 将 http 返回的 Uint8List 转换为 JS 兼容的类型。
        final data = response.bodyBytes.toJS;

        // Use Blob from `package:web`.
        // 使用 `package:web` 中的 Blob。
        final blob = web.Blob([data].toJS);

        // Use URL.createObjectUrl from `package:web`.
        // 使用 `package:web` 中的 URL.createObjectUrl。
        final objectUrl = web.URL.createObjectURL(blob);

        // Use HTMLAnchorElement from `package:web`.
        // 使用 `package:web` 中的 HTMLAnchorElement。
        final anchor = web.document.createElement('a') as web.HTMLAnchorElement
          ..href = objectUrl
          ..setAttribute('download', fileName)
          ..click();

        // Clean up.
        // 清理。
        web.URL.revokeObjectURL(objectUrl);
        debugPrint('[WebDownloader] Successfully downloaded media: $fileName');
      } else {
        throw Exception('Failed to download file: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('[WebDownloader] Failed to download media: $e');
      rethrow;
    }
  }

  @override
  Future<void> downloadText(
    String textContent,
    String fileName, {
    String? path,
  }) async {
    try {
      debugPrint('[WebDownloader] Downloading text content to: $fileName.txt');
      // `path` is ignored on web; kept to match interface.
      // `path` 在 Web 上被忽略；保留以匹配接口。
      final name = fileName.endsWith('.txt') ? fileName : '$fileName.txt';

      // Convert Dart String to a JS-compatible type.
      // 将 Dart String 转换为 JS 兼容的类型。
      final data = textContent.toJS;

      final blob = web.Blob([data].toJS);
      final objectUrl = web.URL.createObjectURL(blob);
      final anchor = web.document.createElement('a') as web.HTMLAnchorElement
        ..href = objectUrl
        ..setAttribute('download', name)
        ..click();

      web.URL.revokeObjectURL(objectUrl);
      debugPrint('[WebDownloader] Successfully downloaded text content: $name');
    } catch (e) {
      debugPrint('[WebDownloader] Failed to download text content: $e');
      rethrow;
    }
  }
}

// The factory function remains unchanged.
// 工厂函数保持不变。
Downloader getDownloader() => WebDownloader();
