// lib/utils/path_helper.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

/// A helper function to get the platform-specific download path.
/// 一个用于获取平台特定下载路径的辅助函数。
Future<String?> getDownloadPath() async {
  // Web platform does not have the concept of a file system path, so return null.
  // Web 平台没有文件系统路径的概念，返回 null。
  if (kIsWeb) {
    return null;
  }

  Directory? directory;
  try {
    if (Platform.isIOS || Platform.isMacOS) {
      directory = await getApplicationDocumentsDirectory();
    } else if (Platform.isAndroid) {
      // Request permission.
      // 请求权限。
      if (await Permission.storage.request().isGranted) {
        directory = await getExternalStorageDirectory();
      }
    } else if (Platform.isWindows || Platform.isLinux) {
      directory = await getDownloadsDirectory();
    }
  } catch (err) {
    print("Cannot get download directory: $err");
  }
  
  // If all attempts fail, fall back to the temporary directory.
  // 如果所有尝试都失败，回退到临时目录。
  directory ??= await getTemporaryDirectory();
  return directory.path;
}