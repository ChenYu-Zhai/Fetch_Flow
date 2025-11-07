import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 全局单例
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((_) async {
  return await SharedPreferences.getInstance();
});