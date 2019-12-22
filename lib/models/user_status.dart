import 'package:json_annotation/json_annotation.dart';

part 'user_status.g.dart';

@JsonSerializable()
class UserStatus {
  final int STATUS_CODE_OK = 0;
  final int STATUS_CODE_NOT_LOGGED_IN = 1;
  @JsonKey(name: "code")
  final int code;
  @JsonKey(name: "short_text")
  final String shortMessage;
  @JsonKey(name: "long_text")
  final String longMessage;

  UserStatus(this.code, this.shortMessage, this.longMessage);

  @JsonKey(ignore: true)
  bool isLoggedIn() {
    return this.code == 0;
  }

  factory UserStatus.fromJson(Map<String, dynamic> json) =>
      _$UserStatusFromJson(json);

  Map<String, dynamic> toJson() => _$UserStatusToJson(this);
}
