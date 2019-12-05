import 'package:json_annotation/json_annotation.dart';

part 'image_uri.g.dart';

@JsonSerializable()
class ImageUri {
  final String raw;

  ImageUri(this.raw);

  factory ImageUri.fromJson(Map<String, dynamic> json) =>
      _$ImageUriFromJson(json);

  Map<String, dynamic> toJson() => _$ImageUriToJson(this);
}
