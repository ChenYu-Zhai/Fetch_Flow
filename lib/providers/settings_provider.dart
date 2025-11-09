// lib/providers/settings_provider.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'shared_preferences_provider.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'shared_preferences_provider.dart';

/* -------------------- 工具函数 -------------------- */
int _getInt(Ref ref, String key, int fallback) => ref
    .watch(sharedPreferencesProvider)
    .when(
      data: (p) => p.getInt(key) ?? fallback,
      loading: () => fallback,
      error: (_, __) => fallback,
    );

double _getDouble(Ref ref, String key, double fallback) => ref
    .watch(sharedPreferencesProvider)
    .when(
      data: (p) => p.getDouble(key) ?? fallback,
      loading: () => fallback,
      error: (_, __) => fallback,
    );

/* -------------------- 各配置项 -------------------- */

/// 网格列数（持久化）
final crossAxisCountNotifierProvider =
    StateNotifierProvider<CrossAxisCountNotifier, int>((ref) {
      final initial = _getInt(ref, 'crossAxisCount', 3);
      return CrossAxisCountNotifier(ref, initial); // ✅ 传入 ref
    });

class CrossAxisCountNotifier extends StateNotifier<int> {
  final Ref _ref; // ✅ 保存 ref
  CrossAxisCountNotifier(this._ref, super.state);

  Future<void> setCount(int value) async {
    final prefs = await _ref.read(sharedPreferencesProvider.future);
    await prefs.setInt('crossAxisCount', value);
    state = value;
  }
}

/// 预加载延迟（持久化）
final preloadDelayProvider = StateNotifierProvider<PreloadDelayNotifier, int>((
  ref,
) {
  final initial = _getInt(ref, 'preloadDelay', 300);
  return PreloadDelayNotifier(ref, initial); // ✅ 传入 ref
});

class PreloadDelayNotifier extends StateNotifier<int> {
  final Ref _ref;
  PreloadDelayNotifier(this._ref, super.state);

  Future<void> setDelay(int value) async {
    final prefs = await _ref.read(sharedPreferencesProvider.future);
    await prefs.setInt('preloadDelay', value);
    state = value;
  }
}

/// 每页数量（持久化）
final prefetchThresholdNotifierProvider =
    StateNotifierProvider<PrefetchThresholdNotifier, int>((ref) {
      final initial = _getInt(ref, 'prefetchThreshold', 20);
      return PrefetchThresholdNotifier(ref, initial); // ✅ 传入 ref
    });

class PrefetchThresholdNotifier extends StateNotifier<int> {
  final Ref _ref;
  PrefetchThresholdNotifier(this._ref, super.state);

  Future<void> setThreshold(int value) async {
    final prefs = await _ref.read(sharedPreferencesProvider.future);
    await prefs.setInt('prefetchThreshold', value);
    state = value;
  }
}

/// 下载路径（保持您原有实现）
final downloadPathProvider =
    StateNotifierProvider<DownloadPathNotifier, String>((ref) {
      final prefs = ref.watch(sharedPreferencesProvider).requireValue;
      return DownloadPathNotifier(prefs);
    });

class DownloadPathNotifier extends StateNotifier<String> {
  final SharedPreferences _prefs;
  DownloadPathNotifier(this._prefs)
    : super(_prefs.getString('downloadPath') ?? '');

  Future<void> setPath(String path) async {
    await _prefs.setString('downloadPath', path);
    state = path;
  }
}

/// Slider 实时显示值（纯 UI 状态，不持久化）
final sliderValueProvider = StateProvider<int>((ref) => 20);
