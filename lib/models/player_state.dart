import 'player_options.dart';
import 'player_restrictions.dart';
import 'track.dart';

class PlayerState {
  final Track track;
  final bool isPaused;
  final double playbackSpeed;
  final int playbackPosition;
  final PlayerOptions playbackOptions;
  final PlayerRestrictions playbackRestrictions;

  PlayerState(this.track, this.isPaused, this.playbackSpeed,
      this.playbackPosition, this.playbackOptions, this.playbackRestrictions);

  PlayerState.fromJson(Map<String, dynamic> json)
      : track = Track.fromJson(json["track"]),
        isPaused = json["isPaused"],
        playbackSpeed = json["playbackSpeed"],
        playbackPosition = json["playbackPosition"],
        playbackOptions = PlayerOptions.fromJson(json["playbackOptions"]),
        playbackRestrictions =
            PlayerRestrictions.fromJson(json["playbackRestrictions"]);

  Map<String, dynamic> toJson() => {
        'track': track,
        'isPaused': isPaused,
        'playbackSpeed': playbackSpeed,
        'playbackPosition': playbackPosition,
        'playbackOptions': playbackOptions,
        'playbackRestrictions': playbackRestrictions,
      };
}
