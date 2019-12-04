class CrossfadeState {
  final bool isEnabled;
  final int duration;

  CrossfadeState(this.isEnabled, this.duration);

  CrossfadeState.fromJson(Map<String, dynamic> json)
      : isEnabled = json["isEnabled"],
        duration = json["duration"];

  Map<String, dynamic> toJson() => {
        'isEnabled': isEnabled,
        'duration': duration,
      };
}
