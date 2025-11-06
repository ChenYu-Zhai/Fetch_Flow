// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unified_post_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UnifiedPostModelImpl _$$UnifiedPostModelImplFromJson(
  Map<String, dynamic> json,
) => _$UnifiedPostModelImpl(
  id: json['id'] as String,
  source: json['source'] as String,
  previewImageUrl: json['previewImageUrl'] as String,
  fullImageUrl: json['fullImageUrl'] as String,
  width: (json['width'] as num).toInt(),
  height: (json['height'] as num).toInt(),
  mediaType: $enumDecode(_$MediaTypeEnumMap, json['mediaType']),
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  author: json['author'] as String?,
  score: (json['score'] as num?)?.toInt(),
  detailsUrl: json['detailsUrl'] as String?,
  originalData: json['originalData'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$$UnifiedPostModelImplToJson(
  _$UnifiedPostModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'source': instance.source,
  'previewImageUrl': instance.previewImageUrl,
  'fullImageUrl': instance.fullImageUrl,
  'width': instance.width,
  'height': instance.height,
  'mediaType': _$MediaTypeEnumMap[instance.mediaType]!,
  'tags': instance.tags,
  'author': instance.author,
  'score': instance.score,
  'detailsUrl': instance.detailsUrl,
  'originalData': instance.originalData,
};

const _$MediaTypeEnumMap = {
  MediaType.image: 'image',
  MediaType.video: 'video',
  MediaType.gif: 'gif',
};
