import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_provider.dart'; // We need sharedPreferencesProvider.

// Create a Notifier to handle the saving logic.
// 创建一个 Notifier 来处理保存逻辑。
class CrossAxisCountNotifier extends StateNotifier<int> {
  final SharedPreferences _prefs;
  CrossAxisCountNotifier(this._prefs)
    : super(_prefs.getInt('crossAxisCount') ?? 2);

  Future<void> setCount(int count) async {
    debugPrint('[CrossAxisCountNotifier] Setting cross axis count to: $count');
    await _prefs.setInt('crossAxisCount', count);
    state = count;
  }
}

final crossAxisCountNotifierProvider =
    StateNotifierProvider<CrossAxisCountNotifier, int>((ref) {
      final prefs = ref.watch(sharedPreferencesProvider).requireValue;
      return CrossAxisCountNotifier(prefs);
    });

class DownloadPathNotifier extends StateNotifier<String> {
  final SharedPreferences _prefs;
  DownloadPathNotifier(this._prefs)
    : super(_prefs.getString('downloadPath') ?? '');

  Future<void> setPath(String path) async {
    debugPrint('[DownloadPathNotifier] Setting download path to: $path');
    await _prefs.setString('downloadPath', path);
    state = path;
  }
}

final downloadPathProvider =
    StateNotifierProvider<DownloadPathNotifier, String>((ref) {
      final prefs = ref.watch(sharedPreferencesProvider).requireValue;
      return DownloadPathNotifier(prefs);
    });
