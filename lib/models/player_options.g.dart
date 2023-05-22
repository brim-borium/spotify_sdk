// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_options.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlayerOptions _$PlayerOptionsFromJson(Map<String, dynamic> json) =>
    PlayerOptions(
      $enumDecode(_$RepeatModeEnumMap, json['repeat']),
      isShuffling: json['shuffle'] as bool,
    );

Map<String, dynamic> _$PlayerOptionsToJson(PlayerOptions instance) =>
    <String, dynamic>{
      'shuffle': instance.isShuffling,
      'repeat': _$RepeatModeEnumMap[instance.repeatMode]!,
    };

const _$RepeatModeEnumMap = {
  RepeatMode.off: 0,
  RepeatMode.track: 1,
  RepeatMode.context: 2,
};
