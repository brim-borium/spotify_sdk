// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'crossfade_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CrossfadeState _$CrossfadeStateFromJson(Map<String, dynamic> json) {
  return CrossfadeState(
    json['isEnabled'] as bool,
    json['duration'] as int,
  );
}

Map<String, dynamic> _$CrossfadeStateToJson(CrossfadeState instance) =>
    <String, dynamic>{
      'isEnabled': instance.isEnabled,
      'duration': instance.duration,
    };
