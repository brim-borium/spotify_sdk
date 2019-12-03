class PlayerRestrictions {
  final bool canSkipNext;
  final bool canSkipPrevious;
  final bool canRepeatTrack;
  final bool canRepeatContext;
  final bool canToggleShuffle;
  final bool canSeek;

  PlayerRestrictions(
      this.canSkipNext,
      this.canSkipPrevious,
      this.canRepeatTrack,
      this.canRepeatContext,
      this.canToggleShuffle,
      this.canSeek);

  PlayerRestrictions.fromJson(Map<String, dynamic> json)
      : canSkipNext = json["canSkipNext"],
        canSkipPrevious = json["canSkipPrevious"],
        canRepeatTrack = json["canRepeatTrack"],
        canRepeatContext = json["canRepeatContext"],
        canToggleShuffle = json["canToggleShuffle"],
        canSeek = json["canSeek"];

  Map<String, dynamic> toJson() => {
        'canSkipNext': canSkipNext,
        'canSkipPrevious': canSkipPrevious,
        'canRepeatTrack': canRepeatTrack,
        'canRepeatContext': canRepeatContext,
        'canToggleShuffle': canToggleShuffle,
        'canSeek': canSeek,
      };
}
