import 'package:json_annotation/json_annotation.dart';

part 'player_restrictions.g.dart';

@JsonSerializable()
class PlayerRestrictions {
  final bool canSkipNext;
  final bool canSkipPrevious;
  final bool canRepeatTrack;
  final bool canRepeatContext;
  final bool canToggleShuffle;
  final bool canSeek;

  PlayerRestrictions(
      this.canSkipNext,
      this.canSkipPrevious,
      this.canRepeatTrack,
      this.canRepeatContext,
      this.canToggleShuffle,
      this.canSeek);

  factory PlayerRestrictions.fromJson(Map<String, dynamic> json) =>
      _$PlayerRestrictionsFromJson(json);

  Map<String, dynamic> toJson() => _$PlayerRestrictionsToJson(this);
}
