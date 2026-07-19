import 'package:json_annotation/json_annotation.dart';
import 'package:spotify_sdk_platform_interface/models/player_options.dart';
import 'package:spotify_sdk_platform_interface/models/player_restrictions.dart';
import 'package:spotify_sdk_platform_interface/models/track.dart';

part 'player_state.g.dart';

/// The state of the Spotify player.
@JsonSerializable()
class PlayerState {
  /// Constructor for [PlayerState].
  PlayerState(
    this.track,
    this.playbackSpeed,
    this.playbackPosition,
    this.playbackOptions,
    this.playbackRestrictions, {
    required this.isPaused,
  });

  /// Converts a [Map<String, dynamic>] to a [PlayerState].
  factory PlayerState.fromJson(Map<String, dynamic> json) =>
      _$PlayerStateFromJson(json);

  /// The currently playing track.
  final Track? track;

  /// Whether the player is paused.
  @JsonKey(name: 'is_paused')
  final bool isPaused;

  /// The current playback speed.
  @JsonKey(name: 'playback_speed')
  final double playbackSpeed;

  /// The current playback position in milliseconds.
  @JsonKey(name: 'playback_position')
  final int playbackPosition;

  /// The current playback options.
  @JsonKey(name: 'playback_options')
  final PlayerOptions playbackOptions;

  /// The current playback restrictions.
  @JsonKey(name: 'playback_restrictions')
  final PlayerRestrictions playbackRestrictions;

  /// Converts a [PlayerState] to a [Map<String, dynamic>].
  Map<String, dynamic> toJson() => _$PlayerStateToJson(this);
}
