// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'unified_post_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

UnifiedPostModel _$UnifiedPostModelFromJson(Map<String, dynamic> json) {
  return _UnifiedPostModel.fromJson(json);
}

/// @nodoc
mixin _$UnifiedPostModel {
  // --- Core identity information ---
  // --- 核心身份信息 ---
  String get id => throw _privateConstructorUsedError;
  String get source =>
      throw _privateConstructorUsedError; // --- Core media information ---
  // --- 核心媒体信息 ---
  String get previewImageUrl => throw _privateConstructorUsedError;
  String get fullImageUrl => throw _privateConstructorUsedError;
  int get width => throw _privateConstructorUsedError;
  int get height => throw _privateConstructorUsedError;
  MediaType get mediaType =>
      throw _privateConstructorUsedError; // --- Additional information ---
  // --- 附加信息 ---
  List<String> get tags => throw _privateConstructorUsedError;
  String? get author => throw _privateConstructorUsedError;
  int? get score => throw _privateConstructorUsedError; // --- Metadata ---
  // --- 元数据 ---
  String? get detailsUrl => throw _privateConstructorUsedError;
  Map<String, dynamic> get originalData => throw _privateConstructorUsedError;

  /// Serializes this UnifiedPostModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UnifiedPostModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UnifiedPostModelCopyWith<UnifiedPostModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UnifiedPostModelCopyWith<$Res> {
  factory $UnifiedPostModelCopyWith(
    UnifiedPostModel value,
    $Res Function(UnifiedPostModel) then,
  ) = _$UnifiedPostModelCopyWithImpl<$Res, UnifiedPostModel>;
  @useResult
  $Res call({
    String id,
    String source,
    String previewImageUrl,
    String fullImageUrl,
    int width,
    int height,
    MediaType mediaType,
    List<String> tags,
    String? author,
    int? score,
    String? detailsUrl,
    Map<String, dynamic> originalData,
  });
}

/// @nodoc
class _$UnifiedPostModelCopyWithImpl<$Res, $Val extends UnifiedPostModel>
    implements $UnifiedPostModelCopyWith<$Res> {
  _$UnifiedPostModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UnifiedPostModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? source = null,
    Object? previewImageUrl = null,
    Object? fullImageUrl = null,
    Object? width = null,
    Object? height = null,
    Object? mediaType = null,
    Object? tags = null,
    Object? author = freezed,
    Object? score = freezed,
    Object? detailsUrl = freezed,
    Object? originalData = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            source: null == source
                ? _value.source
                : source // ignore: cast_nullable_to_non_nullable
                      as String,
            previewImageUrl: null == previewImageUrl
                ? _value.previewImageUrl
                : previewImageUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            fullImageUrl: null == fullImageUrl
                ? _value.fullImageUrl
                : fullImageUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            width: null == width
                ? _value.width
                : width // ignore: cast_nullable_to_non_nullable
                      as int,
            height: null == height
                ? _value.height
                : height // ignore: cast_nullable_to_non_nullable
                      as int,
            mediaType: null == mediaType
                ? _value.mediaType
                : mediaType // ignore: cast_nullable_to_non_nullable
                      as MediaType,
            tags: null == tags
                ? _value.tags
                : tags // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            author: freezed == author
                ? _value.author
                : author // ignore: cast_nullable_to_non_nullable
                      as String?,
            score: freezed == score
                ? _value.score
                : score // ignore: cast_nullable_to_non_nullable
                      as int?,
            detailsUrl: freezed == detailsUrl
                ? _value.detailsUrl
                : detailsUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            originalData: null == originalData
                ? _value.originalData
                : originalData // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UnifiedPostModelImplCopyWith<$Res>
    implements $UnifiedPostModelCopyWith<$Res> {
  factory _$$UnifiedPostModelImplCopyWith(
    _$UnifiedPostModelImpl value,
    $Res Function(_$UnifiedPostModelImpl) then,
  ) = __$$UnifiedPostModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String source,
    String previewImageUrl,
    String fullImageUrl,
    int width,
    int height,
    MediaType mediaType,
    List<String> tags,
    String? author,
    int? score,
    String? detailsUrl,
    Map<String, dynamic> originalData,
  });
}

/// @nodoc
class __$$UnifiedPostModelImplCopyWithImpl<$Res>
    extends _$UnifiedPostModelCopyWithImpl<$Res, _$UnifiedPostModelImpl>
    implements _$$UnifiedPostModelImplCopyWith<$Res> {
  __$$UnifiedPostModelImplCopyWithImpl(
    _$UnifiedPostModelImpl _value,
    $Res Function(_$UnifiedPostModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UnifiedPostModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? source = null,
    Object? previewImageUrl = null,
    Object? fullImageUrl = null,
    Object? width = null,
    Object? height = null,
    Object? mediaType = null,
    Object? tags = null,
    Object? author = freezed,
    Object? score = freezed,
    Object? detailsUrl = freezed,
    Object? originalData = null,
  }) {
    return _then(
      _$UnifiedPostModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        source: null == source
            ? _value.source
            : source // ignore: cast_nullable_to_non_nullable
                  as String,
        previewImageUrl: null == previewImageUrl
            ? _value.previewImageUrl
            : previewImageUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        fullImageUrl: null == fullImageUrl
            ? _value.fullImageUrl
            : fullImageUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        width: null == width
            ? _value.width
            : width // ignore: cast_nullable_to_non_nullable
                  as int,
        height: null == height
            ? _value.height
            : height // ignore: cast_nullable_to_non_nullable
                  as int,
        mediaType: null == mediaType
            ? _value.mediaType
            : mediaType // ignore: cast_nullable_to_non_nullable
                  as MediaType,
        tags: null == tags
            ? _value._tags
            : tags // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        author: freezed == author
            ? _value.author
            : author // ignore: cast_nullable_to_non_nullable
                  as String?,
        score: freezed == score
            ? _value.score
            : score // ignore: cast_nullable_to_non_nullable
                  as int?,
        detailsUrl: freezed == detailsUrl
            ? _value.detailsUrl
            : detailsUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        originalData: null == originalData
            ? _value._originalData
            : originalData // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UnifiedPostModelImpl implements _UnifiedPostModel {
  const _$UnifiedPostModelImpl({
    required this.id,
    required this.source,
    required this.previewImageUrl,
    required this.fullImageUrl,
    required this.width,
    required this.height,
    required this.mediaType,
    final List<String> tags = const [],
    this.author,
    this.score,
    this.detailsUrl,
    final Map<String, dynamic> originalData = const {},
  }) : _tags = tags,
       _originalData = originalData;

  factory _$UnifiedPostModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$UnifiedPostModelImplFromJson(json);

  // --- Core identity information ---
  // --- 核心身份信息 ---
  @override
  final String id;
  @override
  final String source;
  // --- Core media information ---
  // --- 核心媒体信息 ---
  @override
  final String previewImageUrl;
  @override
  final String fullImageUrl;
  @override
  final int width;
  @override
  final int height;
  @override
  final MediaType mediaType;
  // --- Additional information ---
  // --- 附加信息 ---
  final List<String> _tags;
  // --- Additional information ---
  // --- 附加信息 ---
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  final String? author;
  @override
  final int? score;
  // --- Metadata ---
  // --- 元数据 ---
  @override
  final String? detailsUrl;
  final Map<String, dynamic> _originalData;
  @override
  @JsonKey()
  Map<String, dynamic> get originalData {
    if (_originalData is EqualUnmodifiableMapView) return _originalData;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_originalData);
  }

  @override
  String toString() {
    return 'UnifiedPostModel(id: $id, source: $source, previewImageUrl: $previewImageUrl, fullImageUrl: $fullImageUrl, width: $width, height: $height, mediaType: $mediaType, tags: $tags, author: $author, score: $score, detailsUrl: $detailsUrl, originalData: $originalData)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UnifiedPostModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.previewImageUrl, previewImageUrl) ||
                other.previewImageUrl == previewImageUrl) &&
            (identical(other.fullImageUrl, fullImageUrl) ||
                other.fullImageUrl == fullImageUrl) &&
            (identical(other.width, width) || other.width == width) &&
            (identical(other.height, height) || other.height == height) &&
            (identical(other.mediaType, mediaType) ||
                other.mediaType == mediaType) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.author, author) || other.author == author) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.detailsUrl, detailsUrl) ||
                other.detailsUrl == detailsUrl) &&
            const DeepCollectionEquality().equals(
              other._originalData,
              _originalData,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    source,
    previewImageUrl,
    fullImageUrl,
    width,
    height,
    mediaType,
    const DeepCollectionEquality().hash(_tags),
    author,
    score,
    detailsUrl,
    const DeepCollectionEquality().hash(_originalData),
  );

  /// Create a copy of UnifiedPostModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UnifiedPostModelImplCopyWith<_$UnifiedPostModelImpl> get copyWith =>
      __$$UnifiedPostModelImplCopyWithImpl<_$UnifiedPostModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$UnifiedPostModelImplToJson(this);
  }
}

abstract class _UnifiedPostModel implements UnifiedPostModel {
  const factory _UnifiedPostModel({
    required final String id,
    required final String source,
    required final String previewImageUrl,
    required final String fullImageUrl,
    required final int width,
    required final int height,
    required final MediaType mediaType,
    final List<String> tags,
    final String? author,
    final int? score,
    final String? detailsUrl,
    final Map<String, dynamic> originalData,
  }) = _$UnifiedPostModelImpl;

  factory _UnifiedPostModel.fromJson(Map<String, dynamic> json) =
      _$UnifiedPostModelImpl.fromJson;

  // --- Core identity information ---
  // --- 核心身份信息 ---
  @override
  String get id;
  @override
  String get source; // --- Core media information ---
  // --- 核心媒体信息 ---
  @override
  String get previewImageUrl;
  @override
  String get fullImageUrl;
  @override
  int get width;
  @override
  int get height;
  @override
  MediaType get mediaType; // --- Additional information ---
  // --- 附加信息 ---
  @override
  List<String> get tags;
  @override
  String? get author;
  @override
  int? get score; // --- Metadata ---
  // --- 元数据 ---
  @override
  String? get detailsUrl;
  @override
  Map<String, dynamic> get originalData;

  /// Create a copy of UnifiedPostModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UnifiedPostModelImplCopyWith<_$UnifiedPostModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
