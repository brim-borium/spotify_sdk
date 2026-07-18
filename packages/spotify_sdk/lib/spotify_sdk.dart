import 'dart:async';
import 'dart:typed_data';

import 'package:spotify_sdk_platform_interface/spotify_sdk_platform_interface.dart';

export 'package:spotify_sdk_platform_interface/spotify_sdk_platform_interface.dart';

/// [SpotifySdk] holds the functionality to connect via spotify remote or
/// get an authToken to control the spotify playback.
class SpotifySdk {
  /// Connects to Spotify Remote, returning a [bool] for confirmation.
  static Future<bool> connectToSpotifyRemote({
    required String clientId,
    required String redirectUrl,
    String spotifyUri = '',
    bool asRadio = false,
    String? scope,
    String playerName = 'Spotify SDK',
    String? accessToken,
  }) => SpotifySdkPlatform.instance.connectToSpotifyRemote(
    clientId: clientId,
    redirectUrl: redirectUrl,
    spotifyUri: spotifyUri,
    asRadio: asRadio,
    scope: scope,
    playerName: playerName,
    accessToken: accessToken,
  );

  /// Returns an access token as a [String].
  static Future<String> getAccessToken({
    required String clientId,
    required String redirectUrl,
    String spotifyUri = '',
    bool asRadio = false,
    String? scope,
  }) => SpotifySdkPlatform.instance.getAccessToken(
    clientId: clientId,
    redirectUrl: redirectUrl,
    spotifyUri: spotifyUri,
    asRadio: asRadio,
    scope: scope,
  );

  /// Logs the user out and disconnects the app from the users spotify account.
  static Future<bool> disconnect() => SpotifySdkPlatform.instance.disconnect();

  /// Gets the current [CrossfadeState].
  static Future<CrossfadeState?> getCrossFadeState() =>
      SpotifySdkPlatform.instance.getCrossFadeState();

  /// Gets the current [PlayerState].
  static Future<PlayerState?> getPlayerState() =>
      SpotifySdkPlatform.instance.getPlayerState();

  /// Queues the given [spotifyUri].
  static Future<void> queue({required String spotifyUri}) =>
      SpotifySdkPlatform.instance.queue(spotifyUri: spotifyUri);

  /// Plays the given [spotifyUri].
  static Future<void> play({
    required String spotifyUri,
    bool asRadio = false,
  }) => SpotifySdkPlatform.instance.play(
    spotifyUri: spotifyUri,
    asRadio: asRadio,
  );

  /// Pauses the current playing track.
  static Future<void> pause() => SpotifySdkPlatform.instance.pause();

  /// Resumes the current paused track.
  static Future<void> resume() => SpotifySdkPlatform.instance.resume();

  /// Sets the playbackSpeed of the Podcast.
  static Future<void> setPodcastPlaybackSpeed({
    required PodcastPlaybackSpeed podcastPlaybackSpeed,
  }) => SpotifySdkPlatform.instance.setPodcastPlaybackSpeed(
    podcastPlaybackSpeed: podcastPlaybackSpeed,
  );

  /// Skips to the next track.
  static Future<void> skipNext() => SpotifySdkPlatform.instance.skipNext();

  /// Skips to the previous track.
  static Future<void> skipPrevious() =>
      SpotifySdkPlatform.instance.skipPrevious();

  /// Skips to track at specified index in album or playlist.
  static Future<void> skipToIndex({
    required String spotifyUri,
    required int trackIndex,
  }) => SpotifySdkPlatform.instance.skipToIndex(
    spotifyUri: spotifyUri,
    trackIndex: trackIndex,
  );

  /// Seeks the current track to the given [positionedMilliseconds].
  static Future<void> seekTo({required int positionedMilliseconds}) =>
      SpotifySdkPlatform.instance.seekTo(
        positionedMilliseconds: positionedMilliseconds,
      );

  /// Adds the given [relativeMilliseconds] to the current playback time.
  static Future<void> seekToRelativePosition({
    required int relativeMilliseconds,
  }) => SpotifySdkPlatform.instance.seekToRelativePosition(
    relativeMilliseconds: relativeMilliseconds,
  );

  /// Switch to local device for playback.
  static Future<void> switchToLocalDevice() =>
      SpotifySdkPlatform.instance.switchToLocalDevice();

  /// Toggles shuffle.
  static Future<void> toggleShuffle() =>
      SpotifySdkPlatform.instance.toggleShuffle();

  /// Toggles repeat.
  static Future<void> toggleRepeat() =>
      SpotifySdkPlatform.instance.toggleRepeat();

  /// Adds the given [spotifyUri] to the users library.
  static Future<void> addToLibrary({required String spotifyUri}) =>
      SpotifySdkPlatform.instance.addToLibrary(spotifyUri: spotifyUri);

  /// Removes the given [spotifyUri] from the users library.
  static Future<void> removeFromLibrary({required String spotifyUri}) =>
      SpotifySdkPlatform.instance.removeFromLibrary(spotifyUri: spotifyUri);

  /// Gets the [Capabilities] of the current user.
  static Future<Capabilities?> getCapabilities({
    required String spotifyUri,
  }) => SpotifySdkPlatform.instance.getCapabilities(spotifyUri: spotifyUri);

  /// Gets the [LibraryState] of the given [spotifyUri].
  static Future<LibraryState?> getLibraryState({
    required String spotifyUri,
  }) => SpotifySdkPlatform.instance.getLibraryState(spotifyUri: spotifyUri);

  /// Gets an image from a specified [imageUri].
  static Future<Uint8List?> getImage({
    required ImageUri imageUri,
    ImageDimension dimension = ImageDimension.medium,
  }) => SpotifySdkPlatform.instance.getImage(
    imageUri: imageUri,
    dimension: dimension,
  );

  /// Sets the shuffle mode.
  static Future<void> setShuffle({required bool shuffle}) =>
      SpotifySdkPlatform.instance.setShuffle(shuffle: shuffle);

  /// Sets the repeat mode.
  static Future<void> setRepeatMode({
    required SpotifyRepeatMode repeatMode,
  }) => SpotifySdkPlatform.instance.setRepeatMode(repeatMode: repeatMode);

  /// Subscribes to the [PlayerContext] and returns it.
  static Stream<PlayerContext> subscribePlayerContext() =>
      SpotifySdkPlatform.instance.subscribePlayerContext();

  /// Subscribes to the [PlayerState] and returns it.
  static Stream<PlayerState> subscribePlayerState() =>
      SpotifySdkPlatform.instance.subscribePlayerState();

  /// Subscribes to the [ConnectionStatus] and returns it.
  static Stream<ConnectionStatus> subscribeConnectionStatus() =>
      SpotifySdkPlatform.instance.subscribeConnectionStatus();

  /// Subscribes to the [Capabilities] of the current user.
  static Stream<Capabilities> subscribeCapabilities() =>
      SpotifySdkPlatform.instance.subscribeCapabilities();

  /// Subscribes to the [UserStatus] and returns it.
  static Stream<UserStatus> subscribeUserStatus() =>
      SpotifySdkPlatform.instance.subscribeUserStatus();
}
