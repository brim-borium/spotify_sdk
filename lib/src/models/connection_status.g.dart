// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connection_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConnectionStatus _$ConnectionStatusFromJson(Map<String, dynamic> json) =>
    ConnectionStatus(
      json['message'] as String?,
      json['errorCode'] as String?,
      json['errorDetails'] as String?,
      connected: json['connected'] as bool,
    );

Map<String, dynamic> _$ConnectionStatusToJson(ConnectionStatus instance) =>
    <String, dynamic>{
      'connected': instance.connected,
      'message': instance.message,
      'errorCode': instance.errorCode,
      'errorDetails': instance.errorDetails,
    };
