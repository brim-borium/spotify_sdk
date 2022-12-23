import 'package:json_annotation/json_annotation.dart';

part 'player_restrictions.g.dart';

@JsonSerializable()
class PlayerRestrictions {
  PlayerRestrictions({
    required this.canSkipNext,
    required this.canSkipPrevious,
    required this.canRepeatTrack,
    required this.canRepeatContext,
    required this.canToggleShuffle,
    required this.canSeek,
  });

  @JsonKey(name: 'can_skip_next')
  final bool canSkipNext;
  @JsonKey(name: 'can_skip_prev')
  final bool canSkipPrevious;
  @JsonKey(name: 'can_repeat_track')
  final bool canRepeatTrack;
  @JsonKey(name: 'can_repeat_context')
  final bool canRepeatContext;
  @JsonKey(name: 'can_toggle_shuffle')
  final bool canToggleShuffle;
  @JsonKey(name: 'can_seek')
  final bool canSeek;

  factory PlayerRestrictions.fromJson(Map<String, dynamic> json) =>
      _$PlayerRestrictionsFromJson(json);

  Map<String, dynamic> toJson() => _$PlayerRestrictionsToJson(this);
}
