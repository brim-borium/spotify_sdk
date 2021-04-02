import 'package:json_annotation/json_annotation.dart';

part 'crossfade_state.g.dart';

@JsonSerializable()
class CrossfadeState {
  CrossfadeState(
    this.duration, {
    required this.isEnabled,
  });

  final bool isEnabled;
  final int duration;

  factory CrossfadeState.fromJson(Map<String, dynamic> json) =>
      _$CrossfadeStateFromJson(json);

  Map<String, dynamic> toJson() => _$CrossfadeStateToJson(this);
}
