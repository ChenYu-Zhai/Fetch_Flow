import 'package:freezed_annotation/freezed_annotation.dart';

/// 强制将任何类型（Int, Double, String）转换为 String
class ForceStringConverter implements JsonConverter<String?, Object?> {
  const ForceStringConverter();

  @override
  String? fromJson(Object? json) {
    if (json == null) return null;
    // 核心魔法：无论是什么类型，直接调用 toString()
    return json.toString();
  }

  @override
  Object? toJson(String? object) => object;
}