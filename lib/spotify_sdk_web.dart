@JS()
library spotify_sdk_web;

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

import 'models/album.dart';
import 'models/artist.dart';
import 'models/connection_status.dart';
import 'models/image_uri.dart';
import 'models/player_context.dart';
import 'models/player_options.dart' as options;
import 'models/player_restrictions.dart';
import 'models/player_state.dart';
import 'models/track.dart';
import 'platform_channels.dart';
import 'spotify_sdk.dart';

///
/// [SpotifySdkPlugin] is the web implementation of the Spotify SDK plugin.
///
class SpotifySdkPlugin {
  /// authentication token error id
  static const String errorAuthenticationTokenError =
      'authenticationTokenError';

  /// spotify sdk url
  static const String spotifySdkUrl = 'https://sdk.scdn.co/spotify-player.js';

  /// spotify auth scopes
  static const List<String> authenticationScopes = [
    'streaming',
    'user-read-email',
    'user-read-private',
    'app-remote-control',
    'user-modify-playback-state',
    'playlist-read-private',
    'playlist-modify-public',
    'user-read-currently-playing'
  ];

  /// Whether the Spotify SDK is loaded.
  bool _sdkLoaded = false;

  /// Current Spotify SDK player instance.
  Player _currentPlayer;

  /// Current Spotify auth token.
  SpotifyToken _spotifyToken;

  /// Cached client id used when connecting to Spotify.
  String cachedClientId;

  /// Cached redirect url used when connecting to Spotify.
  String cachedRedirectUrl;

  /// player context event stream controller
  final StreamController playerContextEventController;

  /// player state event stream controller
  final StreamController playerStateEventController;

  /// player capabilities event stream controller
  final StreamController playerCapabilitiesEventController;

  /// user state event stream controller
  final StreamController userStateEventController;

  /// connection status event stream controller
  final StreamController connectionStatusEventController;

  /// Dio http client
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://api.spotify.com/v1/me/player',
  ));

  /// constructor
  SpotifySdkPlugin(
      this.playerContextEventController,
      this.playerStateEventController,
      this.playerCapabilitiesEventController,
      this.userStateEventController,
      this.connectionStatusEventController) {
    _initializeSpotify();
  }

  /// registers plugin method channels
  static void registerWith(Registrar registrar) {
    // method channel
    final channel = MethodChannel(MethodChannels.spotifySdk,
        const StandardMethodCodec(), registrar.messenger);
    // event channels
    final playerContextEventChannel =
        PluginEventChannel(EventChannels.playerContext);
    final playerContextEventController = StreamController.broadcast();
    playerContextEventChannel.controller = playerContextEventController;
    final playerStateEventChannel =
        PluginEventChannel(EventChannels.playerState);
    final playerStateEventController = StreamController.broadcast();
    playerStateEventChannel.controller = playerStateEventController;
    final playerCapabilitiesEventChannel =
        PluginEventChannel(EventChannels.capabilities);
    final playerCapabilitiesEventController = StreamController.broadcast();
    playerCapabilitiesEventChannel.controller =
        playerCapabilitiesEventController;
    final userStatusEventChannel = PluginEventChannel(EventChannels.userStatus);
    final userStatusEventController = StreamController.broadcast();
    userStatusEventChannel.controller = userStatusEventController;
    final connectionStatusEventChannel =
        PluginEventChannel(EventChannels.connectionStatus);
    final connectionStatusEventController = StreamController.broadcast();
    connectionStatusEventChannel.controller = connectionStatusEventController;

    final instance = SpotifySdkPlugin(
        playerContextEventController,
        playerStateEventController,
        playerCapabilitiesEventController,
        userStatusEventController,
        connectionStatusEventController);

    channel.setMethodCallHandler(instance.handleMethodCall);
  }

  /// handles method coming through the method channel
  Future<dynamic> handleMethodCall(MethodCall call) async {
    // check if spotify is loaded
    if (_sdkLoaded == false) {
      throw PlatformException(
          code: 'Uninitialized',
          details: "The Spotify SDK wasn't initialized yet");
    }

    switch (call.method) {
      case MethodNames.connectToSpotify:
        if (_currentPlayer != null) {
          return true;
        }
        log('Connecting to Spotify...');
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
        if (result == true) {
          // wait for the confirmation
          num time = 0;
          while (_currentPlayer.deviceID == null) {
            await Future.delayed(Duration(milliseconds: 200));
            time += 200;
            if (time > 10000) {
              return false;
            }
          }
          return true;
        } else {
          // disconnected
          _onSpotifyDisconected(
              errorCode: 'Initialization Error',
              errorDetails: 'Attempt to connect to the Spotify SDK failed');
          return false;
        }
        break;
      case MethodNames.getAuthenticationToken:
        return await _getSpotifyAuthToken(
            clientId: call.arguments[ParamNames.clientId] as String,
            redirectUrl: call.arguments[ParamNames.redirectUrl] as String);
        break;
      case MethodNames.disconnectFromSpotify:
        log('Disconnecting from Spotify...');
        if (_currentPlayer == null) {
          return true;
        } else {
          _currentPlayer.disconnect();
          _onSpotifyDisconected();
          return true;
        }
        break;
      case MethodNames.play:
        await _play(call.arguments[ParamNames.spotifyUri] as String);
        break;
      case MethodNames.queueTrack:
        await _queue(call.arguments[ParamNames.spotifyUri] as String);
        break;
      case MethodNames.setShuffle:
        await _setShuffle(call.arguments[ParamNames.shuffle] as bool);
        break;
      case MethodNames.setRepeatMode:
        await _setRepeatMode(
            call.arguments[ParamNames.repeatMode] as RepeatMode);
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
      case MethodNames.getPlayerState:
        var stateRaw = await promiseToFuture(_currentPlayer?.getCurrentState())
            as WebPlaybackState;
        if (stateRaw == null) return null;
        return jsonEncode(toPlayerState(stateRaw).toJson());
        break;
      default:
        throw PlatformException(
            code: 'Unimplemented',
            details:
                "Method '${call.method}' not implemented in web spotify_sdk");
    }
  }

  /// Loads the Spotify SDK library.
  void _initializeSpotify() {
    if (context['onSpotifyWebPlaybackSDKReady'] == null) {
      // load spotify sdk
      context['onSpotifyWebPlaybackSDKReady'] =
          allowInterop(_onSpotifyInitialized);
      querySelector('body').children.add(ScriptElement()..src = spotifySdkUrl);
    } else {
      // spotify sdk already loaded
      log('Reusing loaded Spotify SDK!');
      _sdkLoaded = true;
    }
  }

  /// Registers Spotify event handlers.
  void _registerPlayerEvents(Player player) {
    // player state
    player.addListener('player_state_changed',
        allowInterop((WebPlaybackState state) {
      if (state == null) return;
      playerStateEventController.add(jsonEncode(toPlayerState(state).toJson()));
      playerContextEventController
          .add(jsonEncode(toPlayerContext(state).toJson()));
    }));

    // ready/not ready
    player.addListener('ready', allowInterop((WebPlaybackPlayer player) {
      log('Spotify SDK ready!');
      _onSpotifyConnected(player.device_id);
    }));
    player.addListener('not_ready', allowInterop((event) {
      _onSpotifyDisconected(
          errorCode: 'Spotify SDK not ready',
          errorDetails: 'Spotify SDK is not ready to take requests');
    }));

    // errors
    player.addListener('initialization_error',
        allowInterop((WebPlaybackError error) {
      _onSpotifyDisconected(
          errorCode: 'Initialization Error', errorDetails: error.message);
    }));
    player.addListener('authentication_error',
        allowInterop((WebPlaybackError error) {
      _onSpotifyDisconected(
          errorCode: 'Authentication Error', errorDetails: error.message);
    }));
    player.addListener('account_error', allowInterop((WebPlaybackError error) {
      _onSpotifyDisconected(
          errorCode: 'Account Error', errorDetails: error.message);
    }));
    player.addListener('playback_error', allowInterop((WebPlaybackError error) {
      log('playback_error: ${error.message}');
    }));
  }

  /// Called when the Spotify SDK is first loaded.
  void _onSpotifyInitialized() {
    log('Spotify SDK loaded!');
    _sdkLoaded = true;
  }

  /// Called when the plugin successfully connects to the spotify web sdk.
  void _onSpotifyConnected(String deviceId) {
    _currentPlayer.deviceID = deviceId;

    // emit connected event
    connectionStatusEventController.add(jsonEncode(ConnectionStatus(
      'Spotify SDK connected',
      null,
      null,
      connected: true,
    ).toJson()));
  }

  /// Called when the plugin disconects from the spotify sdk.
  void _onSpotifyDisconected({String errorCode, String errorDetails}) {
    _unregisterPlayerEvents(_currentPlayer);
    _currentPlayer = null;

    if (errorCode != null) {
      // disconnected due to error
      log('$errorCode: $errorDetails');
    }

    // emit not connected event
    connectionStatusEventController.add(jsonEncode(ConnectionStatus(
            'Spotify SDK disconnected', errorCode, errorDetails,
            connected: false)
        .toJson()));
  }

  void _unregisterPlayerEvents(Player player) {
    player.removeListener('player_state_changed');
    player.removeListener('ready');
    player.removeListener('not_ready');
    player.removeListener('initialization_error');
    player.removeListener('authentication_error');
    player.removeListener('account_error');
    player.removeListener('playback_error');
  }

  /// Gets the current Spotify token or
  /// reauthenticates the user if the token expired.
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
      var scopes = authenticationScopes.join(' ');
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
        await Future.delayed(Duration(milliseconds: 250));
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

  /// Sets whether shuffle should be enabled.
  Future _setShuffle(bool shuffleEnabled) async {
    if (_currentPlayer?.deviceID == null) {
      throw PlatformException(
          message: "Spotify player not connected!", code: "Set Shuffle Error");
    }

    await _dio.put(
      '/shuffle',
      queryParameters: {
        'state': shuffleEnabled,
        'device_id': _currentPlayer.deviceID
      },
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getSpotifyAuthToken()}'
        },
      ),
    );
  }

  /// Sets the repeat mode.
  Future _setRepeatMode(RepeatMode repeatMode) async {
    if (_currentPlayer?.deviceID == null) {
      throw PlatformException(
          message: "Spotify player not connected!",
          code: "Set Repeat Mode Error");
    }

    await _dio.put(
      '/repeat',
      queryParameters: {
        'state': repeatMode.toString().substring(11),
        'device_id': _currentPlayer.deviceID
      },
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getSpotifyAuthToken()}'
        },
      ),
    );
  }

  /// Toggles shuffle on the current player.
  Future toggleShuffle({bool state}) async {
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
  Future toggleRepeat({bool state}) async {
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
    var trackRaw = state.track_window?.current_track;
    var albumRaw = trackRaw?.album;
    var restrictionsRaw = state.disallows;
    var artists = <Artist>[];
    for (var artist in trackRaw.artists) {
      artists.add(Artist(artist.name, artist.uri));
    }

    // getting repeat mode
    options.RepeatMode repeatMode;
    switch (state.repeat_mode) {
      case 1:
        repeatMode = options.RepeatMode.context;
        break;
      case 2:
        repeatMode = options.RepeatMode.track;
        break;
      default:
        repeatMode = options.RepeatMode.off;
        break;
    }

    return PlayerState(
      trackRaw != null
          ? Track(
              Album(albumRaw.name, albumRaw.uri),
              artists[0],
              artists,
              null,
              ImageUri(albumRaw.images[0]?.url),
              trackRaw.name,
              trackRaw.uri,
              isEpisode: trackRaw.type == 'episode',
              isPodcast: trackRaw.type == 'episode',
            )
          : null,
      1.0,
      state.position,
      options.PlayerOptions(repeatMode, isShuffling: state.shuffle),
      PlayerRestrictions(
          canSkipNext: restrictionsRaw.skipping_next,
          canSkipPrevious: restrictionsRaw.skipping_prev,
          canSeek: restrictionsRaw.seeking,
          canRepeatTrack: true,
          canRepeatContext: true,
          canToggleShuffle: true),
      isPaused: state.paused,
    );
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
  /// Device id of the player.
  String deviceID;

  /// The main constructor for initializing the Web Playback SDK.
  /// It should contain an object with the player name, volume and access token.
  external Player(PlayerOptions options);

  /// Connects Web Playback SDK instance to Spotify
  /// with the credentials provided during initialization.
  external dynamic connect();

  /// Closes the current session that Web Playback SDK has with Spotify.
  external void disconnect();

  /// Create a new event listener in the Web Playback SDK.
  external void addListener(String type, Function callback);

  /// Remove an event listener in the Web Playback SDK.
  // ignore: non_constant_identifier_names
  external void removeListener(String event_name);

  /// Collect metadata on local playback.
  external dynamic getCurrentState();

  /// Rename the Spotify Player device.
  /// This is visible across all Spotify Connect devices.
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
  // ignore: non_constant_identifier_names
  external dynamic seek(int position_ms);

  /// Switch to the previous track in local playback.
  external dynamic previousTrack();

  /// Skip to the next track in local playback.
  external dynamic nextTrack();
}

/// Spotify player options object
@JS()
@anonymous
class PlayerOptions {
  // ignore: public_member_api_docs
  external String get name;
  // ignore: public_member_api_docs
  external Function get getOAuthToken;
  // ignore: public_member_api_docs
  external double get volume;

  // ignore: public_member_api_docs
  external factory PlayerOptions(
      {String name, Function getOAuthToken, double volume});
}

/// Spotify playback object
@JS()
@anonymous
class WebPlaybackPlayer {
  // ignore: public_member_api_docs, non_constant_identifier_names
  external String get device_id;
  // ignore: public_member_api_docs, non_constant_identifier_names
  external factory WebPlaybackPlayer({String device_id});
}

/// Spotify playback state object
@JS()
@anonymous
class WebPlaybackState {
  // ignore: public_member_api_docs
  external WebPlayerContext get context;
  // ignore: public_member_api_docs
  external WebPlayerDisallows get disallows;
  // ignore: public_member_api_docs
  external bool get paused;
  // ignore: public_member_api_docs
  external int get position;
  // ignore: public_member_api_docs, non_constant_identifier_names
  external int get repeat_mode;
  // ignore: public_member_api_docs
  external bool get shuffle;
  // ignore: public_member_api_docs, non_constant_identifier_names
  external WebPlayerTrackWindow get track_window;

  // ignore: public_member_api_docs
  external factory WebPlaybackState(
      {WebPlayerContext context,
      WebPlayerDisallows disallows,
      bool paysed,
      int position,
      // ignore: non_constant_identifier_names
      int repeat_mode,
      bool shuffle,
      // ignore: non_constant_identifier_names
      WebPlayerTrackWindow track_window});
}

/// Spotify player context object
@JS()
@anonymous
class WebPlayerContext {
  // ignore: public_member_api_docs
  external String get uri;
  // ignore: public_member_api_docs
  external WebPlayerContextMetadata get metadata;

  // ignore: public_member_api_docs
  external factory WebPlayerContext(
      {String uri, WebPlayerContextMetadata metadata});
}

/// Spotify player context metadata object
@JS()
@anonymous
class WebPlayerContextMetadata {
  // ignore: public_member_api_docs
  external String get title;
  // ignore: public_member_api_docs
  external String get subtitle;
  // ignore: public_member_api_docs
  external String get type;

  // ignore: public_member_api_docs
  external factory WebPlayerContextMetadata(
      {String title, String subtitle, String type});
}

/// Spotify player disallows object
@JS()
@anonymous
class WebPlayerDisallows {
  // ignore: public_member_api_docs
  external bool get pausing;
  // ignore: public_member_api_docs, non_constant_identifier_names
  external bool get peeking_next;
  // ignore: public_member_api_docs, non_constant_identifier_names
  external bool get peeking_prev;
  // ignore: public_member_api_docs
  external bool get resuming;
  // ignore: public_member_api_docs
  external bool get seeking;
  // ignore: public_member_api_docs, non_constant_identifier_names
  external bool get skipping_next;
  // ignore: public_member_api_docs, non_constant_identifier_names
  external bool get skipping_prev;

  // ignore: public_member_api_docs
  external factory WebPlayerDisallows(
      {bool pausing,
      // ignore: non_constant_identifier_names
      bool peeking_next,
      // ignore: non_constant_identifier_names
      bool peeking_prev,
      bool resuming,
      bool seeking,
      // ignore: non_constant_identifier_names
      bool skipping_next,
      // ignore: non_constant_identifier_names
      bool skipping_prev});
}

/// Spotify player track window object
@JS()
@anonymous
class WebPlayerTrackWindow {
  // ignore: public_member_api_docs, non_constant_identifier_names
  external WebPlaybackTrack get current_track;
  // ignore: public_member_api_docs, non_constant_identifier_names
  external List<WebPlaybackTrack> get previous_tracks;
  // ignore: public_member_api_docs, non_constant_identifier_names
  external List<WebPlaybackTrack> get next_tracks;

  // ignore: public_member_api_docs
  external factory WebPlayerTrackWindow(
      // ignore: non_constant_identifier_names
      {WebPlaybackTrack current_track,
      // ignore: non_constant_identifier_names
      List<WebPlaybackTrack> previous_tracks,
      // ignore: non_constant_identifier_names
      List<WebPlaybackTrack> next_tracks});
}

/// Spotify playback track object
@JS()
@anonymous
class WebPlaybackTrack {
  // ignore: public_member_api_docs
  external String get uri;
  // ignore: public_member_api_docs
  external String get id;
  // ignore: public_member_api_docs
  external String get type;
  // ignore: public_member_api_docs, non_constant_identifier_names
  external String get media_type;
  // ignore: public_member_api_docs
  external String get name;
  // ignore: public_member_api_docs, non_constant_identifier_names
  external bool get is_playable;
  // ignore: public_member_api_docs
  external WebPlaybackAlbum get album;
  // ignore: public_member_api_docs
  external List<WebPlaybackArtist> get artists;

  // ignore: public_member_api_docs
  external factory WebPlaybackTrack(
      {String uri,
      String id,
      String type,
      // ignore: non_constant_identifier_names
      String media_type,
      String name,
      // ignore: non_constant_identifier_names
      bool is_playable,
      WebPlaybackAlbum album,
      List<WebPlaybackArtist> artists});
}

/// Spotify playback album object
@JS()
@anonymous
class WebPlaybackAlbum {
  // ignore: public_member_api_docs
  external String get uri;
  // ignore: public_member_api_docs
  external String get name;
  // ignore: public_member_api_docs
  external List<WebPlaybackAlbumImage> get images;

  // ignore: public_member_api_docs
  external factory WebPlaybackAlbum(
      {String uri, String name, List<WebPlaybackAlbumImage> images});
}

/// Spotify artist object
@JS()
@anonymous
class WebPlaybackArtist {
  // ignore: public_member_api_docs
  external String get uri;
  // ignore: public_member_api_docs
  external String get name;

  // ignore: public_member_api_docs
  external factory WebPlaybackArtist({String uri, String name});
}

/// Spotify album image object
@JS()
@anonymous
class WebPlaybackAlbumImage {
  // ignore: public_member_api_docs
  external String get url;

  // ignore: public_member_api_docs
  external factory WebPlaybackAlbumImage({String url});
}

/// Spotify playback error object
@JS()
@anonymous
class WebPlaybackError {
  // ignore: public_member_api_docs
  external String get message;

  // ignore: public_member_api_docs
  external factory WebPlaybackError({String message});
}

/// Spotify token object.
class SpotifyToken {
  /// Spotify token data.
  final String token;

  /// Token expiry time in unix time.
  final int expiry;

  // ignore: public_member_api_docs
  SpotifyToken(this.token, this.expiry);
}
