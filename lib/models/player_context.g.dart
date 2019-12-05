// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_context.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlayerContext _$PlayerContextFromJson(Map<String, dynamic> json) {
  return PlayerContext(
    json['subtitle'] as String,
    json['title'] as String,
    json['type'] as String,
    json['uri'] as String,
  );
}

Map<String, dynamic> _$PlayerContextToJson(PlayerContext instance) =>
    <String, dynamic>{
      'subtitle': instance.subtitle,
      'title': instance.title,
      'type': instance.type,
      'uri': instance.uri,
    };
