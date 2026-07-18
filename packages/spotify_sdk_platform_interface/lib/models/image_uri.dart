import 'package:json_annotation/json_annotation.dart';

part 'image_uri.g.dart';

/// A URI for an image in the Spotify library.
@JsonSerializable()
class ImageUri {
  /// Constructor for [ImageUri].
  ImageUri(this.raw);

  /// Converts a [Map<String, dynamic>] to an [ImageUri].
  factory ImageUri.fromJson(Map<String, dynamic> json) =>
      _$ImageUriFromJson(json);

  /// The raw URI string.
  final String raw;

  /// Converts an [ImageUri] to a [Map<String, dynamic>].
  Map<String, dynamic> toJson() => _$ImageUriToJson(this);
}
