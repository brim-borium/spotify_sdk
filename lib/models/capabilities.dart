import 'package:json_annotation/json_annotation.dart';

part 'capabilities.g.dart';

@JsonSerializable()
class Capabilities {
  @JsonKey(name: "can_play_on_demand")
  final bool canPlayOnDemand;

  Capabilities(this.canPlayOnDemand);

  factory Capabilities.fromJson(Map<String, dynamic> json) =>
      _$CapabilitiesFromJson(json);

  Map<String, dynamic> toJson() => _$CapabilitiesToJson(this);
}
