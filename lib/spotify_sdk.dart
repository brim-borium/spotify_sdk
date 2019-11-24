import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:logger/logger.dart';

class SpotifySdk {
  static final String methodConnectToSpotify = "connectToSpotify";
  static final String methodLogoutFromSpotify = "logoutFromSpotify";
  static final String methodQueueTrack = "queueTrack";
  static final String methodPlay = "play";
  static final String methodPause = "pause";
  static final String methodToggleRepeat = "toggleRepeat";
  static final String methodToggleShuffle = "toggleShuffle";
  static final String methodAddToLibrary = "addToLibrary";

  static final String paramClientId = "clientId";
  static final String paramRedirectUrl = "redirectUrl";
  static final String paramSpotifyUri = "spotifyUri";
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
}
