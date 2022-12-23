import 'package:json_annotation/json_annotation.dart';

import 'album.dart';
import 'artist.dart';
import 'image_uri.dart';

part 'track.g.dart';

@JsonSerializable()
class Track {
  Track(
    this.album,
    this.artist,
    this.artists,
    this.duration,
    this.imageUri,
    this.name,
    this.uri,
    this.linkedFromUri, {
    required this.isEpisode,
    required this.isPodcast,
  });

  final Album album;
  final Artist artist;
  final List<Artist> artists;
  @JsonKey(name: 'duration_ms')
  final int duration;
  @JsonKey(name: 'image_id')
  final ImageUri imageUri;
  @JsonKey(name: 'is_episode')
  final bool isEpisode;
  @JsonKey(name: 'is_podcast')
  final bool isPodcast;
  final String name;
  final String uri;
  @JsonKey(name: 'linked_from_uri')
  final String? linkedFromUri;

  factory Track.fromJson(Map<String, dynamic> json) => _$TrackFromJson(json);

  Map<String, dynamic> toJson() => _$TrackToJson(this);
}
