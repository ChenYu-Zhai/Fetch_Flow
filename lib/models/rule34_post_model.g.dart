// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rule34_post_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$Rule34PostModelImpl _$$Rule34PostModelImplFromJson(
  Map<String, dynamic> json,
) => _$Rule34PostModelImpl(
  id: (json['id'] as num).toInt(),
  score: (json['score'] as num).toInt(),
  width: (json['width'] as num).toInt(),
  height: (json['height'] as num).toInt(),
  fileUrl: json['file_url'] as String,
  sampleUrl: json['sample_url'] as String,
  tags: json['tags'] as String,
);

Map<String, dynamic> _$$Rule34PostModelImplToJson(
  _$Rule34PostModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'score': instance.score,
  'width': instance.width,
  'height': instance.height,
  'file_url': instance.fileUrl,
  'sample_url': instance.sampleUrl,
  'tags': instance.tags,
};
