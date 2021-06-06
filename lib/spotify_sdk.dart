import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

import 'enums/image_dimension_enum.dart';
import 'enums/repeat_mode_enum.dart';
import 'extensions/image_dimension_extension.dart';
import 'models/capabilities.dart';
import 'models/connection_status.dart';
import 'models/crossfade_state.dart';
import 'models/image_uri.dart';
import 'models/library_state.dart';
import 'models/player_context.dart';
import 'models/player_state.dart';
import 'models/user_status.dart';
import 'platform_channels.dart';

export 'package:spotify_sdk/enums/image_dimension_enum.dart';
export 'package:spotify_sdk/enums/repeat_mode_enum.dart';
export 'package:spotify_sdk/extensions/image_dimension_extension.dart';

///
/// [SpotifySdk] holds the functionality to connect via spotify remote or
/// get an authToken to control the spotify playback and use the functionality
/// described [here](https://pub.dev/packages/spotify_sdk#usage)
///
class SpotifySdk {
  // method channel
  static const MethodChannel _channel =
      MethodChannel(MethodChannels.spotifySdk);

  //player event channels
  static const EventChannel _playerContextChannel =
      EventChannel(EventChannels.playerContext);
  static const EventChannel _playerStateChannel =
      EventChannel(EventChannels.playerState);

  // user event channels
  static const EventChannel _userStatusChannel =
      EventChannel(EventChannels.userStatus);
  static const EventChannel _capabilitiesChannel =
      EventChannel(EventChannels.capabilities);

  // connection status channel
  static const EventChannel _connectionStatusChannel =
      EventChannel(EventChannels.connectionStatus);

  //logging
  static final Logger _logger = Logger();

  /// Connects to Spotify Remote, returning a [bool] for confirmation
  ///
  /// Required parameters are the [clientId] and the [redirectUrl] to
  /// authenticate with the Spotify Api
  /// iOS specific: You can optionally pass an [accessToken] that you have persisted from a previous session. This will prevent redirecting to the Spotify if the token is still valid. It will be ignored on platforms other than iOS.
  /// iOS specific: You can optionally pass a [spotifyUri]. A blank string will play the user's last song or pick a random one. It will be ignored on platforms other than iOS.
  /// Throws a [PlatformException] if connecting to the remote api failed
  /// Throws a [MissingPluginException] if the method is not implemented on
  /// the native platforms.
  static Future<bool> connectToSpotifyRemote(
      {required String clientId,
      required String redirectUrl,
      String spotifyUri = '',
      bool asRadio = false,
      String? scope,
      String playerName = 'Spotify SDK',
      String? accessToken}) async {
    try {
      return await _channel.invokeMethod(MethodNames.connectToSpotify, {
        ParamNames.clientId: clientId,
        ParamNames.redirectUrl: redirectUrl,
        ParamNames.playerName: playerName,
        ParamNames.accessToken: accessToken,
        ParamNames.scope: scope,
        ParamNames.spotifyUri: spotifyUri,
        ParamNames.asRadio: asRadio,
      });
    } on Exception catch (e) {
      _logException(MethodNames.connectToSpotify, e);
      rethrow;
    }
  }

  /// Returns an authentication token as a [String]
  ///
  /// Required parameters are the [clientId] and the [redirectUrl] to
  /// authenticate with the Spotify Api.
  /// Also you have to provide a [scope] like
  /// "app-remote-control, user-modify-playback-state, playlist-read-private,
  /// playlist-modify-public,user-read-currently-playing"
  /// See https://developer.spotify.com/documentation/general/guides/scopes/
  /// for more scopes and how to use them
  /// The token can be used to communicate with the web api
  /// iOS specific: You can optionally pass a [spotifyUri]. A blank string will play the user's last song or pick a random one. It will be ignored on platforms other than iOS.
  /// Throws a [PlatformException] if retrieving the authentication token
  /// failed.
  /// Throws a [MissingPluginException] if the method is not implemented on
  /// the native platforms.
  static Future<String> getAuthenticationToken(
      {required String clientId,
      required String redirectUrl,
      String spotifyUri = '',
      bool asRadio = false,
      String? scope}) async {
    try {
      final authorization =
          await _channel.invokeMethod(MethodNames.getAuthenticationToken, {
        ParamNames.clientId: clientId,
        ParamNames.redirectUrl: redirectUrl,
        ParamNames.scope: scope,
        ParamNames.spotifyUri: spotifyUri,
        ParamNames.asRadio: asRadio,
      });
      return authorization.toString();
    } on Exception catch (e) {
      _logException(MethodNames.getAuthenticationToken, e);
      rethrow;
    }
  }

  /// Logs the user out and disconnects the app from the users spotify account
  ///
  /// Throws a [PlatformException] if disconnect failed
  /// Throws a [MissingPluginException] if the method is not implemented on
  /// the native platforms.
  static Future<bool> disconnect() async {
    try {
      return await _channel.invokeMethod(MethodNames.disconnectFromSpotify);
    } on Exception catch (e) {
      _logException(MethodNames.disconnectFromSpotify, e);
      rethrow;
    }
  }

  /// Checks if the Spotify app is active on the user's device. You can use this to determine if maybe you should prompt
  /// the user to connect to Spotify (because you know they are already using Spotify if it is active). The Spotify app
  /// will be considered active if music is playing.
  /// Returns true if Spotify is active, otherwise false.
  ///
  /// Throws a [MissingPluginException] if the method is not implemented on
  /// the native platforms.
  static Future<bool> get isSpotifyAppActive async {
    try {
      return await _channel.invokeMethod(MethodNames.isSpotifyAppActive);
    } on Exception catch (e) {
      _logException(MethodNames.isSpotifyAppActive, e);
      rethrow;
    }
  }

  /// Gets the current [CrossfadeState]
  ///
  /// Throws a [PlatformException] getting the crossfadeState failed
  /// Throws a [MissingPluginException] if the method is not implemented on
  /// the native platforms.
  static Future<CrossfadeState?> getCrossFadeState() async {
    try {
      var crossfadeStateJson =
          await (_channel.invokeMethod<String>(MethodNames.getCrossfadeState));
      if (crossfadeStateJson == null) {
        return null;
      }
      var crossfadeStateMap =
          jsonDecode(crossfadeStateJson) as Map<String, dynamic>;
      var crossfadeState = CrossfadeState.fromJson(crossfadeStateMap);
      return crossfadeState;
    } on Exception catch (e) {
      _logException(MethodNames.getCrossfadeState, e);
      rethrow;
    }
  }

  /// Gets the current [PlayerState]
  ///
  /// Throws a [PlatformException] getting the playerState failed
  /// Throws a [MissingPluginException] if the method is not implemented on
  /// the native platforms.
  static Future<PlayerState?> getPlayerState() async {
    try {
      var playerStateJson =
          await (_channel.invokeMethod<String>(MethodNames.getPlayerState));
      if (playerStateJson == null) {
        return null;
      }
      var playerStateMap = jsonDecode(playerStateJson) as Map<String, dynamic>;
      var playerState = PlayerState.fromJson(playerStateMap);
      return playerState;
    } on Exception catch (e) {
      _logException(MethodNames.getPlayerState, e);
      rethrow;
    }
  }

  /// Queues the given [spotifyUri]
  ///
  /// The [spotifyUri] can be an artist, album, playlist and track
  /// Throws a [PlatformException] if queing failed
  /// Throws a [MissingPluginException] if the method is not implemented on
  /// the native platforms.
  static Future queue({required String spotifyUri}) async {
    try {
      await _channel.invokeMethod(
          MethodNames.queueTrack, {ParamNames.spotifyUri: spotifyUri});
    } on Exception catch (e) {
      _logException(MethodNames.queueTrack, e);
      rethrow;
    }
  }

  /// Plays the given [spotifyUri]
  ///
  /// The [spotifyUri] can be an artist, album, playlist and track
  /// On iOS set [asRadio] to true to start radio for track URI. Default: false
  /// Throws a [PlatformException] if playing failed
  /// Throws a [MissingPluginException] if the method is not implemented on
  /// the native platforms.
  static Future play({
    required String spotifyUri,
    bool asRadio = false,
  }) async {
    try {
      await _channel.invokeMethod(MethodNames.play, {
        ParamNames.spotifyUri: spotifyUri,
        ParamNames.asRadio: asRadio,
      });
    } on Exception catch (e) {
      _logException(MethodNames.play, e);
      rethrow;
    }
  }

  /// Pauses the current playing track
  ///
  /// Throws a [PlatformException] if pausing failed
  /// Throws a [MissingPluginException] if the method is not implemented on
  /// the native platforms.
  static Future pause() async {
    try {
      await _channel.invokeMethod(MethodNames.pause);
    } on Exception catch (e) {
      _logException(MethodNames.pause, e);
      rethrow;
    }
  }

  /// Resumes the current paused track
  ///
  /// Throws a [PlatformException] if resuming failed
  /// Throws a [MissingPluginException] if the method is not implemented on
  /// the native platforms.
  static Future resume() async {
    try {
      await _channel.invokeMethod(MethodNames.resume);
    } on Exception catch (e) {
      _logException(MethodNames.resume, e);
      rethrow;
    }
  }

  /// Skips to the next track
  ///
  /// Throws a [PlatformException] if skipping failed
  /// Throws a [MissingPluginException] if the method is not implemented on
  /// the native platforms.
  static Future skipNext() async {
    try {
      await _channel.invokeMethod(MethodNames.skipNext);
    } on Exception catch (e) {
      _logException(MethodNames.skipNext, e);
      rethrow;
    }
  }

  /// Skips to the previous track
  ///
  /// Throws a [PlatformException] if skipping failed
  /// Throws a [MissingPluginException] if the method is not implemented on
  /// the native platforms.
  static Future skipPrevious() async {
    try {
      await _channel.invokeMethod(MethodNames.skipPrevious);
    } on Exception catch (e) {
      _logException(MethodNames.skipPrevious, e);
      rethrow;
    }
  }

  /// Skips to track at specified index in album or playlist
  ///
  /// The [spotifyUri] can be an album or playlist
  /// The [trackIndex] is the index of the track in the playlist to be played
  /// Throws a [PlatformException] if skipping failed
  /// Throws a [MissingPluginException] if the method is not implemented on
  /// the native platforms.
  static Future skipToIndex({
    required String spotifyUri,
    required int trackIndex,
  }) async {
    try {
      await _channel.invokeMethod(MethodNames.skipToIndex, {
        ParamNames.spotifyUri: spotifyUri,
        ParamNames.trackIndex: trackIndex,
      });
    } on Exception catch (e) {
      _logException(MethodNames.skipToIndex, e);
      rethrow;
    }
  }

  /// Subscribes to the [PlayerContext] and returns it.
  ///
  /// Throws a [PlatformException] if this fails
  /// Throws a [MissingPluginException] if the method is not implemented on
  /// the native platforms.
  static Stream<PlayerContext> subscribePlayerContext() {
    try {
      var playerContextSubscription =
          _playerContextChannel.receiveBroadcastStream();
      return playerContextSubscription.asyncMap((playerContextJson) {
        var playerContextMap =
            jsonDecode(playerContextJson.toString()) as Map<String, dynamic>;
        return PlayerContext.fromJson(playerContextMap);
      });
    } on Exception catch (e) {
      _logException(MethodNames.subscribePlayerContext, e);
      rethrow;
    }
  }

  /// Subscribes to the [PlayerState] and returns it.
  ///
  /// Throws a [PlatformException] if this fails
  /// Throws a [MissingPluginException] if the method is not implemented on
  /// the native platforms.
  static Stream<PlayerState> subscribePlayerState() {
    try {
      var playerStateSubscription =
          _playerStateChannel.receiveBroadcastStream();
      return playerStateSubscription.asyncMap((playerStateJson) {
        var playerStateMap =
            jsonDecode(playerStateJson.toString()) as Map<String, dynamic>;
        return PlayerState.fromJson(playerStateMap);
      });
    } on Exception catch (e) {
      _logException(MethodNames.subscribePlayerState, e);
      rethrow;
    }
  }

  /// Subscribes to the [ConnectionStatus] and returns it.
  ///
  /// Throws a [PlatformException] if this fails
  /// Throws a [MissingPluginException] if the method is not implemented on
  /// the native platforms.
  static Stream<ConnectionStatus> subscribeConnectionStatus() {
    try {
      var connectionStatusSubscription =
          _connectionStatusChannel.receiveBroadcastStream();
      return connectionStatusSubscription.asyncMap((connectionStatusJson) {
        var connectionStatusMap =
            jsonDecode(connectionStatusJson.toString()) as Map<String, dynamic>;
        return ConnectionStatus.fromJson(connectionStatusMap);
      });
    } on Exception catch (e) {
      _logException(MethodNames.subscribeConnectionStatus, e);
      rethrow;
    }
  }

  /// Seeks the current track to the given [positionedMilliseconds]
  ///
  ///
  /// Throws a [PlatformException] if seeking failed
  /// Throws a [MissingPluginException] if the method is not implemented on
  /// the native platforms.
  static Future seekTo({required int positionedMilliseconds}) async {
    try {
      await _channel.invokeMethod(MethodNames.seekTo,
          {ParamNames.positionedMilliseconds: positionedMilliseconds});
    } on Exception catch (e) {
      _logException(MethodNames.seekTo, e);
      rethrow;
    }
  }

  /// Adds the given [relativeMilliseconds] to the current playback time.
  ///
  /// This will add [relativeMilliseconds] to the current value of the playback
  /// time. This can also be negative to rewind the current track.
  /// Throws a [PlatformException] if seeking failed
  /// Throws a [MissingPluginException] if the method is not implemented on
  /// the native platforms.
  static Future seekToRelativePosition(
      {required int relativeMilliseconds}) async {
    try {
      await _channel.invokeMethod(MethodNames.seekToRelativePosition,
          {ParamNames.relativeMilliseconds: relativeMilliseconds});
    } on Exception catch (e) {
      _logException(MethodNames.seekToRelativePosition, e);
      rethrow;
    }
  }

  /// Toggles shuffle
  ///
  /// Throws a [PlatformException] if toggling shuffle failed
  /// Throws a [MissingPluginException] if the method is not implemented on
  /// the native platforms.
  static Future toggleShuffle() async {
    try {
      await _channel.invokeMethod(MethodNames.toggleShuffle);
    } on Exception catch (e) {
      _logException(MethodNames.toggleShuffle, e);
      rethrow;
    }
  }

  /// Toggles repeat
  ///
  /// Throws a [PlatformException] if toggling repeat failed
  /// Throws a [MissingPluginException] if the method is not implemented on
  /// the native platforms.
  static Future toggleRepeat() async {
    try {
      await _channel.invokeMethod(MethodNames.toggleRepeat);
    } on Exception catch (e) {
      _logException(MethodNames.toggleRepeat, e);
      rethrow;
    }
  }

  /// Adds the given [spotifyUri] to the users library
  ///
  /// Throws a [PlatformException] if adding failed
  /// Throws a [MissingPluginException] if the method is not implemented on
  /// the native platforms.
  static Future addToLibrary({required String spotifyUri}) async {
    try {
      await _channel.invokeMethod(
          MethodNames.addToLibrary, {ParamNames.spotifyUri: spotifyUri});
    } on Exception catch (e) {
      _logException(MethodNames.addToLibrary, e);
      rethrow;
    }
  }

  /// Removes the given [spotifyUri] from the users library
  ///
  /// Throws a [PlatformException] if adding failed
  /// Throws a [MissingPluginException] if the method is not implemented on
  /// the native platforms.
  static Future removeFromLibrary({required String spotifyUri}) async {
    try {
      await _channel.invokeMethod(
          MethodNames.removeFromLibrary, {ParamNames.spotifyUri: spotifyUri});
    } on Exception catch (e) {
      _logException(MethodNames.removeFromLibrary, e);
      rethrow;
    }
  }

  /// Gets the [Capabilities] of the current user
  ///
  /// Throws a [PlatformException] getting the capability failed
  /// Throws a [MissingPluginException] if the method is not implemented on
  /// the native platforms.
  static Future<Capabilities?> getCapabilities(
      {required String spotifyUri}) async {
    try {
      var capabilitiesJson =
          await _channel.invokeMethod<String>(MethodNames.getCapabilities);

      if (capabilitiesJson!.isNotEmpty) {
        var capabilitiesMap =
            jsonDecode(capabilitiesJson) as Map<String, dynamic>;
        return Capabilities.fromJson(capabilitiesMap);
      }

      return null;
    } on Exception catch (e) {
      _logException(MethodNames.getCapabilities, e);
      rethrow;
    }
  }

  /// Gets the [LibraryState] of the given [spotifyUri]
  ///
  /// Throws a [PlatformException] when getting the library state failed
  /// Throws a [MissingPluginException] if the method is not implemented on
  /// the native platforms.
  static Future<LibraryState?> getLibraryState(
      {required String spotifyUri}) async {
    try {
      var libraryStateJson = await (_channel.invokeMethod<String>(
          MethodNames.getLibraryState, {ParamNames.spotifyUri: spotifyUri}));
      if (libraryStateJson == null) {
        return null;
      }
      var libraryStateMap =
          jsonDecode(libraryStateJson) as Map<String, dynamic>;
      return LibraryState.fromJson(libraryStateMap);
    } on Exception catch (e) {
      _logException(MethodNames.getLibraryState, e);
      rethrow;
    }
  }

  /// Subscribes to the [Capabilities] of the current user
  ///
  /// Throws a [PlatformException] getting the capability failed
  /// Throws a [MissingPluginException] if the method is not implemented on
  /// the native platforms.
  static Stream<Capabilities> subscribeCapabilities() {
    try {
      var capabilitiesSubscription =
          _capabilitiesChannel.receiveBroadcastStream();
      return capabilitiesSubscription.asyncMap((capabilitiesJson) {
        var capabilitiesMap =
            jsonDecode(capabilitiesJson.toString()) as Map<String, dynamic>;
        return Capabilities.fromJson(capabilitiesMap);
      });
    } on Exception catch (e) {
      _logException(MethodNames.subscribePlayerContext, e);
      rethrow;
    }
  }

  /// Subscribes to the [UserStatus]
  ///
  /// Throws a [PlatformException] when getting the userStatus failed
  /// Throws a [MissingPluginException] if the method is not implemented on
  /// the native platforms.
  static Stream<UserStatus> subscribeUserStatus() {
    try {
      var userStatusSubscription = _userStatusChannel.receiveBroadcastStream();
      return userStatusSubscription.asyncMap((userStatusJson) {
        var userStatusMap =
            jsonDecode(userStatusJson.toString()) as Map<String, dynamic>;
        return UserStatus.fromJson(userStatusMap);
      });
    } on Exception catch (e) {
      _logException(MethodNames.subscribePlayerContext, e);
      rethrow;
    }
  }

  /// Gets an image from a specified [imageUri]
  ///
  /// The size of the image can be controlled via the [dimension].
  /// If no [dimension] is given the default value of [ImageDimension.medium]
  /// will be used
  /// Throws a [PlatformException] if adding failed
  /// Throws a [MissingPluginException] if the method is not implemented on
  /// the native platforms.
  static Future<Uint8List?> getImage(
      {required ImageUri imageUri,
      ImageDimension dimension = ImageDimension.medium}) async {
    try {
      return _channel.invokeMethod(MethodNames.getImage, {
        ParamNames.imageUri: imageUri.raw,
        ParamNames.imageDimension: dimension.value
      });
    } on Exception catch (e) {
      _logException(MethodNames.getImage, e);
      rethrow;
    }
  }

  /// Sets the shuffle mode
  ///
  /// Set [shuffle] to true or false.
  /// Throws a [PlatformException] if adding failed
  /// Throws a [MissingPluginException] if the method is not implemented on
  /// the native platforms.
  static Future setShuffle({required bool shuffle}) async {
    try {
      return _channel.invokeMethod(MethodNames.setShuffle, {
        ParamNames.shuffle: shuffle,
      });
    } on Exception catch (e) {
      _logException(MethodNames.setShuffle, e);
      rethrow;
    }
  }

  /// Sets the repeat mode
  ///
  /// Set [repeatMode] to a value of [RepeatMode] either [off, track, context].
  /// Throws a [PlatformException] if adding failed
  /// Throws a [MissingPluginException] if the method is not implemented on
  /// the native platforms.
  static Future setRepeatMode({required RepeatMode repeatMode}) async {
    try {
      return _channel.invokeMethod(
          MethodNames.setRepeatMode, {ParamNames.repeatMode: repeatMode.index});
    } on Exception catch (e) {
      _logException(MethodNames.setRepeatMode, e);
      rethrow;
    }
  }

  static void _logException(String method, Exception e) {
    if (e is PlatformException) {
      var message = e.message ?? '';
      message += e.details != null ? '\n${e.details}' : '';
      _logger.i('$method failed with: $message');
    } else if (e is MissingPluginException) {
      _logger.i('$method not implemented');
    } else {
      _logger.i('$method throws unhandled exception: ${e.toString()}');
    }
  }
}
