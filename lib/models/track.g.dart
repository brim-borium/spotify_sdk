// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'track.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Track _$TrackFromJson(Map<String, dynamic> json) {
  return Track(
    json['album'] == null
        ? null
        : Album.fromJson(json['album'] as Map<String, dynamic>),
    json['artist'] == null
        ? null
        : Artist.fromJson(json['artist'] as Map<String, dynamic>),
    (json['artists'] as List)
        ?.map((e) =>
            e == null ? null : Artist.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    json['duration_ms'] as int,
    json['image_id'] == null
        ? null
        : ImageUri.fromJson(json['image_id'] as Map<String, dynamic>),
    json['is_episode'] as bool,
    json['is_podcast'] as bool,
    json['name'] as String,
    json['uri'] as String,
  );
}

Map<String, dynamic> _$TrackToJson(Track instance) => <String, dynamic>{
      'album': instance.album,
      'artist': instance.artist,
      'artists': instance.artists,
      'duration_ms': instance.duration,
      'image_id': instance.imageUri,
      'is_episode': instance.isEpisode,
      'is_podcast': instance.isPodcast,
      'name': instance.name,
      'uri': instance.uri,
    };
