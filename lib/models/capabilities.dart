import 'package:json_annotation/json_annotation.dart';

part 'capabilities.g.dart';

/// The capabilities of a Spotify user.
@JsonSerializable()
class Capabilities {
  /// Constructor for [Capabilities].
  Capabilities({
    required this.canPlayOnDemand,
  });

  /// Converts a [Map<String, dynamic>] to a [Capabilities].
  factory Capabilities.fromJson(Map<String, dynamic> json) =>
      _$CapabilitiesFromJson(json);

  /// Whether the user can play tracks on demand.
  @JsonKey(name: 'can_play_on_demand')
  final bool canPlayOnDemand;

  /// Converts a [Capabilities] to a [Map<String, dynamic>].
  Map<String, dynamic> toJson() => _$CapabilitiesToJson(this);
}
