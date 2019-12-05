import 'package:json_annotation/json_annotation.dart';
part 'artist.g.dart';

@JsonSerializable()
class Artist {
  final String name;
  final String uri;

  Artist(this.name, this.uri);

  factory Artist.fromJson(Map<String, dynamic> json) => _$ArtistFromJson(json);

  Map<String, dynamic> toJson() => _$ArtistToJson(this);
}
