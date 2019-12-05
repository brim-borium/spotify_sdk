import 'package:json_annotation/json_annotation.dart';

part 'player_options.g.dart';

@JsonSerializable()
class PlayerOptions {
  @JsonKey(name: "shuffle")
  final bool isShuffling;
  @JsonKey(name: "repeat")
  final RepeatMode repeatMode;

  PlayerOptions(this.isShuffling, this.repeatMode);

  factory PlayerOptions.fromJson(Map<String, dynamic> json) =>
      _$PlayerOptionsFromJson(json);

  Map<String, dynamic> toJson() => _$PlayerOptionsToJson(this);
}

enum RepeatMode {
  @JsonValue(0)
  Off,
  @JsonValue(1)
  Track,
  @JsonValue(2)
  Context
}
