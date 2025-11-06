// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'rule34_post_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Rule34PostModel _$Rule34PostModelFromJson(Map<String, dynamic> json) {
  return _Rule34PostModel.fromJson(json);
}

/// @nodoc
mixin _$Rule34PostModel {
  int get id => throw _privateConstructorUsedError;
  int get score => throw _privateConstructorUsedError;
  int get width => throw _privateConstructorUsedError;
  int get height =>
      throw _privateConstructorUsedError; // Use @JsonKey to map snake_case fields from the API
  // to camelCase properties in our code.
  // 使用 @JsonKey 将 API 返回的 snake_case 字段
  // 映射到我们代码中的 camelCase 属性。
  @JsonKey(name: 'file_url')
  String get fileUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'sample_url')
  String get sampleUrl => throw _privateConstructorUsedError; // The API returns a space-separated string.
  // API 返回的是一个空格分隔的字符串。
  String get tags => throw _privateConstructorUsedError;

  /// Serializes this Rule34PostModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Rule34PostModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $Rule34PostModelCopyWith<Rule34PostModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $Rule34PostModelCopyWith<$Res> {
  factory $Rule34PostModelCopyWith(
    Rule34PostModel value,
    $Res Function(Rule34PostModel) then,
  ) = _$Rule34PostModelCopyWithImpl<$Res, Rule34PostModel>;
  @useResult
  $Res call({
    int id,
    int score,
    int width,
    int height,
    @JsonKey(name: 'file_url') String fileUrl,
    @JsonKey(name: 'sample_url') String sampleUrl,
    String tags,
  });
}

/// @nodoc
class _$Rule34PostModelCopyWithImpl<$Res, $Val extends Rule34PostModel>
    implements $Rule34PostModelCopyWith<$Res> {
  _$Rule34PostModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Rule34PostModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? score = null,
    Object? width = null,
    Object? height = null,
    Object? fileUrl = null,
    Object? sampleUrl = null,
    Object? tags = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            score: null == score
                ? _value.score
                : score // ignore: cast_nullable_to_non_nullable
                      as int,
            width: null == width
                ? _value.width
                : width // ignore: cast_nullable_to_non_nullable
                      as int,
            height: null == height
                ? _value.height
                : height // ignore: cast_nullable_to_non_nullable
                      as int,
            fileUrl: null == fileUrl
                ? _value.fileUrl
                : fileUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            sampleUrl: null == sampleUrl
                ? _value.sampleUrl
                : sampleUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            tags: null == tags
                ? _value.tags
                : tags // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$Rule34PostModelImplCopyWith<$Res>
    implements $Rule34PostModelCopyWith<$Res> {
  factory _$$Rule34PostModelImplCopyWith(
    _$Rule34PostModelImpl value,
    $Res Function(_$Rule34PostModelImpl) then,
  ) = __$$Rule34PostModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    int score,
    int width,
    int height,
    @JsonKey(name: 'file_url') String fileUrl,
    @JsonKey(name: 'sample_url') String sampleUrl,
    String tags,
  });
}

/// @nodoc
class __$$Rule34PostModelImplCopyWithImpl<$Res>
    extends _$Rule34PostModelCopyWithImpl<$Res, _$Rule34PostModelImpl>
    implements _$$Rule34PostModelImplCopyWith<$Res> {
  __$$Rule34PostModelImplCopyWithImpl(
    _$Rule34PostModelImpl _value,
    $Res Function(_$Rule34PostModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Rule34PostModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? score = null,
    Object? width = null,
    Object? height = null,
    Object? fileUrl = null,
    Object? sampleUrl = null,
    Object? tags = null,
  }) {
    return _then(
      _$Rule34PostModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        score: null == score
            ? _value.score
            : score // ignore: cast_nullable_to_non_nullable
                  as int,
        width: null == width
            ? _value.width
            : width // ignore: cast_nullable_to_non_nullable
                  as int,
        height: null == height
            ? _value.height
            : height // ignore: cast_nullable_to_non_nullable
                  as int,
        fileUrl: null == fileUrl
            ? _value.fileUrl
            : fileUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        sampleUrl: null == sampleUrl
            ? _value.sampleUrl
            : sampleUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        tags: null == tags
            ? _value.tags
            : tags // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$Rule34PostModelImpl implements _Rule34PostModel {
  const _$Rule34PostModelImpl({
    required this.id,
    required this.score,
    required this.width,
    required this.height,
    @JsonKey(name: 'file_url') required this.fileUrl,
    @JsonKey(name: 'sample_url') required this.sampleUrl,
    required this.tags,
  });

  factory _$Rule34PostModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$Rule34PostModelImplFromJson(json);

  @override
  final int id;
  @override
  final int score;
  @override
  final int width;
  @override
  final int height;
  // Use @JsonKey to map snake_case fields from the API
  // to camelCase properties in our code.
  // 使用 @JsonKey 将 API 返回的 snake_case 字段
  // 映射到我们代码中的 camelCase 属性。
  @override
  @JsonKey(name: 'file_url')
  final String fileUrl;
  @override
  @JsonKey(name: 'sample_url')
  final String sampleUrl;
  // The API returns a space-separated string.
  // API 返回的是一个空格分隔的字符串。
  @override
  final String tags;

  @override
  String toString() {
    return 'Rule34PostModel(id: $id, score: $score, width: $width, height: $height, fileUrl: $fileUrl, sampleUrl: $sampleUrl, tags: $tags)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$Rule34PostModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.width, width) || other.width == width) &&
            (identical(other.height, height) || other.height == height) &&
            (identical(other.fileUrl, fileUrl) || other.fileUrl == fileUrl) &&
            (identical(other.sampleUrl, sampleUrl) ||
                other.sampleUrl == sampleUrl) &&
            (identical(other.tags, tags) || other.tags == tags));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    score,
    width,
    height,
    fileUrl,
    sampleUrl,
    tags,
  );

  /// Create a copy of Rule34PostModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$Rule34PostModelImplCopyWith<_$Rule34PostModelImpl> get copyWith =>
      __$$Rule34PostModelImplCopyWithImpl<_$Rule34PostModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$Rule34PostModelImplToJson(this);
  }
}

abstract class _Rule34PostModel implements Rule34PostModel {
  const factory _Rule34PostModel({
    required final int id,
    required final int score,
    required final int width,
    required final int height,
    @JsonKey(name: 'file_url') required final String fileUrl,
    @JsonKey(name: 'sample_url') required final String sampleUrl,
    required final String tags,
  }) = _$Rule34PostModelImpl;

  factory _Rule34PostModel.fromJson(Map<String, dynamic> json) =
      _$Rule34PostModelImpl.fromJson;

  @override
  int get id;
  @override
  int get score;
  @override
  int get width;
  @override
  int get height; // Use @JsonKey to map snake_case fields from the API
  // to camelCase properties in our code.
  // 使用 @JsonKey 将 API 返回的 snake_case 字段
  // 映射到我们代码中的 camelCase 属性。
  @override
  @JsonKey(name: 'file_url')
  String get fileUrl;
  @override
  @JsonKey(name: 'sample_url')
  String get sampleUrl; // The API returns a space-separated string.
  // API 返回的是一个空格分隔的字符串。
  @override
  String get tags;

  /// Create a copy of Rule34PostModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$Rule34PostModelImplCopyWith<_$Rule34PostModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
