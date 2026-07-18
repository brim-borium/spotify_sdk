import 'package:json_annotation/json_annotation.dart';

part 'user_status.g.dart';

/// The status of a Spotify user.
@JsonSerializable()
class UserStatus {
  /// Constructor for [UserStatus].
  UserStatus(this.code, this.shortMessage, this.longMessage);

  /// Converts a [Map<String, dynamic>] to a [UserStatus].
  factory UserStatus.fromJson(Map<String, dynamic> json) =>
      _$UserStatusFromJson(json);

  /// Status code for OK.
  final int statusCodeOk = 0;

  /// Status code for not logged in.
  final int statusCodeNotLoggedIn = 1;

  /// The status code.
  @JsonKey(name: 'code')
  final int code;

  /// The short status message.
  @JsonKey(name: 'short_text')
  final String shortMessage;

  /// The long status message.
  @JsonKey(name: 'long_text')
  final String longMessage;

  /// Returns whether the user is logged in.
  bool isLoggedIn() {
    return code == 0;
  }

  /// Converts a [UserStatus] to a [Map<String, dynamic>].
  Map<String, dynamic> toJson() => _$UserStatusToJson(this);
}
