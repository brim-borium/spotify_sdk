// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_restrictions.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlayerRestrictions _$PlayerRestrictionsFromJson(Map<String, dynamic> json) {
  return PlayerRestrictions(
    json['canSkipNext'] as bool,
    json['canSkipPrevious'] as bool,
    json['canRepeatTrack'] as bool,
    json['canRepeatContext'] as bool,
    json['canToggleShuffle'] as bool,
    json['canSeek'] as bool,
  );
}

Map<String, dynamic> _$PlayerRestrictionsToJson(PlayerRestrictions instance) =>
    <String, dynamic>{
      'canSkipNext': instance.canSkipNext,
      'canSkipPrevious': instance.canSkipPrevious,
      'canRepeatTrack': instance.canRepeatTrack,
      'canRepeatContext': instance.canRepeatContext,
      'canToggleShuffle': instance.canToggleShuffle,
      'canSeek': instance.canSeek,
    };
