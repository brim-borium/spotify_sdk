import 'package:json_annotation/json_annotation.dart';
import 'package:spotify_sdk/models/album.dart';
import 'package:spotify_sdk/models/artist.dart';
import 'package:spotify_sdk/models/image_uri.dart';

part 'track.g.dart';

/// A track in the Spotify library.
@JsonSerializable()
class Track {
  /// Constructor for [Track].
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

  /// Converts a [Map<String, dynamic>] to a [Track].
  factory Track.fromJson(Map<String, dynamic> json) => _$TrackFromJson(json);

  /// The album this track belongs to.
  final Album album;

  /// The main artist of this track.
  final Artist artist;

  /// The list of artists of this track.
  final List<Artist> artists;

  /// The duration of the track in milliseconds.
  @JsonKey(name: 'duration_ms')
  final int duration;

  /// The URI for the track image.
  @JsonKey(name: 'image_id')
  final ImageUri imageUri;

  /// Whether the track is an episode.
  @JsonKey(name: 'is_episode')
  final bool isEpisode;

  /// Whether the track is a podcast.
  @JsonKey(name: 'is_podcast')
  final bool isPodcast;

  /// The name of the track.
  final String name;

  /// The URI of the track.
  final String uri;

  /// The URI of the track this one was linked from.
  @JsonKey(name: 'linked_from_uri')
  final String? linkedFromUri;

  /// Converts a [Track] to a [Map<String, dynamic>].
  Map<String, dynamic> toJson() => _$TrackToJson(this);
}
