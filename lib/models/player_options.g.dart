// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_options.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlayerOptions _$PlayerOptionsFromJson(Map<String, dynamic> json) =>
    PlayerOptions(
      $enumDecode(_$SpotifyRepeatModeEnumMap, json['repeat']),
      isShuffling: json['shuffle'] as bool,
    );

Map<String, dynamic> _$PlayerOptionsToJson(PlayerOptions instance) =>
    <String, dynamic>{
      'shuffle': instance.isShuffling,
      'repeat': _$SpotifyRepeatModeEnumMap[instance.repeatMode]!,
    };

const _$SpotifyRepeatModeEnumMap = {
  SpotifyRepeatMode.off: 0,
  SpotifyRepeatMode.track: 1,
  SpotifyRepeatMode.context: 2,
};
