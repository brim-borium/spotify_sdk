// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_options.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlayerOptions _$PlayerOptionsFromJson(Map<String, dynamic> json) {
  return PlayerOptions(
    _$enumDecodeNullable(_$RepeatModeEnumMap, json['repeat']),
    isShuffling: json['shuffle'] as bool,
  );
}

Map<String, dynamic> _$PlayerOptionsToJson(PlayerOptions instance) =>
    <String, dynamic>{
      'shuffle': instance.isShuffling,
      'repeat': _$RepeatModeEnumMap[instance.repeatMode],
    };

T _$enumDecode<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }

  final value = enumValues.entries
      .singleWhere((e) => e.value == source, orElse: () => null)
      ?.key;

  if (value == null && unknownValue == null) {
    throw ArgumentError('`$source` is not one of the supported values: '
        '${enumValues.values.join(', ')}');
  }
  return value ?? unknownValue;
}

T _$enumDecodeNullable<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<T>(enumValues, source, unknownValue: unknownValue);
}

const _$RepeatModeEnumMap = {
  RepeatMode.off: 0,
  RepeatMode.track: 1,
  RepeatMode.context: 2,
};
