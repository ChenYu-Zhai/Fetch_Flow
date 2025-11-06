// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'unified_gallery_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$GalleryState {
  List<UnifiedPostModel> get posts => throw _privateConstructorUsedError;
  Object? get nextToken => throw _privateConstructorUsedError;
  bool get hasMore => throw _privateConstructorUsedError;
  Map<String, dynamic> get filters => throw _privateConstructorUsedError;
  bool get isLoadingNextPage => throw _privateConstructorUsedError;

  /// Create a copy of GalleryState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GalleryStateCopyWith<GalleryState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GalleryStateCopyWith<$Res> {
  factory $GalleryStateCopyWith(
    GalleryState value,
    $Res Function(GalleryState) then,
  ) = _$GalleryStateCopyWithImpl<$Res, GalleryState>;
  @useResult
  $Res call({
    List<UnifiedPostModel> posts,
    Object? nextToken,
    bool hasMore,
    Map<String, dynamic> filters,
    bool isLoadingNextPage,
  });
}

/// @nodoc
class _$GalleryStateCopyWithImpl<$Res, $Val extends GalleryState>
    implements $GalleryStateCopyWith<$Res> {
  _$GalleryStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GalleryState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? posts = null,
    Object? nextToken = freezed,
    Object? hasMore = null,
    Object? filters = null,
    Object? isLoadingNextPage = null,
  }) {
    return _then(
      _value.copyWith(
            posts: null == posts
                ? _value.posts
                : posts // ignore: cast_nullable_to_non_nullable
                      as List<UnifiedPostModel>,
            nextToken: freezed == nextToken ? _value.nextToken : nextToken,
            hasMore: null == hasMore
                ? _value.hasMore
                : hasMore // ignore: cast_nullable_to_non_nullable
                      as bool,
            filters: null == filters
                ? _value.filters
                : filters // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
            isLoadingNextPage: null == isLoadingNextPage
                ? _value.isLoadingNextPage
                : isLoadingNextPage // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GalleryStateImplCopyWith<$Res>
    implements $GalleryStateCopyWith<$Res> {
  factory _$$GalleryStateImplCopyWith(
    _$GalleryStateImpl value,
    $Res Function(_$GalleryStateImpl) then,
  ) = __$$GalleryStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<UnifiedPostModel> posts,
    Object? nextToken,
    bool hasMore,
    Map<String, dynamic> filters,
    bool isLoadingNextPage,
  });
}

/// @nodoc
class __$$GalleryStateImplCopyWithImpl<$Res>
    extends _$GalleryStateCopyWithImpl<$Res, _$GalleryStateImpl>
    implements _$$GalleryStateImplCopyWith<$Res> {
  __$$GalleryStateImplCopyWithImpl(
    _$GalleryStateImpl _value,
    $Res Function(_$GalleryStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GalleryState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? posts = null,
    Object? nextToken = freezed,
    Object? hasMore = null,
    Object? filters = null,
    Object? isLoadingNextPage = null,
  }) {
    return _then(
      _$GalleryStateImpl(
        posts: null == posts
            ? _value._posts
            : posts // ignore: cast_nullable_to_non_nullable
                  as List<UnifiedPostModel>,
        nextToken: freezed == nextToken ? _value.nextToken : nextToken,
        hasMore: null == hasMore
            ? _value.hasMore
            : hasMore // ignore: cast_nullable_to_non_nullable
                  as bool,
        filters: null == filters
            ? _value._filters
            : filters // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        isLoadingNextPage: null == isLoadingNextPage
            ? _value.isLoadingNextPage
            : isLoadingNextPage // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$GalleryStateImpl with DiagnosticableTreeMixin implements _GalleryState {
  const _$GalleryStateImpl({
    final List<UnifiedPostModel> posts = const [],
    this.nextToken,
    this.hasMore = true,
    final Map<String, dynamic> filters = const {},
    this.isLoadingNextPage = false,
  }) : _posts = posts,
       _filters = filters;

  final List<UnifiedPostModel> _posts;
  @override
  @JsonKey()
  List<UnifiedPostModel> get posts {
    if (_posts is EqualUnmodifiableListView) return _posts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_posts);
  }

  @override
  final Object? nextToken;
  @override
  @JsonKey()
  final bool hasMore;
  final Map<String, dynamic> _filters;
  @override
  @JsonKey()
  Map<String, dynamic> get filters {
    if (_filters is EqualUnmodifiableMapView) return _filters;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_filters);
  }

  @override
  @JsonKey()
  final bool isLoadingNextPage;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'GalleryState(posts: $posts, nextToken: $nextToken, hasMore: $hasMore, filters: $filters, isLoadingNextPage: $isLoadingNextPage)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'GalleryState'))
      ..add(DiagnosticsProperty('posts', posts))
      ..add(DiagnosticsProperty('nextToken', nextToken))
      ..add(DiagnosticsProperty('hasMore', hasMore))
      ..add(DiagnosticsProperty('filters', filters))
      ..add(DiagnosticsProperty('isLoadingNextPage', isLoadingNextPage));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GalleryStateImpl &&
            const DeepCollectionEquality().equals(other._posts, _posts) &&
            const DeepCollectionEquality().equals(other.nextToken, nextToken) &&
            (identical(other.hasMore, hasMore) || other.hasMore == hasMore) &&
            const DeepCollectionEquality().equals(other._filters, _filters) &&
            (identical(other.isLoadingNextPage, isLoadingNextPage) ||
                other.isLoadingNextPage == isLoadingNextPage));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_posts),
    const DeepCollectionEquality().hash(nextToken),
    hasMore,
    const DeepCollectionEquality().hash(_filters),
    isLoadingNextPage,
  );

  /// Create a copy of GalleryState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GalleryStateImplCopyWith<_$GalleryStateImpl> get copyWith =>
      __$$GalleryStateImplCopyWithImpl<_$GalleryStateImpl>(this, _$identity);
}

abstract class _GalleryState implements GalleryState {
  const factory _GalleryState({
    final List<UnifiedPostModel> posts,
    final Object? nextToken,
    final bool hasMore,
    final Map<String, dynamic> filters,
    final bool isLoadingNextPage,
  }) = _$GalleryStateImpl;

  @override
  List<UnifiedPostModel> get posts;
  @override
  Object? get nextToken;
  @override
  bool get hasMore;
  @override
  Map<String, dynamic> get filters;
  @override
  bool get isLoadingNextPage;

  /// Create a copy of GalleryState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GalleryStateImplCopyWith<_$GalleryStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
