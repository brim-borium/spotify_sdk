import 'package:json_annotation/json_annotation.dart';

part 'artist.g.dart';

/// An artist in the Spotify library.
@JsonSerializable()
class Artist {
  /// Constructor for [Artist].
  Artist(this.name, this.uri);

  /// Converts a [Map<String, dynamic>] to an [Artist].
  factory Artist.fromJson(Map<String, dynamic> json) => _$ArtistFromJson(json);

  /// The name of the artist.
  final String? name;

  /// The URI of the artist.
  final String? uri;

  /// Converts an [Artist] to a [Map<String, dynamic>].
  Map<String, dynamic> toJson() => _$ArtistToJson(this);
}
