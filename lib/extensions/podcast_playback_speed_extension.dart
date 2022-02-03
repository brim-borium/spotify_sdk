import 'package:spotify_sdk/enums/podcast_playback_speed.dart';

///Extension for formatting the PodcastPlaybackSpeed enum to value
///@nodoc
extension PodcastPlaybackSpeedExtension on PodcastPlaybackSpeed {
  ///maps the value to the specified enum
  ///@nodoc
  static const values = {
    PodcastPlaybackSpeed.playbackSpeed_50: 50,
    PodcastPlaybackSpeed.playbackSpeed_80: 80,
    PodcastPlaybackSpeed.playbackSpeed_100: 100,
    PodcastPlaybackSpeed.playbackSpeed_120: 120,
    PodcastPlaybackSpeed.playbackSpeed_150: 150,
    PodcastPlaybackSpeed.playbackSpeed_200: 200,
    PodcastPlaybackSpeed.playbackSpeed_300: 300,
  };

  /// returns the value
  ///@nodoc
  int get value => values[this]!;
}
