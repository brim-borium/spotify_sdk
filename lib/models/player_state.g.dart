// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlayerState _$PlayerStateFromJson(Map<String, dynamic> json) {
  return PlayerState(
    json['track'] == null
        ? null
        : Track.fromJson(json['track'] as Map<String, dynamic>),
    json['isPaused'] as bool,
    (json['playbackSpeed'] as num)?.toDouble(),
    json['playbackPosition'] as int,
    json['playbackOptions'] == null
        ? null
        : PlayerOptions.fromJson(
            json['playbackOptions'] as Map<String, dynamic>),
    json['playbackRestrictions'] == null
        ? null
        : PlayerRestrictions.fromJson(
            json['playbackRestrictions'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$PlayerStateToJson(PlayerState instance) =>
    <String, dynamic>{
      'track': instance.track,
      'isPaused': instance.isPaused,
      'playbackSpeed': instance.playbackSpeed,
      'playbackPosition': instance.playbackPosition,
      'playbackOptions': instance.playbackOptions,
      'playbackRestrictions': instance.playbackRestrictions,
    };
