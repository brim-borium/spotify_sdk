import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:logger/logger.dart';

class SpotifySdk {
  // connection and auth
  static const String _methodConnectToSpotify = "connectToSpotify";
  static const String _methodGetAuthenticationToken = "getAuthenticationToken";
  static const String _methodLogoutFromSpotify = "logoutFromSpotify";

  // player api
  static const String _methodQueueTrack = "queueTrack";
  static const String _methodPlay = "play";
  static const String _methodPause = "pause";
  static const String _methodToggleRepeat = "toggleRepeat";
  static const String _methodToggleShuffle = "toggleShuffle";
  static const String _methodResume = "resume";
  static const String _methodSkipNext = "skipNext";
  static const String _methodSkipPrevious = "skipPrevious";
  static const String _methodSeekTo = "seekTo";
  static const String _methodSeekToRelativePosition = "seekToRelativePosition";
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

  static final Logger _logger = new Logger();
  static const MethodChannel _channel = const MethodChannel('spotify_sdk');

  static Future<bool> connectToSpotifyRemote(
      {@required String clientId, @required String redirectUrl}) async {
    try {
      return await _channel.invokeMethod(_methodConnectToSpotify,
          {_paramClientId: clientId, _paramRedirectUrl: redirectUrl});
    } on PlatformException catch (e) {
      _logger.i('$_methodConnectToSpotify failed: ${e.message}');
      throw e;
    } on MissingPluginException catch (e) {
      _logger.i('$_methodConnectToSpotify not implemented');
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
    } on PlatformException catch (e) {
      _logger.i('$_methodGetAuthenticationToken failed: ${e.message}');
      throw e;
    } on MissingPluginException catch (e) {
      _logger.i('$_methodGetAuthenticationToken not implemented');
      throw e;
    }
  }

  /// Logs the user out and disconnects the app from the users spotify account
  ///
  /// Throws a [PlatformException] if logut failed
  /// Throws a [MissingPluginException] if the method is not implemented on any of the native platforms.
  static Future logout() async {
    try {
      await _channel.invokeMethod(_methodLogoutFromSpotify);
    } on PlatformException catch (e) {
      _logger.i('$_methodLogoutFromSpotify failed: ${e.message}');
      throw e;
    } on MissingPluginException catch (e) {
      _logger.i('$_methodLogoutFromSpotify not implemented');
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
    } on PlatformException catch (e) {
      _logger.i('$_methodQueueTrack failed: ${e.message}');
      throw e;
    } on MissingPluginException catch (e) {
      _logger.i('$_methodQueueTrack not implemented');
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
    } on PlatformException catch (e) {
      _logger.i('$_methodPlay failed: ${e.message}');
      throw e;
    } on MissingPluginException catch (e) {
      _logger.i('$_methodPlay not implemented');
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
    } on PlatformException catch (e) {
      _logger.i('$_methodPause failed: ${e.message}');
      throw e;
    } on MissingPluginException catch (e) {
      _logger.i('$_methodPause not implemented');
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
    } on PlatformException catch (e) {
      _logger.i('$_methodResume failed: ${e.message}');
      throw e;
    } on MissingPluginException catch (e) {
      _logger.i('$_methodResume not implemented');
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
    } on PlatformException catch (e) {
      _logger.i('$_methodSkipNext failed: ${e.message}');
      throw e;
    } on MissingPluginException catch (e) {
      _logger.i('$_methodSkipNext not implemented');
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
    } on PlatformException catch (e) {
      _logger.i('$_methodSkipPrevious failed: ${e.message}');
      throw e;
    } on MissingPluginException catch (e) {
      _logger.i('$_methodSkipPrevious not implemented');
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
    } on PlatformException catch (e) {
      _logger.i('$_methodSeekTo failed: ${e.message}');
      throw e;
    } on MissingPluginException catch (e) {
      _logger.i('$_methodSeekTo not implemented');
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
    } on PlatformException catch (e) {
      _logger.i('$_methodSeekToRelativePosition failed: ${e.message}');
      throw e;
    } on MissingPluginException catch (e) {
      _logger.i('$_methodSeekToRelativePosition not implemented');
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
    } on PlatformException catch (e) {
      _logger.i('$_methodToggleShuffle failed: ${e.message}');
      throw e;
    } on MissingPluginException catch (e) {
      _logger.i('$_methodToggleShuffle not implemented');
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
    } on PlatformException catch (e) {
      _logger.i('$_methodToggleRepeat failed: ${e.message}');
      throw e;
    } on MissingPluginException catch (e) {
      _logger.i('$_methodToggleRepeat not implemented');
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
    } on PlatformException catch (e) {
      _logger.i('$_methodAddToLibrary failed: ${e.message}');
      throw e;
    } on MissingPluginException catch (e) {
      _logger.i('$_methodAddToLibrary not implemented');
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
    } on PlatformException catch (e) {
      _logger.i('$_methodAddToLibrary failed: ${e.message}');
      throw e;
    } on MissingPluginException catch (e) {
      _logger.i('$_methodAddToLibrary not implemented');
      throw e;
    }
  }
}

enum ImageDimension { large, medium, small, x_small, thumbnail }
