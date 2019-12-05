import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:logger/logger.dart';
import 'package:spotify_sdk/models/player_state.dart';

import 'models/crossfade_state.dart';

class SpotifySdk {
  // connection and auth
  static const String _methodConnectToSpotify = "connectToSpotify";
  static const String _methodGetAuthenticationToken = "getAuthenticationToken";
  static const String _methodLogoutFromSpotify = "logoutFromSpotify";

  // player api
  static const String _methodGetCrossfadeState = "getCrossfadeState";
  static const String _methodGetPlayerState = "getPlayerState";
  static const String _methodPlay = "play";
  static const String _methodPause = "pause";
  static const String _methodQueueTrack = "queueTrack";
  static const String _methodResume = "resume";
  static const String _methodSkipNext = "skipNext";
  static const String _methodSkipPrevious = "skipPrevious";
  static const String _methodSeekTo = "seekTo";
  static const String _methodSeekToRelativePosition = "seekToRelativePosition";
  static const String _methodToggleRepeat = "toggleRepeat";
  static const String _methodToggleShuffle = "toggleShuffle";
  // user api
  static const String _methodAddToLibrary = "addToLibrary";
  // images api
  static const String _methodGetImage = "getImage";
  // params
  static const String _paramClientId = "clientId";
  static const String _paramRedirectUrl = "redirectUrl";
  static const String _paramSpotifyUri = "spotifyUri";
  static const String _paramImageUri = "imageUri";
  static const String _paramImageDimension = "imageDimension";
  static const String _paramPositionedMilliseconds = "positionedMilliseconds";
  static const String _paramRelativeMilliseconds = "relativeMilliseconds";

  static final Logger _logger = Logger();
  static const MethodChannel _channel = const MethodChannel('spotify_sdk');

  /// Connects to Spotify Remote, returning a [bool] for confirmation
  ///
  /// Required paramters are the [clientId] and the [redirectUrl] to authenticate with the Spotify Api
  /// Throws a [PlatformException] if connecting to the remote api failed
  /// Throws a [MissingPluginException] if the method is not implemented on any of the native platforms.
  static Future<bool> connectToSpotifyRemote(
      {@required String clientId, @required String redirectUrl}) async {
    try {
      return await _channel.invokeMethod(_methodConnectToSpotify,
          {_paramClientId: clientId, _paramRedirectUrl: redirectUrl});
    } on Exception catch (e) {
      _logException(_methodConnectToSpotify, e);
      throw e;
    }
  }

  /// Returns an authentication token as a [String].
  ///
  /// Required paramters are the [clientId] and the [redirectUrl] to authenticate with the Spotify Api
  /// Throws a [PlatformException] if retrieving the authentication token failed.
  /// Throws a [MissingPluginException] if the method is not implemented on any of the native platforms.
  static Future<String> getAuthenticationToken(
      {@required String clientId, @required String redirectUrl}) async {
    try {
      final String authorization = await _channel.invokeMethod(
          _methodGetAuthenticationToken,
          {_paramClientId: clientId, _paramRedirectUrl: redirectUrl});
      return authorization;
    } on Exception catch (e) {
      _logException(_methodGetAuthenticationToken, e);
      throw e;
    }
  }

  /// Logs the user out and disconnects the app from the users spotify account
  ///
  /// Throws a [PlatformException] if logout failed
  /// Throws a [MissingPluginException] if the method is not implemented on any of the native platforms.
  static Future logout() async {
    try {
      await _channel.invokeMethod(_methodLogoutFromSpotify);
    } on Exception catch (e) {
      _logException(_methodLogoutFromSpotify, e);
      throw e;
    }
  }

  /// Gets the current [CrossfadeState]
  ///
  /// Throws a [PlatformException] getting the crossfadeState failed
  /// Throws a [MissingPluginException] if the method is not implemented on any of the native platforms.
  static Future<CrossfadeState> getCrossFadeState() async {
    try {
      var crossfadeStateJson =
          await _channel.invokeMethod(_methodGetCrossfadeState);
      var crossfadeStateMap = jsonDecode(crossfadeStateJson);
      var crossfadeState = CrossfadeState.fromJson(crossfadeStateMap);
      return crossfadeState;
    } on Exception catch (e) {
      _logException(_methodGetCrossfadeState, e);
      throw e;
    }
  }

  /// Gets the current [PlayerState]
  ///
  /// Throws a [PlatformException] getting the playerState failed
  /// Throws a [MissingPluginException] if the method is not implemented on any of the native platforms.
  static Future<PlayerState> getPlayerState() async {
    try {
      var playerStateJson = await _channel.invokeMethod(_methodGetPlayerState);
      var playerStateMap = jsonDecode(playerStateJson);
      var playerState = PlayerState.fromJson(playerStateMap);
      return playerState;
    } on Exception catch (e) {
      _logException(_methodGetPlayerState, e);
      throw e;
    }
  }

  /// Queues the given [spotifyUri]
  ///
  /// The [spotifyUri] can be an artist, album, playlist and track
  /// Throws a [PlatformException] if queing failed
  /// Throws a [MissingPluginException] if the method is not implemented on any of the native platforms.
  static Future queue({@required String spotifyUri}) async {
    try {
      await _channel
          .invokeMethod(_methodQueueTrack, {_paramSpotifyUri: spotifyUri});
    } on Exception catch (e) {
      _logException(_methodQueueTrack, e);
      throw e;
    }
  }

  /// Plays the given [spotifyUri]
  ///
  /// The [spotifyUri] can be an artist, album, playlist and track
  /// Throws a [PlatformException] if playing failed
  /// Throws a [MissingPluginException] if the method is not implemented on any of the native platforms.
  static Future play({@required String spotifyUri}) async {
    try {
      await _channel.invokeMethod(_methodPlay, {_paramSpotifyUri: spotifyUri});
    } on Exception catch (e) {
      _logException(_methodPlay, e);
      throw e;
    }
  }

  /// Pauses the current playing track
  ///
  /// Throws a [PlatformException] if pausing failed
  /// Throws a [MissingPluginException] if the method is not implemented on any of the native platforms.
  static Future pause() async {
    try {
      await _channel.invokeMethod(_methodPause);
    } on Exception catch (e) {
      _logException(_methodPause, e);
      throw e;
    }
  }

  /// Resumes the current paused track
  ///
  /// Throws a [PlatformException] if resuming failed
  /// Throws a [MissingPluginException] if the method is not implemented on any of the native platforms.
  static Future resume() async {
    try {
      await _channel.invokeMethod(_methodResume);
    } on Exception catch (e) {
      _logException(_methodResume, e);
      throw e;
    }
  }

  /// Skips to the next track
  ///
  /// Throws a [PlatformException] if skipping failed
  /// Throws a [MissingPluginException] if the method is not implemented on any of the native platforms.
  static Future skipNext() async {
    try {
      await _channel.invokeMethod(_methodSkipNext);
    } on Exception catch (e) {
      _logException(_methodSkipNext, e);
      throw e;
    }
  }

  /// Skips to the previous track
  ///
  /// Throws a [PlatformException] if skipping failed
  /// Throws a [MissingPluginException] if the method is not implemented on any of the native platforms.
  static Future skipPrevious() async {
    try {
      await _channel.invokeMethod(_methodSkipPrevious);
    } on Exception catch (e) {
      _logException(_methodSkipPrevious, e);
      throw e;
    }
  }

  /// Seeks the current track to the given [positionedMilliseconds]
  ///
  ///
  /// Throws a [PlatformException] if seeking failed
  /// Throws a [MissingPluginException] if the method is not implemented on any of the native platforms.
  static Future seekTo({@required int positionedMilliseconds}) async {
    try {
      await _channel.invokeMethod(_methodSeekTo,
          {_paramPositionedMilliseconds: positionedMilliseconds});
    } on Exception catch (e) {
      _logException(_methodSeekTo, e);
      throw e;
    }
  }

  /// Adds the given [relativeMilliseconds] to the current playback time.
  ///
  /// This will add [relativeMilliseconds] to the current value of the playback time. This can also be negative to rewind the current track.
  /// Throws a [PlatformException] if seeking failed
  /// Throws a [MissingPluginException] if the method is not implemented on any of the native platforms.
  static Future seekToRelativePosition(
      {@required int relativeMilliseconds}) async {
    try {
      await _channel.invokeMethod(_methodSeekToRelativePosition,
          {_paramRelativeMilliseconds: relativeMilliseconds});
    } on Exception catch (e) {
      _logException(_methodSeekToRelativePosition, e);
      throw e;
    }
  }

  /// Toggles shuffle
  ///
  /// Throws a [PlatformException] if toggling shuffle failed
  /// Throws a [MissingPluginException] if the method is not implemented on any of the native platforms.
  static Future toggleShuffle() async {
    try {
      await _channel.invokeMethod(_methodToggleShuffle);
    } on Exception catch (e) {
      _logException(_methodToggleShuffle, e);
      throw e;
    }
  }

  /// Toggles repeat
  ///
  /// Throws a [PlatformException] if toggling repeat failed
  /// Throws a [MissingPluginException] if the method is not implemented on any of the native platforms.
  static Future toggleRepeat() async {
    try {
      await _channel.invokeMethod(_methodToggleRepeat);
    } on Exception catch (e) {
      _logException(_methodToggleRepeat, e);
      throw e;
    }
  }

  /// Adds the given [spotifyUri] to the users library
  ///
  /// Throws a [PlatformException] if adding failed
  /// Throws a [MissingPluginException] if the method is not implemented on any of the native platforms.
  static Future addToLibrary({@required String spotifyUri}) async {
    try {
      await _channel
          .invokeMethod(_methodAddToLibrary, {_paramSpotifyUri: spotifyUri});
    } on Exception catch (e) {
      _logException(_methodAddToLibrary, e);
      throw e;
    }
  }

  /// Gets an image from a specified [imageUri]
  ///
  /// The size of the image can be controlled via the [dimension]. If no [dimension] is given the default value of [ImageDimension.medium] will be used
  /// Throws a [PlatformException] if adding failed
  /// Throws a [MissingPluginException] if the method is not implemented on any of the native platforms.
  static Future getImage(
      {@required String imageUri, @required ImageDimension dimension}) async {
    try {
      var imageDimension = 480;
      switch (dimension) {
        case ImageDimension.large:
          imageDimension = 720;
          break;
        case ImageDimension.medium:
          imageDimension = 480;
          break;
        case ImageDimension.small:
          imageDimension = 360;
          break;
        case ImageDimension.x_small:
          imageDimension = 240;
          break;
        case ImageDimension.thumbnail:
          imageDimension = 144;
          break;
      }
      await _channel.invokeMethod(_methodGetImage,
          {_paramImageUri: imageUri, _paramImageDimension: imageDimension});
    } on Exception catch (e) {
      _logException(_methodGetImage, e);
      throw e;
    }
  }

  static void _logException(String method, Exception e) {
    if (e is PlatformException) {
      var message = e.message;
      message += !e.details.isEmpty ? "\n${e.details}" : "";
      _logger.i('$method failed with: $message');
    } else if (e is MissingPluginException) {
      _logger.i('$method not implemented');
    } else {
      _logger.i('$method throws unhandled exception: ${e.toString()}');
    }
  }
}

enum ImageDimension { large, medium, small, x_small, thumbnail }
