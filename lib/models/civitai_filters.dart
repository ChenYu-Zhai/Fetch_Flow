// lib/models/civitai_filters.dart

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'civitai_filters.freezed.dart';

// Enum definitions follow Dart style guidelines (camelCase).
// 枚举定义遵循 Dart 风格指南 (camelCase)。
enum CivitaiSort { mostReactions, mostComments, newest }
enum CivitaiPeriod { allTime, year, month, week, day }
enum CivitaiNsfw { none, soft, mature, x, blocked } // 'blocked' is our internal state.

// Extensions for each enum to convert them to API-compatible values.
// 为每个枚举创建扩展，以便将其转换为 API 兼容的值。

extension CivitaiSortExtension on CivitaiSort {
  String get toApiValue {
    switch (this) {
      case CivitaiSort.mostReactions: return 'Most Reactions';
      case CivitaiSort.mostComments: return 'Most Comments';
      case CivitaiSort.newest: return 'Newest';
    }
  }
}

extension CivitaiPeriodExtension on CivitaiPeriod {
  String get toApiValue {
    switch (this) {
      case CivitaiPeriod.allTime: return 'AllTime';
      case CivitaiPeriod.year: return 'Year';
      case CivitaiPeriod.month: return 'Month';
      case CivitaiPeriod.week: return 'Week';
      case CivitaiPeriod.day: return 'Day';
    }
  }
}

extension CivitaiNsfwExtension on CivitaiNsfw {
  /// Returns an API-compatible value (String, bool, or null).
  /// 返回一个 API 兼容的值 (String, bool, 或 null)。
  dynamic get toApiValue {
    switch (this) {
      case CivitaiNsfw.none:
        // According to API documentation, nsfw=boolean, None corresponds to false.
        // 根据 API 文档，nsfw=boolean，None 级别对应 false。
        return false;
      case CivitaiNsfw.soft: return 'Soft';
      case CivitaiNsfw.mature: return 'Mature';
      case CivitaiNsfw.x: return 'X';
      case CivitaiNsfw.blocked:
        // 'blocked' is our internal state, indicating no nsfw content should be shown.
        // 'blocked' 是我们自己的状态，表示不看任何 nsfw 内容。
        return false;
    }
  }
}


@freezed
class CivitaiFilterState with _$CivitaiFilterState {
  const CivitaiFilterState._();

  const factory CivitaiFilterState({
    @Default(50) int limit,
    int? postId,
    int? modelId,
    int? modelVersionId,
    String? username,
    // Change default value to none, more compliant with API semantics.
    // 将默认值改为 none，更符合 API 语义。
    @Default(CivitaiNsfw.none) CivitaiNsfw nsfw,
    @Default(CivitaiSort.newest) CivitaiSort sort,
    @Default(CivitaiPeriod.allTime) CivitaiPeriod period,
  }) = _CivitaiFilterState;

  Map<String, dynamic> toApiParams() {
    final map = <String, dynamic>{
      'limit': limit,
      
      // Use the extension methods defined for each Enum.
      // 使用我们为每个 Enum 定义的扩展方法。
      'sort': sort.toApiValue,
      'period': period.toApiValue,
      
      // nsfw's toApiValue already handles all cases.
      // nsfw 的 toApiValue 已经处理了所有情况。
      'nsfw': nsfw.toApiValue,
    };
    
    // Debug print (can be kept or removed in production).
    // 调试打印（可以在发布时保留或移除）。
    debugPrint("Civitai API Filter Params: $map");

    // Only add non-null parameters.
    // 只添加非空的参数。
    if (postId != null) map['postId'] = postId;
    if (modelId != null) map['modelId'] = modelId;
    if (modelVersionId != null) map['modelVersionId'] = modelVersionId;
    if (username != null && username!.isNotEmpty) map['username'] = username;
    
    // If nsfw is 'undefined' (API default behavior), this parameter should not be included.
    // In our logic, we always provide a value (true, false, or string), so no removal is needed here.
    // 如果 nsfw 是 'undefined' (API 默认行为)，则不应包含此参数。
    // 在我们的逻辑中，我们总是提供一个值 (true, false, 或 string)，所以这里不需要移除。
    // map.removeWhere((key, value) => value == null);

    return map;
  }
}