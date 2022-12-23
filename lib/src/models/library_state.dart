import 'package:json_annotation/json_annotation.dart';

part 'library_state.g.dart';

@JsonSerializable()
class LibraryState {
  LibraryState(
    this.uri, {
    required this.isSaved,
    required this.canSave,
  });

  @JsonKey(name: 'uri')
  final String uri;
  @JsonKey(name: 'saved')
  final bool isSaved;
  @JsonKey(name: 'can_save')
  final bool canSave;

  factory LibraryState.fromJson(Map<String, dynamic> json) =>
      _$LibraryStateFromJson(json);

  Map<String, dynamic> toJson() => _$LibraryStateToJson(this);
}
