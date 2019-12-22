// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserStatus _$UserStatusFromJson(Map<String, dynamic> json) {
  return UserStatus(
    json['code'] as int,
    json['short_text'] as String,
    json['long_text'] as String,
  );
}

Map<String, dynamic> _$UserStatusToJson(UserStatus instance) =>
    <String, dynamic>{
      'code': instance.code,
      'short_text': instance.shortMessage,
      'long_text': instance.longMessage,
    };
