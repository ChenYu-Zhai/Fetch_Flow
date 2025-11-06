// lib/models/rule34_post_model.dart

import 'package:freezed_annotation/freezed_annotation.dart';

part 'rule34_post_model.freezed.dart';
part 'rule34_post_model.g.dart';

@freezed
class Rule34PostModel with _$Rule34PostModel {
  const factory Rule34PostModel({
    required int id,
    required int score,
    required int width,
    required int height,

    // Use @JsonKey to map snake_case fields from the API
    // to camelCase properties in our code.
    // 使用 @JsonKey 将 API 返回的 snake_case 字段
    // 映射到我们代码中的 camelCase 属性。
    @JsonKey(name: 'file_url') required String fileUrl,
    @JsonKey(name: 'sample_url') required String sampleUrl,

    // The API returns a space-separated string.
    // API 返回的是一个空格分隔的字符串。
    required String tags,
  }) = _Rule34PostModel;

  factory Rule34PostModel.fromJson(Map<String, dynamic> json) =>
      _$Rule34PostModelFromJson(json);
}
