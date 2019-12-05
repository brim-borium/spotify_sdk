import 'package:json_annotation/json_annotation.dart';

import 'player_options.dart';
import 'player_restrictions.dart';
import 'track.dart';

part 'player_state.g.dart';

@JsonSerializable()
class PlayerState {
  final Track track;
  final bool isPaused;
  final double playbackSpeed;
  final int playbackPosition;
  final PlayerOptions playbackOptions;
  final PlayerRestrictions playbackRestrictions;

  PlayerState(this.track, this.isPaused, this.playbackSpeed,
      this.playbackPosition, this.playbackOptions, this.playbackRestrictions);

  factory PlayerState.fromJson(Map<String, dynamic> json) =>
      _$PlayerStateFromJson(json);

  Map<String, dynamic> toJson() => _$PlayerStateToJson(this);
}
