// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'civitai_filters.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$CivitaiFilterState {
  int get limit => throw _privateConstructorUsedError;
  int? get postId => throw _privateConstructorUsedError;
  int? get modelId => throw _privateConstructorUsedError;
  int? get modelVersionId => throw _privateConstructorUsedError;
  String? get username =>
      throw _privateConstructorUsedError; // Change default value to none, more compliant with API semantics.
  // 将默认值改为 none，更符合 API 语义。
  CivitaiNsfw get nsfw => throw _privateConstructorUsedError;
  CivitaiSort get sort => throw _privateConstructorUsedError;
  CivitaiPeriod get period => throw _privateConstructorUsedError;

  /// Create a copy of CivitaiFilterState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CivitaiFilterStateCopyWith<CivitaiFilterState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CivitaiFilterStateCopyWith<$Res> {
  factory $CivitaiFilterStateCopyWith(
    CivitaiFilterState value,
    $Res Function(CivitaiFilterState) then,
  ) = _$CivitaiFilterStateCopyWithImpl<$Res, CivitaiFilterState>;
  @useResult
  $Res call({
    int limit,
    int? postId,
    int? modelId,
    int? modelVersionId,
    String? username,
    CivitaiNsfw nsfw,
    CivitaiSort sort,
    CivitaiPeriod period,
  });
}

/// @nodoc
class _$CivitaiFilterStateCopyWithImpl<$Res, $Val extends CivitaiFilterState>
    implements $CivitaiFilterStateCopyWith<$Res> {
  _$CivitaiFilterStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CivitaiFilterState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? limit = null,
    Object? postId = freezed,
    Object? modelId = freezed,
    Object? modelVersionId = freezed,
    Object? username = freezed,
    Object? nsfw = null,
    Object? sort = null,
    Object? period = null,
  }) {
    return _then(
      _value.copyWith(
            limit: null == limit
                ? _value.limit
                : limit // ignore: cast_nullable_to_non_nullable
                      as int,
            postId: freezed == postId
                ? _value.postId
                : postId // ignore: cast_nullable_to_non_nullable
                      as int?,
            modelId: freezed == modelId
                ? _value.modelId
                : modelId // ignore: cast_nullable_to_non_nullable
                      as int?,
            modelVersionId: freezed == modelVersionId
                ? _value.modelVersionId
                : modelVersionId // ignore: cast_nullable_to_non_nullable
                      as int?,
            username: freezed == username
                ? _value.username
                : username // ignore: cast_nullable_to_non_nullable
                      as String?,
            nsfw: null == nsfw
                ? _value.nsfw
                : nsfw // ignore: cast_nullable_to_non_nullable
                      as CivitaiNsfw,
            sort: null == sort
                ? _value.sort
                : sort // ignore: cast_nullable_to_non_nullable
                      as CivitaiSort,
            period: null == period
                ? _value.period
                : period // ignore: cast_nullable_to_non_nullable
                      as CivitaiPeriod,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CivitaiFilterStateImplCopyWith<$Res>
    implements $CivitaiFilterStateCopyWith<$Res> {
  factory _$$CivitaiFilterStateImplCopyWith(
    _$CivitaiFilterStateImpl value,
    $Res Function(_$CivitaiFilterStateImpl) then,
  ) = __$$CivitaiFilterStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int limit,
    int? postId,
    int? modelId,
    int? modelVersionId,
    String? username,
    CivitaiNsfw nsfw,
    CivitaiSort sort,
    CivitaiPeriod period,
  });
}

/// @nodoc
class __$$CivitaiFilterStateImplCopyWithImpl<$Res>
    extends _$CivitaiFilterStateCopyWithImpl<$Res, _$CivitaiFilterStateImpl>
    implements _$$CivitaiFilterStateImplCopyWith<$Res> {
  __$$CivitaiFilterStateImplCopyWithImpl(
    _$CivitaiFilterStateImpl _value,
    $Res Function(_$CivitaiFilterStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CivitaiFilterState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? limit = null,
    Object? postId = freezed,
    Object? modelId = freezed,
    Object? modelVersionId = freezed,
    Object? username = freezed,
    Object? nsfw = null,
    Object? sort = null,
    Object? period = null,
  }) {
    return _then(
      _$CivitaiFilterStateImpl(
        limit: null == limit
            ? _value.limit
            : limit // ignore: cast_nullable_to_non_nullable
                  as int,
        postId: freezed == postId
            ? _value.postId
            : postId // ignore: cast_nullable_to_non_nullable
                  as int?,
        modelId: freezed == modelId
            ? _value.modelId
            : modelId // ignore: cast_nullable_to_non_nullable
                  as int?,
        modelVersionId: freezed == modelVersionId
            ? _value.modelVersionId
            : modelVersionId // ignore: cast_nullable_to_non_nullable
                  as int?,
        username: freezed == username
            ? _value.username
            : username // ignore: cast_nullable_to_non_nullable
                  as String?,
        nsfw: null == nsfw
            ? _value.nsfw
            : nsfw // ignore: cast_nullable_to_non_nullable
                  as CivitaiNsfw,
        sort: null == sort
            ? _value.sort
            : sort // ignore: cast_nullable_to_non_nullable
                  as CivitaiSort,
        period: null == period
            ? _value.period
            : period // ignore: cast_nullable_to_non_nullable
                  as CivitaiPeriod,
      ),
    );
  }
}

/// @nodoc

class _$CivitaiFilterStateImpl extends _CivitaiFilterState
    with DiagnosticableTreeMixin {
  const _$CivitaiFilterStateImpl({
    this.limit = 50,
    this.postId,
    this.modelId,
    this.modelVersionId,
    this.username,
    this.nsfw = CivitaiNsfw.none,
    this.sort = CivitaiSort.newest,
    this.period = CivitaiPeriod.allTime,
  }) : super._();

  @override
  @JsonKey()
  final int limit;
  @override
  final int? postId;
  @override
  final int? modelId;
  @override
  final int? modelVersionId;
  @override
  final String? username;
  // Change default value to none, more compliant with API semantics.
  // 将默认值改为 none，更符合 API 语义。
  @override
  @JsonKey()
  final CivitaiNsfw nsfw;
  @override
  @JsonKey()
  final CivitaiSort sort;
  @override
  @JsonKey()
  final CivitaiPeriod period;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'CivitaiFilterState(limit: $limit, postId: $postId, modelId: $modelId, modelVersionId: $modelVersionId, username: $username, nsfw: $nsfw, sort: $sort, period: $period)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'CivitaiFilterState'))
      ..add(DiagnosticsProperty('limit', limit))
      ..add(DiagnosticsProperty('postId', postId))
      ..add(DiagnosticsProperty('modelId', modelId))
      ..add(DiagnosticsProperty('modelVersionId', modelVersionId))
      ..add(DiagnosticsProperty('username', username))
      ..add(DiagnosticsProperty('nsfw', nsfw))
      ..add(DiagnosticsProperty('sort', sort))
      ..add(DiagnosticsProperty('period', period));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CivitaiFilterStateImpl &&
            (identical(other.limit, limit) || other.limit == limit) &&
            (identical(other.postId, postId) || other.postId == postId) &&
            (identical(other.modelId, modelId) || other.modelId == modelId) &&
            (identical(other.modelVersionId, modelVersionId) ||
                other.modelVersionId == modelVersionId) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.nsfw, nsfw) || other.nsfw == nsfw) &&
            (identical(other.sort, sort) || other.sort == sort) &&
            (identical(other.period, period) || other.period == period));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    limit,
    postId,
    modelId,
    modelVersionId,
    username,
    nsfw,
    sort,
    period,
  );

  /// Create a copy of CivitaiFilterState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CivitaiFilterStateImplCopyWith<_$CivitaiFilterStateImpl> get copyWith =>
      __$$CivitaiFilterStateImplCopyWithImpl<_$CivitaiFilterStateImpl>(
        this,
        _$identity,
      );
}

abstract class _CivitaiFilterState extends CivitaiFilterState {
  const factory _CivitaiFilterState({
    final int limit,
    final int? postId,
    final int? modelId,
    final int? modelVersionId,
    final String? username,
    final CivitaiNsfw nsfw,
    final CivitaiSort sort,
    final CivitaiPeriod period,
  }) = _$CivitaiFilterStateImpl;
  const _CivitaiFilterState._() : super._();

  @override
  int get limit;
  @override
  int? get postId;
  @override
  int? get modelId;
  @override
  int? get modelVersionId;
  @override
  String? get username; // Change default value to none, more compliant with API semantics.
  // 将默认值改为 none，更符合 API 语义。
  @override
  CivitaiNsfw get nsfw;
  @override
  CivitaiSort get sort;
  @override
  CivitaiPeriod get period;

  /// Create a copy of CivitaiFilterState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CivitaiFilterStateImplCopyWith<_$CivitaiFilterStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
