import 'package:json_annotation/json_annotation.dart';

part 'connection_status.g.dart';

@JsonSerializable()
class ConnectionStatus {
  @JsonKey(name: "connected")
  final bool connected;
  @JsonKey(name: "message")
  final String message;
  @JsonKey(name: "errorCode")
  final String errorCode;
  @JsonKey(name: "errorDetails")
  final String errorDetails;

  ConnectionStatus(
      this.connected, this.message, this.errorCode, this.errorDetails);

  @JsonKey(ignore: true)
  bool hasError() {
    return this.errorCode?.isNotEmpty == true;
  }

  factory ConnectionStatus.fromJson(Map<String, dynamic> json) =>
      _$ConnectionStatusFromJson(json);
  Map<String, dynamic> toJson() => _$ConnectionStatusToJson(this);
}
