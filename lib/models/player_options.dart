class PlayerOptions {
  final bool isShuffling;
  final RepeatMode repeatMode;

  PlayerOptions(this.isShuffling, this.repeatMode);

  PlayerOptions.fromJson(Map<String, dynamic> json)
      : isShuffling = json["isShuffling"],
        repeatMode = RepeatMode.values[json["repeatMode"]];

  Map<String, dynamic> toJson() => {
        'isShuffling': isShuffling,
        'repeatMode': repeatMode,
      };
}

enum RepeatMode { Track, Context, Off }
