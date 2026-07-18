import 'package:json_annotation/json_annotation.dart';

part 'library_state.g.dart';

/// The library state of a Spotify item.
@JsonSerializable()
class LibraryState {
  /// Constructor for [LibraryState].
  LibraryState(
    this.uri, {
    required this.isSaved,
    required this.canSave,
  });

  /// Converts a [Map<String, dynamic>] to a [LibraryState].
  factory LibraryState.fromJson(Map<String, dynamic> json) =>
      _$LibraryStateFromJson(json);

  /// The URI of the item.
  @JsonKey(name: 'uri')
  final String uri;

  /// Whether the item is saved in the library.
  @JsonKey(name: 'saved')
  final bool isSaved;

  /// Whether the user can save the item.
  @JsonKey(name: 'can_save')
  final bool canSave;

  /// Converts a [LibraryState] to a [Map<String, dynamic>].
  Map<String, dynamic> toJson() => _$LibraryStateToJson(this);
}
