@JS()
library spotify_sdk;

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:html';
import 'dart:js';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:js/js.dart';
import 'package:js/js_util.dart';
import 'package:spotify_sdk/models/album.dart';
import 'package:spotify_sdk/models/artist.dart';
import 'package:spotify_sdk/models/image_uri.dart';
import 'package:spotify_sdk/models/player_context.dart';
import 'package:spotify_sdk/models/player_options.dart' as options;
import 'package:spotify_sdk/models/player_restrictions.dart';
import 'package:spotify_sdk/models/player_state.dart';
import 'package:spotify_sdk/models/track.dart';
import 'package:spotify_sdk/platform_channels.dart';

///
/// [SpotifySdkPlugin] holds the functionality to connect via spotify remote or
/// get an authToken to control the spotify playback and use the functionality
/// described [here](https://pub.dev/packages/spotify_sdk#web)
///
class SpotifySdkPlugin {
  /// Initializes the Web Package with [_playerContextEventController],
  /// [_playerStateEventController], [_playerCapabilitiesEventController],
  /// [_userStateEventController] and calls [_initializeSpotify]
  SpotifySdkPlugin(
      this._playerContextEventController,
      this._playerStateEventController,
      this._playerCapabilitiesEventController,
      this._userStateEventController) {
    _initializeSpotify();
  }

  // spotify sdk url
  static const String _spotifySdkUrl = 'https://sdk.scdn.co/spotify-player.js';

  // auth
  static const List<String> _authenticationScopes = [
    'app-remote-control',
    'user-modify-playback-state',
    'playlist-read-private',
    'playlist-modify-public',
    'user-read-currently-playing'
  ];

  /// Whether the Spotify SDK was already loaded.
  bool _sdkLoaded = false;

  /// Current Spotify SDK player instance.
  Player _currentPlayer;

  /// Current Spotify auth token.
  SpotifyToken _spotifyToken;

  /// Cached client id used when connecting to Spotify.
  String cachedClientId;

  /// Cached redirect url used when connecting to Spotify.
  String cachedRedirectUrl;

  // Event stream controllers
  final StreamController _playerContextEventController;
  final StreamController _playerStateEventController;
  // ignore: unused_field
  final StreamController _playerCapabilitiesEventController;
  // ignore: unused_field
  final StreamController _userStateEventController;

  /// Dio http client
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://api.spotify.com/v1/me/player',
  ));

  /// Initial registering
  static void registerWith(Registrar registrar) {
    // method channel
    final channel = MethodChannel(MethodChannels.spotifySdk,
        const StandardMethodCodec(), registrar.messenger);
    // event channels
    final playerContextEventChannel =
        const PluginEventChannel(EventChannels.playerContext);
    final playerContextEventController = StreamController.broadcast();
    playerContextEventChannel.controller = playerContextEventController;
    final playerStateEventChannel =
        const PluginEventChannel(EventChannels.playerState);
    final playerStateEventController = StreamController.broadcast();
    playerStateEventChannel.controller = playerStateEventController;
    final playerCapabilitiesEventChannel =
        const PluginEventChannel(EventChannels.capabilities);
    final playerCapabilitiesEventController = StreamController.broadcast();
    playerCapabilitiesEventChannel.controller =
        playerCapabilitiesEventController;
    final userStatusEventChannel =
        const PluginEventChannel(EventChannels.userStatus);
    final userStatusEventController = StreamController.broadcast();
    userStatusEventChannel.controller = userStatusEventController;

    final instance = SpotifySdkPlugin(
        playerContextEventController,
        playerStateEventController,
        playerCapabilitiesEventController,
        userStatusEventController);

    channel.setMethodCallHandler(instance.handleMethodCall);
  }

  /// check if spotify is loaded
  Future<dynamic> handleMethodCall(MethodCall call) async {
    if (_sdkLoaded == false) {
      throw PlatformException(
          code: 'Uninitialized',
          details: "The Spotify SDK wasn't initialized yet");
    }

    switch (call.method) {
      case MethodNames.connectToSpotify:
        log('Connecting to Spotify...');
        if (_currentPlayer != null) {
          return true;
        }
        // update the client id and redirect url
        var clientId = call.arguments[ParamNames.clientId] as String;
        var redirectUrl = call.arguments[ParamNames.redirectUrl] as String;
        var playerName = call.arguments[ParamNames.playerName] as String;
        if (!(clientId?.isNotEmpty == true &&
            redirectUrl?.isNotEmpty == true)) {
          throw PlatformException(
              message:
                  'Client id or redirectUrl are not set or have invalid format',
              code: 'Authentication Error');
        }
        cachedClientId = clientId;
        cachedRedirectUrl = redirectUrl;

        // get initial token
        await _getSpotifyAuthToken();

        // create player
        _currentPlayer = Player(PlayerOptions(
            name: playerName,
            getOAuthToken: allowInterop((Function callback, t) {
              _getSpotifyAuthToken().then((value) {
                callback(value);
              });
            })));

        _registerPlayerEvents(_currentPlayer);
        var result = await promiseToFuture(_currentPlayer.connect());
        if (result == false) {
          return false;
        } else {
          // wait for the ready event
          while (_currentPlayer != null) {
            if (_currentPlayer.deviceID?.isNotEmpty == true) {
              return true;
            }
            await Future.delayed(const Duration(milliseconds: 250));
          }
          return false;
        }
        break;
      case MethodNames.getAuthenticationToken:
        return await _getSpotifyAuthToken(
            clientId: call.arguments[ParamNames.clientId] as String,
            redirectUrl: call.arguments[ParamNames.redirectUrl] as String);
        break;
      case MethodNames.logoutFromSpotify:
        log('Disconnecting from Spotify...');
        if (_currentPlayer == null) {
          return false;
        } else {
          _unregisterPlayerEvents(_currentPlayer);
          _currentPlayer.disconnect();
          _currentPlayer = null;
          return true;
        }
        break;
      case MethodNames.play:
        await _play(call.arguments[ParamNames.spotifyUri] as String);
        break;
      case MethodNames.queueTrack:
        await _queue(call.arguments[ParamNames.spotifyUri] as String);
        break;
      case MethodNames.resume:
        await promiseToFuture(_currentPlayer?.resume());
        break;
      case MethodNames.pause:
        await promiseToFuture(_currentPlayer?.pause());
        break;
      case MethodNames.skipNext:
        await promiseToFuture(_currentPlayer?.nextTrack());
        break;
      case MethodNames.skipPrevious:
        await promiseToFuture(_currentPlayer?.previousTrack());
        break;
      /*case METHOD_TOGGLE_SHUFFLE:
        //TODO: Needs a state parameter (true/false)
        //await _currentPlayer?.toggleShuffle(state, await _getSpotifyAuthToken());
      break;*/
      /*case METHOD_TOGGLE_REPEAT:
        //TODO: Needs a state parameter (true/false)
        //await _currentPlayer?.toggleRepeat(state, await _getSpotifyAuthToken());
      break;*/
      case MethodNames.getPlayerState:
        var stateRaw = await promiseToFuture(_currentPlayer?.getCurrentState());
        if (stateRaw == null) return null;
        return jsonEncode(toPlayerState(stateRaw as WebPlaybackState).toJson());
        break;
      default:
        throw PlatformException(
            code: 'Unimplemented',
            details:
                "The spotify_sdk plugin for web doesn't implement the method "
                "'${call.method}'");
    }
  }

  /// Loads the Spotify SDK library.
  _initializeSpotify() {
    context['onSpotifyWebPlaybackSDKReady'] =
        allowInterop(_onSpotifyInitialized);
    querySelector('body').children.add(ScriptElement()..src = _spotifySdkUrl);
  }

  /// Called when the Spotify library is loaded.
  _onSpotifyInitialized() {
    log('Spotify Initialized!');
    _sdkLoaded = true;
  }

  /// Registers Spotify event handlers.
  _registerPlayerEvents(Player player) {
    // player state
    player
      ..addListener('player_state_changed',
          allowInterop((WebPlaybackState state) {
        if (state == null) return;
        _playerStateEventController
            .add(jsonEncode(toPlayerState(state).toJson()));
        _playerContextEventController
            .add(jsonEncode(toPlayerContext(state).toJson()));
      }))
      // ready/not ready
      ..addListener('ready', allowInterop((WebPlaybackPlayer player) {
        log('Device ready! ${player?.deviceId}');
        _currentPlayer.deviceID = player.deviceId;
      }))
      ..addListener('not_ready', allowInterop((event) {
        log('Device not ready!');
        _currentPlayer.deviceID = null;
      }))
      // errors
      ..addListener('initialization_error',
          allowInterop((WebPlaybackError error) {
        log('initialization_error: ${error.message}');
        _currentPlayer = null;
      }))
      ..addListener('authentication_error',
          allowInterop((WebPlaybackError error) {
        log('authentication_error: ${error.message}');
        _currentPlayer = null;
      }))
      ..addListener('account_error', allowInterop((WebPlaybackError error) {
        log('account_error: ${error.message}');
        _currentPlayer = null;
      }))
      ..addListener('playback_error', allowInterop((WebPlaybackError error) {
        log('playback_error: ${error.message}');
      }));
  }

  _unregisterPlayerEvents(Player player) {
    player
      ..removeListener('player_state_changed')
      ..removeListener('ready')
      ..removeListener('not_ready')
      ..removeListener('initialization_error')
      ..removeListener('authentication_error')
      ..removeListener('account_error')
      ..removeListener('playback_error');
  }

  /// Gets the current Spotify token or reauthenticates the user if the token
  /// expired.
  Future<String> _getSpotifyAuthToken(
      {String clientId, String redirectUrl}) async {
    if (_spotifyToken != null &&
        _spotifyToken.expiry > DateTime.now().millisecondsSinceEpoch) {
      return _spotifyToken.token;
    }

    clientId ??= cachedClientId;
    redirectUrl ??= cachedRedirectUrl;
    var newToken = await _authenticateSpotify(clientId, redirectUrl);
    _spotifyToken =
        SpotifyToken(newToken, DateTime.now().millisecondsSinceEpoch + 3600000);
    return _spotifyToken.token;
  }

  /// Authenticates the user and returns the access token on success.
  Future<String> _authenticateSpotify(
      String clientId, String redirectUrl) async {
    if (clientId?.isNotEmpty == true && redirectUrl?.isNotEmpty == true) {
      var scopes = _authenticationScopes.join(' ');
      var authUrl =
          'https://accounts.spotify.com/authorize?client_id=$clientId&response_type=token&scope=$scopes&redirect_uri=$redirectUrl';

      var authPopup = window.open(authUrl, 'Spotify Authorization');
      String hash;
      String error;
      var sub = window.onMessage.listen(allowInterop((event) {
        var message = event.data.toString();
        if (message.startsWith('#')) {
          log('Hash received: ${event.data}');
          hash = message;
        } else if (message.startsWith('?')) {
          log('Authorization error: ${event.data}');
          error = message;
        }
      }));

      // loop and wait for auth
      while (authPopup.closed == false && hash == null && error == null) {
        // await response from the window
        await Future.delayed(const Duration(milliseconds: 250));
      }

      // cleanup
      if (authPopup.closed == false) {
        authPopup.close();
      }
      await sub.cancel();

      // check output
      if (error != null || hash == null) {
        throw PlatformException(
            message: '$error', code: 'Authentication Error');
      }
      return hash.split('&')[0].split('=')[1];
    } else {
      throw PlatformException(
          message:
              'Client id or redirectUrl are not set or have invalid format',
          code: 'Authentication Error');
    }
  }

  /// Starts track playback on the device.
  Future _play(String uri) async {
    if (_currentPlayer?.deviceID == null) {
      throw PlatformException(
          message: 'Spotify player not connected!', code: 'Playback Error');
    }

    await _dio.put(
      '/play',
      data: {
        'uris': [uri]
      },
      queryParameters: {'device_id': _currentPlayer.deviceID},
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getSpotifyAuthToken()}'
        },
      ),
    );
  }

  /// Adds a given track to the playback queue.
  Future _queue(String uri) async {
    if (_currentPlayer?.deviceID == null) {
      throw PlatformException(
          message: 'Spotify player not connected!', code: 'Playback Error');
    }

    await _dio.post(
      '/add-to-queue',
      queryParameters: {'uri': uri, 'device_id': _currentPlayer.deviceID},
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getSpotifyAuthToken()}'
        },
      ),
    );
  }

  /// Toggles shuffle on the current player.
  Future toggleShuffle(bool state) async {
    if (_currentPlayer?.deviceID == null) {
      throw PlatformException(
          message: 'Spotify player not connected!', code: 'Playback Error');
    }

    await _dio.put(
      'https://api.spotify.com/v1/me/player/shuffle',
      queryParameters: {'state': state, 'device_id': _currentPlayer.deviceID},
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getSpotifyAuthToken()}'
        },
      ),
    );
  }

  /// Toggles repeat on the current player.
  Future toggleRepeat(bool state) async {
    if (_currentPlayer?.deviceID == null) {
      throw PlatformException(
          message: 'Spotify player not connected!', code: 'Playback Error');
    }

    await _dio.put(
      'https://api.spotify.com/v1/me/player/repeat',
      queryParameters: {'state': state, 'device_id': _currentPlayer.deviceID},
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getSpotifyAuthToken()}'
        },
      ),
    );
  }

  /// Converts a native WebPlaybackState to the library PlayerState
  PlayerState toPlayerState(WebPlaybackState state) {
    if (state == null) return null;
    var trackRaw = state.trackWindow?.currentTrack;
    var albumRaw = trackRaw?.album;
    var restrictionsRaw = state.disallows;
    var artists = <Artist>[];
    for (var artist in trackRaw.artists) {
      artists.add(Artist(artist.name, artist.uri));
    }

    // getting repeat mode
    options.RepeatMode repeatMode;
    switch (state.repeatMode) {
      case 1:
        repeatMode = options.RepeatMode.Context;
        break;
      case 2:
        repeatMode = options.RepeatMode.Track;
        break;
      default:
        repeatMode = options.RepeatMode.Off;
        break;
    }

    return PlayerState(
        trackRaw != null
            ? Track(
                Album(albumRaw.name, albumRaw.uri),
                artists[0],
                artists,
                null,
                ImageUri(albumRaw.images[0].url),
                false,
                false,
                trackRaw.name,
                trackRaw.uri)
            : null,
        state.paused,
        1.0,
        state.position,
        options.PlayerOptions(state.shuffle, repeatMode),
        PlayerRestrictions(
            restrictionsRaw.skippingNext,
            restrictionsRaw.skippingPrev,
            false,
            false,
            false,
            restrictionsRaw.seeking));
  }

  /// Converts a native WebPlaybackState to the library PlayerContext
  PlayerContext toPlayerContext(WebPlaybackState state) {
    if (state == null) return null;
    return PlayerContext(
        state.context.metadata.title,
        state.context.metadata.subtitle,
        state.context.metadata.type,
        state.context.uri);
  }
}

/// Spotify Player Object
@JS('Spotify.Player')
class Player {
  /// The main constructor for initializing the Web Playback SDK. It should
  /// contain an object with the player name, volume and access token.
  external Player(PlayerOptions options);

  /// Device id of the player.
  String deviceID;

  /// Connects Web Playback SDK instance to Spotify with the credentials
  /// provided during initialization.
  external dynamic connect();

  /// Closes the current session that Web Playback SDK has with Spotify.
  external void disconnect();

  /// Create a new event listener in the Web Playback SDK.
  external void addListener(String type, Function callback);

  /// Remove an event listener in the Web Playback SDK.
  external void removeListener(String eventName);

  /// Collect metadata on local playback.
  external dynamic getCurrentState();

  /// Rename the Spotify Player device. This is visible across all
  /// Spotify Connect devices.
  external dynamic setName(String name);

  /// Set the local volume for the Web Playback SDK.
  external dynamic setVolume(double volume);

  /// Pause the local playback.
  external dynamic pause();

  /// Resume the local playback.
  external dynamic resume();

  /// Resume/pause the local playback.
  external dynamic togglePlay();

  /// Seek to a position in the current track in local playback.
  external dynamic seek(int positionMs);

  /// Switch to the previous track in local playback.
  external dynamic previousTrack();

  /// Skip to the next track in local playback.
  external dynamic nextTrack();
}

@JS()
@anonymous

// ignore: public_member_api_docs
class PlayerOptions {
  // ignore: public_member_api_docs
  external factory PlayerOptions(
      {String name, Function getOAuthToken, double volume});

  // ignore: public_member_api_docs
  external String get name;
  // ignore: public_member_api_docs
  external Function get getOAuthToken;
  // ignore: public_member_api_docs
  external double get volume;
}

@JS()
@anonymous
// ignore: public_member_api_docs
class WebPlaybackPlayer {
  // ignore: public_member_api_docs
  external factory WebPlaybackPlayer({String deviceId});
  // ignore: public_member_api_docs
  external String get deviceId;
}

@JS()
@anonymous
// ignore: public_member_api_docs
class WebPlaybackState {
  // ignore: public_member_api_docs
  external factory WebPlaybackState(
      {WebPlayerContext context,
      WebPlayerDisallows disallows,
      bool paused,
      int position,
      int repeatMode,
      bool shuffle,
      WebPlayerTrackWindow trackWindow});

  // ignore: public_member_api_docs
  external WebPlayerContext get context;
  // ignore: public_member_api_docs
  external WebPlayerDisallows get disallows;
  // ignore: public_member_api_docs
  external bool get paused;
  // ignore: public_member_api_docs
  external int get position;
  // ignore: public_member_api_docs
  external int get repeatMode;
  // ignore: public_member_api_docs
  external bool get shuffle;
  // ignore: public_member_api_docs
  external WebPlayerTrackWindow get trackWindow;
}

@JS()
@anonymous
// ignore: public_member_api_docs
class WebPlayerContext {
// ignore: public_member_api_docs
  external factory WebPlayerContext(
      {String uri, WebPlayerContextMetadata metadata});

// ignore: public_member_api_docs
  external String get uri;
// ignore: public_member_api_docs
  external WebPlayerContextMetadata get metadata;
}

@JS()
@anonymous
// ignore: public_member_api_docs
class WebPlayerContextMetadata {
// ignore: public_member_api_docs
  external factory WebPlayerContextMetadata(
      {String title, String subtitle, String type});

// ignore: public_member_api_docs
  external String get title;
// ignore: public_member_api_docs
  external String get subtitle;
// ignore: public_member_api_docs
  external String get type;
}

@JS()
@anonymous
// ignore: public_member_api_docs
class WebPlayerDisallows {
// ignore: public_member_api_docs
  external factory WebPlayerDisallows(
      {bool pausing,
      bool peekingNext,
      bool peekingPrev,
      bool resuming,
      bool seeking,
      bool skippingNext,
      bool skippingPrev});

// ignore: public_member_api_docs
  external bool get pausing;
// ignore: public_member_api_docs
  external bool get peekingNext;
// ignore: public_member_api_docs
  external bool get peekingPrev;
// ignore: public_member_api_docs
  external bool get resuming;
// ignore: public_member_api_docs
  external bool get seeking;
// ignore: public_member_api_docs
  external bool get skippingNext;
// ignore: public_member_api_docs
  external bool get skippingPrev;
}

@JS()
@anonymous
// ignore: public_member_api_docs
class WebPlayerTrackWindow {
// ignore: public_member_api_docs
  external factory WebPlayerTrackWindow(
      {WebPlaybackTrack currentTrack,
      List<WebPlaybackTrack> previousTracks,
      List<WebPlaybackTrack> nextTracks});

// ignore: public_member_api_docs
  external WebPlaybackTrack get currentTrack;
// ignore: public_member_api_docs
  external List<WebPlaybackTrack> get previousTracks;
// ignore: public_member_api_docs
  external List<WebPlaybackTrack> get nextTracks;
}

@JS()
@anonymous
// ignore: public_member_api_docs
class WebPlaybackTrack {
  // ignore: public_member_api_docs
  external factory WebPlaybackTrack(
      {String uri,
      String id,
      String type,
      String mediaType,
      String name,
      bool isPlayable,
      WebPlaybackAlbum album,
      List<WebPlaybackArtist> artists});
  // ignore: public_member_api_docs
  external String get uri;
  // ignore: public_member_api_docs
  external String get id;
  // ignore: public_member_api_docs
  external String get type;
  // ignore: public_member_api_docs
  external String get mediaType;
  // ignore: public_member_api_docs
  external String get name;
  // ignore: public_member_api_docs
  external bool get isPlayable;
  // ignore: public_member_api_docs
  external WebPlaybackAlbum get album;
  // ignore: public_member_api_docs
  external List<WebPlaybackArtist> get artists;
}

@JS()
@anonymous
// ignore: public_member_api_docs
class WebPlaybackAlbum {
  // ignore: public_member_api_docs
  external factory WebPlaybackAlbum(
      {String uri, String name, List<WebPlaybackAlbumImage> images});

  // ignore: public_member_api_docs
  external String get uri;
  // ignore: public_member_api_docs
  external String get name;
  // ignore: public_member_api_docs
  external List<WebPlaybackAlbumImage> get images;
}

@JS()
@anonymous
// ignore: public_member_api_docs
class WebPlaybackArtist {
  // ignore: public_member_api_docs
  external factory WebPlaybackArtist({String uri, String name});

  // ignore: public_member_api_docs
  external String get uri;
  // ignore: public_member_api_docs
  external String get name;
}

@JS()
@anonymous
// ignore: public_member_api_docs
class WebPlaybackAlbumImage {
  // ignore: public_member_api_docs
  external factory WebPlaybackAlbumImage({String url});

  // ignore: public_member_api_docs
  external String get url;
}

@JS()
@anonymous
// ignore: public_member_api_docs
class WebPlaybackError {
  // ignore: public_member_api_docs
  external factory WebPlaybackError({String message});

  // ignore: public_member_api_docs
  external String get message;
}

// ignore: public_member_api_docs
class SpotifyToken {
  // ignore: public_member_api_docs
  SpotifyToken(this.token, this.expiry);

  // ignore: public_member_api_docs
  final String token;

  // ignore: public_member_api_docs
  final int expiry;
}
