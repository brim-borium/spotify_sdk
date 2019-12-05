// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_restrictions.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlayerRestrictions _$PlayerRestrictionsFromJson(Map<String, dynamic> json) {
  return PlayerRestrictions(
    json['can_skip_next'] as bool,
    json['can_skip_prev'] as bool,
    json['can_repeat_track'] as bool,
    json['can_repeat_context'] as bool,
    json['can_toggle_shuffle'] as bool,
    json['can_seek'] as bool,
  );
}

Map<String, dynamic> _$PlayerRestrictionsToJson(PlayerRestrictions instance) =>
    <String, dynamic>{
      'can_skip_next': instance.canSkipNext,
      'can_skip_prev': instance.canSkipPrevious,
      'can_repeat_track': instance.canRepeatTrack,
      'can_repeat_context': instance.canRepeatContext,
      'can_toggle_shuffle': instance.canToggleShuffle,
      'can_seek': instance.canSeek,
    };
