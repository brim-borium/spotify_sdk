// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_options.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlayerOptions _$PlayerOptionsFromJson(Map<String, dynamic> json) {
  return PlayerOptions(
    _$enumDecode(_$RepeatModeEnumMap, json['repeat']),
    isShuffling: json['shuffle'] as bool,
  );
}

Map<String, dynamic> _$PlayerOptionsToJson(PlayerOptions instance) =>
    <String, dynamic>{
      'shuffle': instance.isShuffling,
      'repeat': _$RepeatModeEnumMap[instance.repeatMode],
    };

K _$enumDecode<K, V>(
  Map<K, V> enumValues,
  Object? source, {
  K? unknownValue,
}) {
  if (source == null) {
    throw ArgumentError(
      'A value must be provided. Supported values: '
      '${enumValues.values.join(', ')}',
    );
  }

  return enumValues.entries.singleWhere(
    (e) => e.value == source,
    orElse: () {
      if (unknownValue == null) {
        throw ArgumentError(
          '`$source` is not one of the supported values: '
          '${enumValues.values.join(', ')}',
        );
      }
      return MapEntry(unknownValue, enumValues.values.first);
    },
  ).key;
}

const _$RepeatModeEnumMap = {
  RepeatMode.off: 0,
  RepeatMode.track: 1,
  RepeatMode.context: 2,
};
