// lib/utils/path_helper.dart (或者您放置这些 Provider 的地方)

import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';


final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});


final downloadPathProvider = StateNotifierProvider<DownloadPathNotifier, String>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider).asData?.value;
  if (prefs == null) {
      return DownloadPathNotifier(null);
  }
  return DownloadPathNotifier(prefs);
});

class DownloadPathNotifier extends StateNotifier<String> {
  final SharedPreferences? _prefs;
  DownloadPathNotifier(this._prefs)
      : super(_prefs?.getString('downloadPath') ?? '');

  Future<void> setPath(String path) async {
    if (_prefs == null) return;
    await _prefs!.setString('downloadPath', path);
    state = path;
  }
}

final finalDownloadPathProvider = FutureProvider<String?>((ref) async {
  final customPath = ref.watch(downloadPathProvider);

  if (customPath.isNotEmpty) {
    debugPrint('✅ Using user-defined download path: $customPath');
    return customPath;
  }

  debugPrint('ℹ️ No custom path set, fetching platform default download path...');
  if (kIsWeb) {
    return null;
  }

  Directory? directory;
  try {
    if (Platform.isIOS || Platform.isMacOS) {
      directory = await getApplicationDocumentsDirectory();
    } else if (Platform.isAndroid) {
      if (await Permission.storage.request().isGranted) {
        directory = await getExternalStorageDirectory();
      }
    } else if (Platform.isWindows || Platform.isLinux) {
      directory = await getDownloadsDirectory();
    }
  } catch (err) {
    print("Cannot get default download directory: $err");
  }
  directory ??= await getTemporaryDirectory();
  debugPrint('✅ Using platform default download path: ${directory.path}');
  return directory.path;
});
