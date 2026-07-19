import 'dart:async';
import 'dart:typed_data';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:spotify_sdk_platform_interface/enums/image_dimension_enum.dart';
import 'package:spotify_sdk_platform_interface/enums/podcast_playback_speed.dart';
import 'package:spotify_sdk_platform_interface/enums/repeat_mode_enum.dart';
import 'package:spotify_sdk_platform_interface/models/capabilities.dart';
import 'package:spotify_sdk_platform_interface/models/connection_status.dart';
import 'package:spotify_sdk_platform_interface/models/crossfade_state.dart';
import 'package:spotify_sdk_platform_interface/models/image_uri.dart';
import 'package:spotify_sdk_platform_interface/models/library_state.dart';
import 'package:spotify_sdk_platform_interface/models/player_context.dart';
import 'package:spotify_sdk_platform_interface/models/player_state.dart';
import 'package:spotify_sdk_platform_interface/models/user_status.dart';
import 'package:spotify_sdk_platform_interface/src/method_channel_spotify_sdk.dart';

export 'package:spotify_sdk_platform_interface/enums/image_dimension_enum.dart';
export 'package:spotify_sdk_platform_interface/enums/podcast_playback_speed.dart';
export 'package:spotify_sdk_platform_interface/enums/repeat_mode_enum.dart';
export 'package:spotify_sdk_platform_interface/extensions/image_dimension_extension.dart';
export 'package:spotify_sdk_platform_interface/extensions/podcast_playback_speed_extension.dart';
export 'package:spotify_sdk_platform_interface/models/album.dart';
export 'package:spotify_sdk_platform_interface/models/artist.dart';
export 'package:spotify_sdk_platform_interface/models/capabilities.dart';
export 'package:spotify_sdk_platform_interface/models/connection_status.dart';
export 'package:spotify_sdk_platform_interface/models/crossfade_state.dart';
export 'package:spotify_sdk_platform_interface/models/image_uri.dart';
export 'package:spotify_sdk_platform_interface/models/library_state.dart';
export 'package:spotify_sdk_platform_interface/models/player_context.dart';
export 'package:spotify_sdk_platform_interface/models/player_options.dart';
export 'package:spotify_sdk_platform_interface/models/player_restrictions.dart';
export 'package:spotify_sdk_platform_interface/models/player_state.dart';
export 'package:spotify_sdk_platform_interface/models/track.dart';
export 'package:spotify_sdk_platform_interface/models/user_status.dart';
export 'package:spotify_sdk_platform_interface/src/method_channel_spotify_sdk.dart';

/// The interface that implementations of spotify_sdk must implement.
abstract class SpotifySdkPlatform extends PlatformInterface {
  /// Constructs a SpotifySdkPlatform.
  SpotifySdkPlatform() : super(token: _token);

  static final Object _token = Object();

  static SpotifySdkPlatform _instance = MethodChannelSpotifySdk();

  /// The default instance of [SpotifySdkPlatform] to use.
  ///
  /// Defaults to [MethodChannelSpotifySdk].
  static SpotifySdkPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [SpotifySdkPlatform] when
  /// they register themselves.
  static set instance(SpotifySdkPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Connects to Spotify Remote, returning a [bool] for confirmation.
  Future<bool> connectToSpotifyRemote({
    required String clientId,
    required String redirectUrl,
    String spotifyUri = '',
    bool asRadio = false,
    String? scope,
    String playerName = 'Spotify SDK',
    String? accessToken,
  }) {
    throw UnimplementedError(
      'connectToSpotifyRemote() has not been implemented.',
    );
  }

  /// Returns an access token as a [String].
  Future<String> getAccessToken({
    required String clientId,
    required String redirectUrl,
    String spotifyUri = '',
    bool asRadio = false,
    String? scope,
  }) {
    throw UnimplementedError('getAccessToken() has not been implemented.');
  }

  /// Logs the user out and disconnects the app from the users spotify account.
  Future<bool> disconnect() {
    throw UnimplementedError('disconnect() has not been implemented.');
  }

  /// Gets the current [CrossfadeState].
  Future<CrossfadeState?> getCrossFadeState() {
    throw UnimplementedError('getCrossFadeState() has not been implemented.');
  }

  /// Gets the current [PlayerState].
  Future<PlayerState?> getPlayerState() {
    throw UnimplementedError('getPlayerState() has not been implemented.');
  }

  /// Queues the given [spotifyUri].
  Future<void> queue({required String spotifyUri}) {
    throw UnimplementedError('queue() has not been implemented.');
  }

  /// Plays the given [spotifyUri].
  Future<void> play({
    required String spotifyUri,
    bool asRadio = false,
  }) {
    throw UnimplementedError('play() has not been implemented.');
  }

  /// Pauses the current playing track.
  Future<void> pause() {
    throw UnimplementedError('pause() has not been implemented.');
  }

  /// Resumes the current paused track.
  Future<void> resume() {
    throw UnimplementedError('resume() has not been implemented.');
  }

  /// Sets the playbackSpeed of the Podcast.
  Future<void> setPodcastPlaybackSpeed({
    required PodcastPlaybackSpeed podcastPlaybackSpeed,
  }) {
    throw UnimplementedError(
      'setPodcastPlaybackSpeed() has not been implemented.',
    );
  }

  /// Skips to the next track.
  Future<void> skipNext() {
    throw UnimplementedError('skipNext() has not been implemented.');
  }

  /// Skips to the previous track.
  Future<void> skipPrevious() {
    throw UnimplementedError('skipPrevious() has not been implemented.');
  }

  /// Skips to track at specified index in album or playlist.
  Future<void> skipToIndex({
    required String spotifyUri,
    required int trackIndex,
  }) {
    throw UnimplementedError('skipToIndex() has not been implemented.');
  }

  /// Seeks the current track to the given [positionedMilliseconds].
  Future<void> seekTo({required int positionedMilliseconds}) {
    throw UnimplementedError('seekTo() has not been implemented.');
  }

  /// Adds the given [relativeMilliseconds] to the current playback time.
  Future<void> seekToRelativePosition({
    required int relativeMilliseconds,
  }) {
    throw UnimplementedError(
      'seekToRelativePosition() has not been implemented.',
    );
  }

  /// Switch to local device for playback.
  Future<void> switchToLocalDevice() {
    throw UnimplementedError('switchToLocalDevice() has not been implemented.');
  }

  /// Toggles shuffle.
  Future<void> toggleShuffle() {
    throw UnimplementedError('toggleShuffle() has not been implemented.');
  }

  /// Toggles repeat.
  Future<void> toggleRepeat() {
    throw UnimplementedError('toggleRepeat() has not been implemented.');
  }

  /// Adds the given [spotifyUri] to the users library.
  Future<void> addToLibrary({required String spotifyUri}) {
    throw UnimplementedError('addToLibrary() has not been implemented.');
  }

  /// Removes the given [spotifyUri] from the users library.
  Future<void> removeFromLibrary({required String spotifyUri}) {
    throw UnimplementedError('removeFromLibrary() has not been implemented.');
  }

  /// Gets the [Capabilities] of the current user.
  Future<Capabilities?> getCapabilities({
    required String spotifyUri,
  }) {
    throw UnimplementedError('getCapabilities() has not been implemented.');
  }

  /// Gets the [LibraryState] of the given [spotifyUri].
  Future<LibraryState?> getLibraryState({
    required String spotifyUri,
  }) {
    throw UnimplementedError('getLibraryState() has not been implemented.');
  }

  /// Gets an image from a specified [imageUri].
  Future<Uint8List?> getImage({
    required ImageUri imageUri,
    ImageDimension dimension = ImageDimension.medium,
  }) {
    throw UnimplementedError('getImage() has not been implemented.');
  }

  /// Sets the shuffle mode.
  Future<void> setShuffle({required bool shuffle}) {
    throw UnimplementedError('setShuffle() has not been implemented.');
  }

  /// Sets the repeat mode.
  Future<void> setRepeatMode({
    required SpotifyRepeatMode repeatMode,
  }) {
    throw UnimplementedError('setRepeatMode() has not been implemented.');
  }

  /// Subscribes to the [PlayerContext] and returns it.
  Stream<PlayerContext> subscribePlayerContext() {
    throw UnimplementedError(
      'subscribePlayerContext() has not been implemented.',
    );
  }

  /// Subscribes to the [PlayerState] and returns it.
  Stream<PlayerState> subscribePlayerState() {
    throw UnimplementedError(
      'subscribePlayerState() has not been implemented.',
    );
  }

  /// Subscribes to the [ConnectionStatus] and returns it.
  Stream<ConnectionStatus> subscribeConnectionStatus() {
    throw UnimplementedError(
      'subscribeConnectionStatus() has not been implemented.',
    );
  }

  /// Subscribes to the [Capabilities] of the current user.
  Stream<Capabilities> subscribeCapabilities() {
    throw UnimplementedError(
      'subscribeCapabilities() has not been implemented.',
    );
  }

  /// Subscribes to the [UserStatus] and returns it.
  Stream<UserStatus> subscribeUserStatus() {
    throw UnimplementedError('subscribeUserStatus() has not been implemented.');
  }
}
