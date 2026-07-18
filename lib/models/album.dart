import 'package:json_annotation/json_annotation.dart';

part 'album.g.dart';

/// An album in the Spotify library.
@JsonSerializable()
class Album {
  /// Constructor for [Album].
  Album(this.name, this.uri);

  /// Converts a [Map<String, dynamic>] to an [Album].
  factory Album.fromJson(Map<String, dynamic> json) => _$AlbumFromJson(json);

  /// The name of the album.
  final String? name;

  /// The URI of the album.
  final String? uri;

  /// Converts an [Album] to a [Map<String, dynamic>].
  Map<String, dynamic> toJson() => _$AlbumToJson(this);
}
