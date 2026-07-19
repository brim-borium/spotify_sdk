import 'package:json_annotation/json_annotation.dart';

part 'player_restrictions.g.dart';

/// The playback restrictions of the Spotify player.
@JsonSerializable()
class PlayerRestrictions {
  /// Constructor for [PlayerRestrictions].
  PlayerRestrictions({
    required this.canSkipNext,
    required this.canSkipPrevious,
    required this.canRepeatTrack,
    required this.canRepeatContext,
    required this.canToggleShuffle,
    required this.canSeek,
  });

  /// Converts a [Map<String, dynamic>] to a [PlayerRestrictions].
  factory PlayerRestrictions.fromJson(Map<String, dynamic> json) =>
      _$PlayerRestrictionsFromJson(json);

  /// Whether skipping to the next track is allowed.
  @JsonKey(name: 'can_skip_next')
  final bool canSkipNext;

  /// Whether skipping to the previous track is allowed.
  @JsonKey(name: 'can_skip_prev')
  final bool canSkipPrevious;

  /// Whether repeating the current track is allowed.
  @JsonKey(name: 'can_repeat_track')
  final bool canRepeatTrack;

  /// Whether repeating the current context is allowed.
  @JsonKey(name: 'can_repeat_context')
  final bool canRepeatContext;

  /// Whether toggling shuffle is allowed.
  @JsonKey(name: 'can_toggle_shuffle')
  final bool canToggleShuffle;

  /// Whether seeking is allowed.
  @JsonKey(name: 'can_seek')
  final bool canSeek;

  /// Converts a [PlayerRestrictions] to a [Map<String, dynamic>].
  Map<String, dynamic> toJson() => _$PlayerRestrictionsToJson(this);
}
