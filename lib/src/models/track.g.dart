// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'track.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Track _$TrackFromJson(Map<String, dynamic> json) => Track(
      Album.fromJson(json['album'] as Map<String, dynamic>),
      Artist.fromJson(json['artist'] as Map<String, dynamic>),
      (json['artists'] as List<dynamic>)
          .map((e) => Artist.fromJson(e as Map<String, dynamic>))
          .toList(),
      json['duration_ms'] as int,
      ImageUri.fromJson(json['image_id'] as Map<String, dynamic>),
      json['name'] as String,
      json['uri'] as String,
      json['linked_from_uri'] as String?,
      isEpisode: json['is_episode'] as bool,
      isPodcast: json['is_podcast'] as bool,
    );

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
      'linked_from_uri': instance.linkedFromUri,
    };
