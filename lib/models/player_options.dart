import 'package:json_annotation/json_annotation.dart';
import 'package:spotify_sdk/enums/repeat_mode_enum.dart';

part 'player_options.g.dart';

/// The playback options of the Spotify player.
@JsonSerializable()
class PlayerOptions {
  /// Constructor for [PlayerOptions].
  PlayerOptions(
    this.repeatMode, {
    required this.isShuffling,
  });

  /// Converts a [Map<String, dynamic>] to a [PlayerOptions].
  factory PlayerOptions.fromJson(Map<String, dynamic> json) =>
      _$PlayerOptionsFromJson(json);

  /// Whether shuffle is enabled.
  @JsonKey(name: 'shuffle')
  final bool isShuffling;

  /// The current repeat mode.
  @JsonKey(name: 'repeat')
  final SpotifyRepeatMode repeatMode;

  /// Converts a [PlayerOptions] to a [Map<String, dynamic>].
  Map<String, dynamic> toJson() => _$PlayerOptionsToJson(this);
}
