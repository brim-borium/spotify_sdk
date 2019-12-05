import 'package:json_annotation/json_annotation.dart';

part 'player_options.g.dart';

@JsonSerializable()
class PlayerOptions {
  final bool isShuffling;
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
