import 'dart:async';
import 'dart:developer';
import 'dart:js_interop';

import 'package:spotify_sdk_web/src/interop/web_playback_sdk.dart';
import 'package:web/web.dart' as web;

/// Encapsulates Web Playback SDK script injection and readiness callbacks.
class WebSdkLoader {
  /// Default Spotify Web Playback SDK script URL.
  static const String spotifySdkUrl = 'https://sdk.scdn.co/spotify-player.js';

  bool _sdkLoaded = false;
  Completer<void>? _loadCompleter;

  /// Whether the SDK is currently loaded.
  bool get isLoaded => _sdkLoaded;

  /// Ensures that the Spotify Web Playback SDK script is injected and ready.
  Future<void> ensureSdkLoaded({String scriptUrl = spotifySdkUrl}) async {
    if (_sdkLoaded) {
      return;
    }
    if (_loadCompleter != null) {
      return _loadCompleter!.future;
    }

    _loadCompleter = Completer<void>();

    if (onSpotifyWebPlaybackSDKReady != null) {
      log('Reusing previously initialized Spotify Web SDK');
      _sdkLoaded = true;
      _loadCompleter!.complete();
      return _loadCompleter!.future;
    }

    log('Loading Spotify Web SDK script...');
    onSpotifyWebPlaybackSDKReady = (() {
      _sdkLoaded = true;
      if (!(_loadCompleter?.isCompleted ?? true)) {
        _loadCompleter!.complete();
      }
    }).toJS;

    final script = web.HTMLScriptElement()..src = scriptUrl;
    web.document.body?.append(script);

    return _loadCompleter!.future;
  }
}
