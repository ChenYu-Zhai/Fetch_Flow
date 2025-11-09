// lib/utils/path_helper.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

Future<String?> getDownloadPath() async {
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
  
  directory ??= await getTemporaryDirectory();
  return directory.path;
}