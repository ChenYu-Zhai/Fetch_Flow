// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'civitai_image_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ImageStats _$ImageStatsFromJson(Map<String, dynamic> json) {
  return _ImageStats.fromJson(json);
}

/// @nodoc
mixin _$ImageStats {
  int get likeCount => throw _privateConstructorUsedError;

  /// Serializes this ImageStats to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ImageStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ImageStatsCopyWith<ImageStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ImageStatsCopyWith<$Res> {
  factory $ImageStatsCopyWith(
    ImageStats value,
    $Res Function(ImageStats) then,
  ) = _$ImageStatsCopyWithImpl<$Res, ImageStats>;
  @useResult
  $Res call({int likeCount});
}

/// @nodoc
class _$ImageStatsCopyWithImpl<$Res, $Val extends ImageStats>
    implements $ImageStatsCopyWith<$Res> {
  _$ImageStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ImageStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? likeCount = null}) {
    return _then(
      _value.copyWith(
            likeCount: null == likeCount
                ? _value.likeCount
                : likeCount // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ImageStatsImplCopyWith<$Res>
    implements $ImageStatsCopyWith<$Res> {
  factory _$$ImageStatsImplCopyWith(
    _$ImageStatsImpl value,
    $Res Function(_$ImageStatsImpl) then,
  ) = __$$ImageStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int likeCount});
}

/// @nodoc
class __$$ImageStatsImplCopyWithImpl<$Res>
    extends _$ImageStatsCopyWithImpl<$Res, _$ImageStatsImpl>
    implements _$$ImageStatsImplCopyWith<$Res> {
  __$$ImageStatsImplCopyWithImpl(
    _$ImageStatsImpl _value,
    $Res Function(_$ImageStatsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ImageStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? likeCount = null}) {
    return _then(
      _$ImageStatsImpl(
        likeCount: null == likeCount
            ? _value.likeCount
            : likeCount // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ImageStatsImpl implements _ImageStats {
  const _$ImageStatsImpl({this.likeCount = 0});

  factory _$ImageStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$ImageStatsImplFromJson(json);

  @override
  @JsonKey()
  final int likeCount;

  @override
  String toString() {
    return 'ImageStats(likeCount: $likeCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ImageStatsImpl &&
            (identical(other.likeCount, likeCount) ||
                other.likeCount == likeCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, likeCount);

  /// Create a copy of ImageStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ImageStatsImplCopyWith<_$ImageStatsImpl> get copyWith =>
      __$$ImageStatsImplCopyWithImpl<_$ImageStatsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ImageStatsImplToJson(this);
  }
}

abstract class _ImageStats implements ImageStats {
  const factory _ImageStats({final int likeCount}) = _$ImageStatsImpl;

  factory _ImageStats.fromJson(Map<String, dynamic> json) =
      _$ImageStatsImpl.fromJson;

  @override
  int get likeCount;

  /// Create a copy of ImageStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ImageStatsImplCopyWith<_$ImageStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ImageMeta _$ImageMetaFromJson(Map<String, dynamic> json) {
  return _ImageMeta.fromJson(json);
}

/// @nodoc
mixin _$ImageMeta {
  @JsonKey(name: 'prompt')
  String? get prompt => throw _privateConstructorUsedError;
  @JsonKey(name: 'negativePrompt')
  String? get negativePrompt => throw _privateConstructorUsedError;
  @JsonKey(name: 'tags')
  List<String>? get tags => throw _privateConstructorUsedError;

  /// Serializes this ImageMeta to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ImageMeta
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ImageMetaCopyWith<ImageMeta> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ImageMetaCopyWith<$Res> {
  factory $ImageMetaCopyWith(ImageMeta value, $Res Function(ImageMeta) then) =
      _$ImageMetaCopyWithImpl<$Res, ImageMeta>;
  @useResult
  $Res call({
    @JsonKey(name: 'prompt') String? prompt,
    @JsonKey(name: 'negativePrompt') String? negativePrompt,
    @JsonKey(name: 'tags') List<String>? tags,
  });
}

/// @nodoc
class _$ImageMetaCopyWithImpl<$Res, $Val extends ImageMeta>
    implements $ImageMetaCopyWith<$Res> {
  _$ImageMetaCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ImageMeta
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? prompt = freezed,
    Object? negativePrompt = freezed,
    Object? tags = freezed,
  }) {
    return _then(
      _value.copyWith(
            prompt: freezed == prompt
                ? _value.prompt
                : prompt // ignore: cast_nullable_to_non_nullable
                      as String?,
            negativePrompt: freezed == negativePrompt
                ? _value.negativePrompt
                : negativePrompt // ignore: cast_nullable_to_non_nullable
                      as String?,
            tags: freezed == tags
                ? _value.tags
                : tags // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ImageMetaImplCopyWith<$Res>
    implements $ImageMetaCopyWith<$Res> {
  factory _$$ImageMetaImplCopyWith(
    _$ImageMetaImpl value,
    $Res Function(_$ImageMetaImpl) then,
  ) = __$$ImageMetaImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'prompt') String? prompt,
    @JsonKey(name: 'negativePrompt') String? negativePrompt,
    @JsonKey(name: 'tags') List<String>? tags,
  });
}

/// @nodoc
class __$$ImageMetaImplCopyWithImpl<$Res>
    extends _$ImageMetaCopyWithImpl<$Res, _$ImageMetaImpl>
    implements _$$ImageMetaImplCopyWith<$Res> {
  __$$ImageMetaImplCopyWithImpl(
    _$ImageMetaImpl _value,
    $Res Function(_$ImageMetaImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ImageMeta
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? prompt = freezed,
    Object? negativePrompt = freezed,
    Object? tags = freezed,
  }) {
    return _then(
      _$ImageMetaImpl(
        prompt: freezed == prompt
            ? _value.prompt
            : prompt // ignore: cast_nullable_to_non_nullable
                  as String?,
        negativePrompt: freezed == negativePrompt
            ? _value.negativePrompt
            : negativePrompt // ignore: cast_nullable_to_non_nullable
                  as String?,
        tags: freezed == tags
            ? _value._tags
            : tags // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ImageMetaImpl implements _ImageMeta {
  const _$ImageMetaImpl({
    @JsonKey(name: 'prompt') this.prompt,
    @JsonKey(name: 'negativePrompt') this.negativePrompt,
    @JsonKey(name: 'tags') final List<String>? tags = const <String>[],
  }) : _tags = tags;

  factory _$ImageMetaImpl.fromJson(Map<String, dynamic> json) =>
      _$$ImageMetaImplFromJson(json);

  @override
  @JsonKey(name: 'prompt')
  final String? prompt;
  @override
  @JsonKey(name: 'negativePrompt')
  final String? negativePrompt;
  final List<String>? _tags;
  @override
  @JsonKey(name: 'tags')
  List<String>? get tags {
    final value = _tags;
    if (value == null) return null;
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'ImageMeta(prompt: $prompt, negativePrompt: $negativePrompt, tags: $tags)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ImageMetaImpl &&
            (identical(other.prompt, prompt) || other.prompt == prompt) &&
            (identical(other.negativePrompt, negativePrompt) ||
                other.negativePrompt == negativePrompt) &&
            const DeepCollectionEquality().equals(other._tags, _tags));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    prompt,
    negativePrompt,
    const DeepCollectionEquality().hash(_tags),
  );

  /// Create a copy of ImageMeta
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ImageMetaImplCopyWith<_$ImageMetaImpl> get copyWith =>
      __$$ImageMetaImplCopyWithImpl<_$ImageMetaImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ImageMetaImplToJson(this);
  }
}

abstract class _ImageMeta implements ImageMeta {
  const factory _ImageMeta({
    @JsonKey(name: 'prompt') final String? prompt,
    @JsonKey(name: 'negativePrompt') final String? negativePrompt,
    @JsonKey(name: 'tags') final List<String>? tags,
  }) = _$ImageMetaImpl;

  factory _ImageMeta.fromJson(Map<String, dynamic> json) =
      _$ImageMetaImpl.fromJson;

  @override
  @JsonKey(name: 'prompt')
  String? get prompt;
  @override
  @JsonKey(name: 'negativePrompt')
  String? get negativePrompt;
  @override
  @JsonKey(name: 'tags')
  List<String>? get tags;

  /// Create a copy of ImageMeta
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ImageMetaImplCopyWith<_$ImageMetaImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CivitaiImageModel _$CivitaiImageModelFromJson(Map<String, dynamic> json) {
  return _CivitaiImageModel.fromJson(json);
}

/// @nodoc
mixin _$CivitaiImageModel {
  int get id => throw _privateConstructorUsedError;
  String get url => throw _privateConstructorUsedError;
  String get hash =>
      throw _privateConstructorUsedError; // Use @Default to provide default values for potentially missing fields, enhancing robustness.
  // 使用 @Default 为可能缺失的字段提供默认值，增强鲁棒性。
  int get width => throw _privateConstructorUsedError;
  int get height => throw _privateConstructorUsedError;
  bool get nsfw => throw _privateConstructorUsedError;
  String? get username =>
      throw _privateConstructorUsedError; // Author name from the API.
  // Use @JsonKey to map the JSON field 'type' to our 'type' property.
  // unknownEnumValue ensures the app doesn't crash if the API returns an unrecognized type.
  // 使用 @JsonKey 将 JSON 字段 'type' 映射到我们的 'type' 属性。
  // unknownEnumValue 确保即使 API 返回了我们不认识的新类型，应用也不会崩溃。
  @JsonKey(unknownEnumValue: MediaType.image)
  MediaType get type => throw _privateConstructorUsedError; // Directly use our refactored freezed classes.
  // 类型直接使用我们重构后的 freezed 类。
  ImageMeta? get meta => throw _privateConstructorUsedError;
  ImageStats? get stats => throw _privateConstructorUsedError;

  /// Serializes this CivitaiImageModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CivitaiImageModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CivitaiImageModelCopyWith<CivitaiImageModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CivitaiImageModelCopyWith<$Res> {
  factory $CivitaiImageModelCopyWith(
    CivitaiImageModel value,
    $Res Function(CivitaiImageModel) then,
  ) = _$CivitaiImageModelCopyWithImpl<$Res, CivitaiImageModel>;
  @useResult
  $Res call({
    int id,
    String url,
    String hash,
    int width,
    int height,
    bool nsfw,
    String? username,
    @JsonKey(unknownEnumValue: MediaType.image) MediaType type,
    ImageMeta? meta,
    ImageStats? stats,
  });

  $ImageMetaCopyWith<$Res>? get meta;
  $ImageStatsCopyWith<$Res>? get stats;
}

/// @nodoc
class _$CivitaiImageModelCopyWithImpl<$Res, $Val extends CivitaiImageModel>
    implements $CivitaiImageModelCopyWith<$Res> {
  _$CivitaiImageModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CivitaiImageModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? url = null,
    Object? hash = null,
    Object? width = null,
    Object? height = null,
    Object? nsfw = null,
    Object? username = freezed,
    Object? type = null,
    Object? meta = freezed,
    Object? stats = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            url: null == url
                ? _value.url
                : url // ignore: cast_nullable_to_non_nullable
                      as String,
            hash: null == hash
                ? _value.hash
                : hash // ignore: cast_nullable_to_non_nullable
                      as String,
            width: null == width
                ? _value.width
                : width // ignore: cast_nullable_to_non_nullable
                      as int,
            height: null == height
                ? _value.height
                : height // ignore: cast_nullable_to_non_nullable
                      as int,
            nsfw: null == nsfw
                ? _value.nsfw
                : nsfw // ignore: cast_nullable_to_non_nullable
                      as bool,
            username: freezed == username
                ? _value.username
                : username // ignore: cast_nullable_to_non_nullable
                      as String?,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as MediaType,
            meta: freezed == meta
                ? _value.meta
                : meta // ignore: cast_nullable_to_non_nullable
                      as ImageMeta?,
            stats: freezed == stats
                ? _value.stats
                : stats // ignore: cast_nullable_to_non_nullable
                      as ImageStats?,
          )
          as $Val,
    );
  }

  /// Create a copy of CivitaiImageModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ImageMetaCopyWith<$Res>? get meta {
    if (_value.meta == null) {
      return null;
    }

    return $ImageMetaCopyWith<$Res>(_value.meta!, (value) {
      return _then(_value.copyWith(meta: value) as $Val);
    });
  }

  /// Create a copy of CivitaiImageModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ImageStatsCopyWith<$Res>? get stats {
    if (_value.stats == null) {
      return null;
    }

    return $ImageStatsCopyWith<$Res>(_value.stats!, (value) {
      return _then(_value.copyWith(stats: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CivitaiImageModelImplCopyWith<$Res>
    implements $CivitaiImageModelCopyWith<$Res> {
  factory _$$CivitaiImageModelImplCopyWith(
    _$CivitaiImageModelImpl value,
    $Res Function(_$CivitaiImageModelImpl) then,
  ) = __$$CivitaiImageModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String url,
    String hash,
    int width,
    int height,
    bool nsfw,
    String? username,
    @JsonKey(unknownEnumValue: MediaType.image) MediaType type,
    ImageMeta? meta,
    ImageStats? stats,
  });

  @override
  $ImageMetaCopyWith<$Res>? get meta;
  @override
  $ImageStatsCopyWith<$Res>? get stats;
}

/// @nodoc
class __$$CivitaiImageModelImplCopyWithImpl<$Res>
    extends _$CivitaiImageModelCopyWithImpl<$Res, _$CivitaiImageModelImpl>
    implements _$$CivitaiImageModelImplCopyWith<$Res> {
  __$$CivitaiImageModelImplCopyWithImpl(
    _$CivitaiImageModelImpl _value,
    $Res Function(_$CivitaiImageModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CivitaiImageModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? url = null,
    Object? hash = null,
    Object? width = null,
    Object? height = null,
    Object? nsfw = null,
    Object? username = freezed,
    Object? type = null,
    Object? meta = freezed,
    Object? stats = freezed,
  }) {
    return _then(
      _$CivitaiImageModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        url: null == url
            ? _value.url
            : url // ignore: cast_nullable_to_non_nullable
                  as String,
        hash: null == hash
            ? _value.hash
            : hash // ignore: cast_nullable_to_non_nullable
                  as String,
        width: null == width
            ? _value.width
            : width // ignore: cast_nullable_to_non_nullable
                  as int,
        height: null == height
            ? _value.height
            : height // ignore: cast_nullable_to_non_nullable
                  as int,
        nsfw: null == nsfw
            ? _value.nsfw
            : nsfw // ignore: cast_nullable_to_non_nullable
                  as bool,
        username: freezed == username
            ? _value.username
            : username // ignore: cast_nullable_to_non_nullable
                  as String?,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as MediaType,
        meta: freezed == meta
            ? _value.meta
            : meta // ignore: cast_nullable_to_non_nullable
                  as ImageMeta?,
        stats: freezed == stats
            ? _value.stats
            : stats // ignore: cast_nullable_to_non_nullable
                  as ImageStats?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CivitaiImageModelImpl extends _CivitaiImageModel {
  const _$CivitaiImageModelImpl({
    required this.id,
    required this.url,
    required this.hash,
    this.width = 1024,
    this.height = 1024,
    this.nsfw = false,
    this.username,
    @JsonKey(unknownEnumValue: MediaType.image) required this.type,
    this.meta,
    this.stats,
  }) : super._();

  factory _$CivitaiImageModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$CivitaiImageModelImplFromJson(json);

  @override
  final int id;
  @override
  final String url;
  @override
  final String hash;
  // Use @Default to provide default values for potentially missing fields, enhancing robustness.
  // 使用 @Default 为可能缺失的字段提供默认值，增强鲁棒性。
  @override
  @JsonKey()
  final int width;
  @override
  @JsonKey()
  final int height;
  @override
  @JsonKey()
  final bool nsfw;
  @override
  final String? username;
  // Author name from the API.
  // Use @JsonKey to map the JSON field 'type' to our 'type' property.
  // unknownEnumValue ensures the app doesn't crash if the API returns an unrecognized type.
  // 使用 @JsonKey 将 JSON 字段 'type' 映射到我们的 'type' 属性。
  // unknownEnumValue 确保即使 API 返回了我们不认识的新类型，应用也不会崩溃。
  @override
  @JsonKey(unknownEnumValue: MediaType.image)
  final MediaType type;
  // Directly use our refactored freezed classes.
  // 类型直接使用我们重构后的 freezed 类。
  @override
  final ImageMeta? meta;
  @override
  final ImageStats? stats;

  @override
  String toString() {
    return 'CivitaiImageModel(id: $id, url: $url, hash: $hash, width: $width, height: $height, nsfw: $nsfw, username: $username, type: $type, meta: $meta, stats: $stats)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CivitaiImageModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.hash, hash) || other.hash == hash) &&
            (identical(other.width, width) || other.width == width) &&
            (identical(other.height, height) || other.height == height) &&
            (identical(other.nsfw, nsfw) || other.nsfw == nsfw) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.meta, meta) || other.meta == meta) &&
            (identical(other.stats, stats) || other.stats == stats));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    url,
    hash,
    width,
    height,
    nsfw,
    username,
    type,
    meta,
    stats,
  );

  /// Create a copy of CivitaiImageModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CivitaiImageModelImplCopyWith<_$CivitaiImageModelImpl> get copyWith =>
      __$$CivitaiImageModelImplCopyWithImpl<_$CivitaiImageModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CivitaiImageModelImplToJson(this);
  }
}

abstract class _CivitaiImageModel extends CivitaiImageModel {
  const factory _CivitaiImageModel({
    required final int id,
    required final String url,
    required final String hash,
    final int width,
    final int height,
    final bool nsfw,
    final String? username,
    @JsonKey(unknownEnumValue: MediaType.image) required final MediaType type,
    final ImageMeta? meta,
    final ImageStats? stats,
  }) = _$CivitaiImageModelImpl;
  const _CivitaiImageModel._() : super._();

  factory _CivitaiImageModel.fromJson(Map<String, dynamic> json) =
      _$CivitaiImageModelImpl.fromJson;

  @override
  int get id;
  @override
  String get url;
  @override
  String get hash; // Use @Default to provide default values for potentially missing fields, enhancing robustness.
  // 使用 @Default 为可能缺失的字段提供默认值，增强鲁棒性。
  @override
  int get width;
  @override
  int get height;
  @override
  bool get nsfw;
  @override
  String? get username; // Author name from the API.
  // Use @JsonKey to map the JSON field 'type' to our 'type' property.
  // unknownEnumValue ensures the app doesn't crash if the API returns an unrecognized type.
  // 使用 @JsonKey 将 JSON 字段 'type' 映射到我们的 'type' 属性。
  // unknownEnumValue 确保即使 API 返回了我们不认识的新类型，应用也不会崩溃。
  @override
  @JsonKey(unknownEnumValue: MediaType.image)
  MediaType get type; // Directly use our refactored freezed classes.
  // 类型直接使用我们重构后的 freezed 类。
  @override
  ImageMeta? get meta;
  @override
  ImageStats? get stats;

  /// Create a copy of CivitaiImageModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CivitaiImageModelImplCopyWith<_$CivitaiImageModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
