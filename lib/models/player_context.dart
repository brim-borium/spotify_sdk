import 'package:json_annotation/json_annotation.dart';

part 'player_context.g.dart';

@JsonSerializable()
class PlayerContext {
  final String subtitle;
  final String title;
  final String type;
  final String uri;

  PlayerContext(this.subtitle, this.title, this.type, this.uri);

  factory PlayerContext.fromJson(Map<String, dynamic> json) =>
      _$PlayerContextFromJson(json);

  Map<String, dynamic> toJson() => _$PlayerContextToJson(this);
}
