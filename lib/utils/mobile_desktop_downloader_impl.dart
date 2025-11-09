// lib/utils/mobile_desktop_downloader_impl.dart

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'downloader.dart';

class MobileDesktopDownloader implements Downloader {
  final Dio _dio = Dio();

  Future<String?> _getDownloadPath({String? customPath}) async {
    if (customPath != null && customPath.isNotEmpty) {
      debugPrint('[MobileDesktopDownloader] Using custom download path: $customPath');
      return customPath;
    }
    Directory? directory;
    try {
      if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else if (Platform.isAndroid) {
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          status = await Permission.storage.request();
        }
        if (status.isGranted) {
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getDownloadsDirectory();
      }
    } catch (err) {
      debugPrint("[MobileDesktopDownloader] Cannot get download directory: $err");
      directory = await getTemporaryDirectory();
    }
    debugPrint('[MobileDesktopDownloader] Using download path: ${directory?.path}');
    return directory?.path;
  }

  @override
  Future<void> downloadMedia(
    String url,
    String fileName, {
    String? path,
  }) async {
    try {
      final downloadPath = await _getDownloadPath(customPath: path);
      if (downloadPath == null) {
        throw Exception("Could not determine download path.");
      }
      final savePath = '$downloadPath/$fileName';
      debugPrint('[MobileDesktopDownloader] Downloading media from $url to $savePath');
      await _dio.download(url, savePath);
      debugPrint('[MobileDesktopDownloader] Successfully downloaded media: $savePath');
    } catch (e) {
      debugPrint('[MobileDesktopDownloader] Failed to download media: $e');
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
      final downloadPath = await _getDownloadPath(customPath: path);
      if (downloadPath == null) {
        throw Exception("Could not determine download path.");
      }
      final savePath = '$downloadPath/$fileName.txt';
      final file = File(savePath);
      debugPrint('[MobileDesktopDownloader] Downloading text content to $savePath');
      await file.writeAsString(textContent);
      debugPrint('[MobileDesktopDownloader] Successfully downloaded text content: $savePath');
    } catch (e) {
      debugPrint('[MobileDesktopDownloader] Failed to download text content: $e');
      rethrow;
    }
  }
}

Downloader getDownloader() => MobileDesktopDownloader();
