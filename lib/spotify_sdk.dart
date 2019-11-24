import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:logger/logger.dart';

class SpotifySdk {
  // connection and auth
  static final String methodConnectToSpotify = "connectToSpotify";
  static final String methodLogoutFromSpotify = "logoutFromSpotify";

  // player api
  static final String methodQueueTrack = "queueTrack";
  static final String methodPlay = "play";
  static final String methodPause = "pause";
  static final String methodToggleRepeat = "toggleRepeat";
  static final String methodToggleShuffle = "toggleShuffle";
  static final String methodResume = "resume";
  static final String methodSkipNext = "skipNext";
  static final String methodSkipPrevious = "skipPrevious";
  static final String methodSeekTo = "seekTo";
  static final String methodSeekToRelativePosition = "seekToRelativePosition";
  // user api
  static final String methodAddToLibrary = "addToLibrary";
  // images api
  static final String methodGetImage = "getImage";
  // params
  static final String paramClientId = "clientId";
  static final String paramRedirectUrl = "redirectUrl";
  static final String paramSpotifyUri = "spotifyUri";
  static final String paramImageUri = "imageUri";
  static final String paramImageDimension = "imageDimension";
  static final String paramPositionedMilliseconds = "positionedMilliseconds";
  static final String paramRelativeMilliseconds = "relativeMilliseconds";

  static final Logger _logger = new Logger();
  static const MethodChannel _channel = const MethodChannel('spotify_sdk');

  static Future<String> connectSpotify(
      {@required String clientId, @required String redirectUrl}) async {
    try {
      final String authorization = await _channel.invokeMethod(
          methodConnectToSpotify,
          {paramClientId: clientId, paramRedirectUrl: redirectUrl});
      return authorization;
    } on PlatformException catch (e) {
      _logger.i('$methodConnectToSpotify failed: ${e.message}');
      throw e;
    } on MissingPluginException catch (e) {
      _logger.i('$methodConnectToSpotify not implemented');
      throw e;
    }
  }

  static Future logout() async {
    try {
      await _channel.invokeMethod(methodLogoutFromSpotify);
    } on PlatformException catch (e) {
      _logger.i('$methodLogoutFromSpotify failed: ${e.message}');
      throw e;
    } on MissingPluginException catch (e) {
      _logger.i('$methodLogoutFromSpotify not implemented');
      throw e;
    }
  }

  static Future queue({@required String spotifyUri}) async {
    try {
      await _channel
          .invokeMethod(methodQueueTrack, {paramSpotifyUri: spotifyUri});
    } on PlatformException catch (e) {
      _logger.i('$methodQueueTrack failed: ${e.message}');
      throw e;
    } on MissingPluginException catch (e) {
      _logger.i('$methodQueueTrack not implemented');
      throw e;
    }
  }

  static Future play({@required String spotifyUri}) async {
    try {
      await _channel.invokeMethod(methodPlay, {paramSpotifyUri: spotifyUri});
    } on PlatformException catch (e) {
      _logger.i('$methodPlay failed: ${e.message}');
      throw e;
    } on MissingPluginException catch (e) {
      _logger.i('$methodPlay not implemented');
      throw e;
    }
  }

  static Future pause() async {
    try {
      await _channel.invokeMethod(methodPause);
    } on PlatformException catch (e) {
      _logger.i('$methodPause failed: ${e.message}');
      throw e;
    } on MissingPluginException catch (e) {
      _logger.i('$methodPause not implemented');
      throw e;
    }
  }

  static Future resume() async {
    try {
      await _channel.invokeMethod(methodResume);
    } on PlatformException catch (e) {
      _logger.i('$methodResume failed: ${e.message}');
      throw e;
    } on MissingPluginException catch (e) {
      _logger.i('$methodResume not implemented');
      throw e;
    }
  }

  static Future skipNext() async {
    try {
      await _channel.invokeMethod(methodSkipNext);
    } on PlatformException catch (e) {
      _logger.i('$methodSkipNext failed: ${e.message}');
      throw e;
    } on MissingPluginException catch (e) {
      _logger.i('$methodSkipNext not implemented');
      throw e;
    }
  }

  static Future skipPrevious() async {
    try {
      await _channel.invokeMethod(methodSkipPrevious);
    } on PlatformException catch (e) {
      _logger.i('$methodSkipPrevious failed: ${e.message}');
      throw e;
    } on MissingPluginException catch (e) {
      _logger.i('$methodSkipPrevious not implemented');
      throw e;
    }
  }

  static Future seekTo({@required int positionedMilliseconds}) async {
    try {
      await _channel.invokeMethod(
          methodSeekTo, {paramPositionedMilliseconds: positionedMilliseconds});
    } on PlatformException catch (e) {
      _logger.i('$methodSeekTo failed: ${e.message}');
      throw e;
    } on MissingPluginException catch (e) {
      _logger.i('$methodSeekTo not implemented');
      throw e;
    }
  }

  static Future seekToRelativePosition(
      {@required int relativeMilliseconds}) async {
    try {
      await _channel.invokeMethod(methodSeekToRelativePosition,
          {paramRelativeMilliseconds: relativeMilliseconds});
    } on PlatformException catch (e) {
      _logger.i('$methodSeekToRelativePosition failed: ${e.message}');
      throw e;
    } on MissingPluginException catch (e) {
      _logger.i('$methodSeekToRelativePosition not implemented');
      throw e;
    }
  }

  static Future toggleShuffle() async {
    try {
      await _channel.invokeMethod(methodToggleShuffle);
    } on PlatformException catch (e) {
      _logger.i('$methodToggleShuffle failed: ${e.message}');
      throw e;
    } on MissingPluginException catch (e) {
      _logger.i('$methodToggleShuffle not implemented');
      throw e;
    }
  }

  static Future toggleRepeat() async {
    try {
      await _channel.invokeMethod(methodToggleRepeat);
    } on PlatformException catch (e) {
      _logger.i('$methodToggleRepeat failed: ${e.message}');
      throw e;
    } on MissingPluginException catch (e) {
      _logger.i('$methodToggleRepeat not implemented');
      throw e;
    }
  }

  static Future addToLibrary({@required String spotifyUri}) async {
    try {
      await _channel
          .invokeMethod(methodAddToLibrary, {paramSpotifyUri: spotifyUri});
    } on PlatformException catch (e) {
      _logger.i('$methodAddToLibrary failed: ${e.message}');
      throw e;
    } on MissingPluginException catch (e) {
      _logger.i('$methodAddToLibrary not implemented');
      throw e;
    }
  }

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
      await _channel.invokeMethod(methodGetImage,
          {paramImageUri: imageUri, paramImageDimension: imageDimension});
    } on PlatformException catch (e) {
      _logger.i('$methodAddToLibrary failed: ${e.message}');
      throw e;
    } on MissingPluginException catch (e) {
      _logger.i('$methodAddToLibrary not implemented');
      throw e;
    }
  }
}

enum ImageDimension { large, medium, small, x_small, thumbnail }
