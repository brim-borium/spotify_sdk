import 'package:json_annotation/json_annotation.dart';

part 'player_context.g.dart';

/// The context of the Spotify player.
@JsonSerializable()
class PlayerContext {
  /// Constructor for [PlayerContext].
  PlayerContext(this.title, this.subtitle, this.type, this.uri);

  /// Converts a [Map<String, dynamic>] to a [PlayerContext].
  factory PlayerContext.fromJson(Map<String, dynamic> json) =>
      _$PlayerContextFromJson(json);

  /// The title of the context.
  final String title;

  /// The subtitle of the context.
  final String subtitle;

  /// The type of the context.
  final String type;

  /// The URI of the context.
  final String uri;

  /// Converts a [PlayerContext] to a [Map<String, dynamic>].
  Map<String, dynamic> toJson() => _$PlayerContextToJson(this);
}
