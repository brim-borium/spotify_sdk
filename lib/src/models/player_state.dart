import 'package:json_annotation/json_annotation.dart';

import 'player_options.dart';
import 'player_restrictions.dart';
import 'track.dart';

part 'player_state.g.dart';

@JsonSerializable()
class PlayerState {
  PlayerState(
    this.track,
    this.playbackSpeed,
    this.playbackPosition,
    this.playbackOptions,
    this.playbackRestrictions, {
    required this.isPaused,
  });

  final Track? track;
  @JsonKey(name: 'is_paused')
  final bool isPaused;
  @JsonKey(name: 'playback_speed')
  final double playbackSpeed;
  @JsonKey(name: 'playback_position')
  final int playbackPosition;
  @JsonKey(name: 'playback_options')
  final PlayerOptions playbackOptions;
  @JsonKey(name: 'playback_restrictions')
  final PlayerRestrictions playbackRestrictions;

  factory PlayerState.fromJson(Map<String, dynamic> json) =>
      _$PlayerStateFromJson(json);

  Map<String, dynamic> toJson() => _$PlayerStateToJson(this);
}
