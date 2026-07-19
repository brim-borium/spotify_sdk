import 'package:json_annotation/json_annotation.dart';

/// Holds the values from the spotify api for RepeatModes
enum SpotifyRepeatMode {
  /// repeat is off
  @JsonValue(0)
  off,

  /// repeats the current track
  @JsonValue(1)
  track,

  /// repeats the current context
  @JsonValue(2)
  context,
}
