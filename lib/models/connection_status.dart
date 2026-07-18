import 'package:json_annotation/json_annotation.dart';

part 'connection_status.g.dart';

/// The connection status of the Spotify SDK.
@JsonSerializable()
class ConnectionStatus {
  /// Constructor for [ConnectionStatus].
  ConnectionStatus(
    this.message,
    this.errorCode,
    this.errorDetails, {
    required this.connected,
  });

  /// Converts a [Map<String, dynamic>] to a [ConnectionStatus].
  factory ConnectionStatus.fromJson(Map<String, dynamic> json) =>
      _$ConnectionStatusFromJson(json);

  /// Whether the SDK is connected.
  @JsonKey(name: 'connected')
  final bool connected;

  /// The status message.
  @JsonKey(name: 'message')
  final String? message;

  /// The error code, if any.
  @JsonKey(name: 'errorCode')
  final String? errorCode;

  /// The error details, if any.
  @JsonKey(name: 'errorDetails')
  final String? errorDetails;

  /// Returns whether the status represents an error.
  bool hasError() {
    return errorCode?.isNotEmpty ?? false;
  }

  /// Converts a [ConnectionStatus] to a [Map<String, dynamic>].
  Map<String, dynamic> toJson() => _$ConnectionStatusToJson(this);
}
