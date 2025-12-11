// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'civitai_image_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ImageStatsImpl _$$ImageStatsImplFromJson(Map<String, dynamic> json) =>
    _$ImageStatsImpl(likeCount: (json['likeCount'] as num?)?.toInt() ?? 0);

Map<String, dynamic> _$$ImageStatsImplToJson(_$ImageStatsImpl instance) =>
    <String, dynamic>{'likeCount': instance.likeCount};

_$ImageMetaImpl _$$ImageMetaImplFromJson(Map<String, dynamic> json) =>
    _$ImageMetaImpl(
      prompt: json['prompt'] as String?,
      negativePrompt: json['negativePrompt'] as String?,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const <String>[],
    );

Map<String, dynamic> _$$ImageMetaImplToJson(_$ImageMetaImpl instance) =>
    <String, dynamic>{
      'prompt': instance.prompt,
      'negativePrompt': instance.negativePrompt,
      'tags': instance.tags,
    };

_$CivitaiImageModelImpl _$$CivitaiImageModelImplFromJson(
  Map<String, dynamic> json,
) => _$CivitaiImageModelImpl(
  id: (json['id'] as num).toInt(),
  url: json['url'] as String,
  hash: const ForceStringConverter().fromJson(json['hash']),
  width: (json['width'] as num?)?.toInt() ?? 1024,
  height: (json['height'] as num?)?.toInt() ?? 1024,
  nsfw: json['nsfw'] as bool? ?? false,
  username: const ForceStringConverter().fromJson(json['username']),
  type: $enumDecode(
    _$MediaTypeEnumMap,
    json['type'],
    unknownValue: MediaType.image,
  ),
  meta: json['meta'] == null
      ? null
      : ImageMeta.fromJson(json['meta'] as Map<String, dynamic>),
  stats: json['stats'] == null
      ? null
      : ImageStats.fromJson(json['stats'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$CivitaiImageModelImplToJson(
  _$CivitaiImageModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'url': instance.url,
  'hash': const ForceStringConverter().toJson(instance.hash),
  'width': instance.width,
  'height': instance.height,
  'nsfw': instance.nsfw,
  'username': const ForceStringConverter().toJson(instance.username),
  'type': _$MediaTypeEnumMap[instance.type]!,
  'meta': instance.meta,
  'stats': instance.stats,
};

const _$MediaTypeEnumMap = {
  MediaType.image: 'image',
  MediaType.video: 'video',
  MediaType.gif: 'gif',
};
