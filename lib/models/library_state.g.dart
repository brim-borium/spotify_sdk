// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'library_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LibraryState _$LibraryStateFromJson(Map<String, dynamic> json) {
  return LibraryState(
    json['uri'] as String,
    json['saved'] as bool,
    json['can_save'] as bool,
  );
}

Map<String, dynamic> _$LibraryStateToJson(LibraryState instance) =>
    <String, dynamic>{
      'uri': instance.uri,
      'saved': instance.isSaved,
      'can_save': instance.canSave,
    };
