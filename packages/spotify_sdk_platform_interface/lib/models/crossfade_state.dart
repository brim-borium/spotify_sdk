import 'package:json_annotation/json_annotation.dart';

part 'crossfade_state.g.dart';

/// The crossfade state of the Spotify player.
@JsonSerializable()
class CrossfadeState {
  /// Constructor for [CrossfadeState].
  new(this.duration, {required this.isEnabled});

  /// Converts a [Map<String, dynamic>] to a [CrossfadeState].
  factory fromJson(Map<String, dynamic> json) => _$CrossfadeStateFromJson(json);

  /// Whether crossfade is enabled.
  final bool isEnabled;

  /// The duration of the crossfade in milliseconds.
  final int duration;

  /// Converts a [CrossfadeState] to a [Map<String, dynamic>].
  Map<String, dynamic> toJson() => _$CrossfadeStateToJson(this);
}
