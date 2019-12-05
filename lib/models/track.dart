import 'package:json_annotation/json_annotation.dart';

import 'album.dart';
import 'artist.dart';
import 'image_uri.dart';

part 'track.g.dart';

@JsonSerializable()
class Track {
  final Album album;
  final Artist artist;
  final List<Artist> artists;
  final int duration;
  final ImageUri imageUri;
  final bool isEpisode;
  final bool isPodcast;
  final String name;
  final String uri;

  Track(this.album, this.artist, this.artists, this.duration, this.imageUri,
      this.isEpisode, this.isPodcast, this.name, this.uri);

  factory Track.fromJson(Map<String, dynamic> json) => _$TrackFromJson(json);

  Map<String, dynamic> toJson() => _$TrackToJson(this);
}
