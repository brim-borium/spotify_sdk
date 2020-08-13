import 'package:json_annotation/json_annotation.dart';

part 'user_status.g.dart';

@JsonSerializable()
class UserStatus {
  UserStatus(this.code, this.shortMessage, this.longMessage);

  final int statusCodeOk = 0;
  final int statusCodeNotLoggedIn = 1;
  @JsonKey(name: 'code')
  final int code;
  @JsonKey(name: 'short_text')
  final String shortMessage;
  @JsonKey(name: 'long_text')
  final String longMessage;

  @JsonKey(ignore: true)
  bool isLoggedIn() {
    return code == 0;
  }

  factory UserStatus.fromJson(Map<String, dynamic> json) =>
      _$UserStatusFromJson(json);

  Map<String, dynamic> toJson() => _$UserStatusToJson(this);
}
