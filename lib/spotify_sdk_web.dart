@JS()
library spotify_sdk_web;

import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:developer';
import 'dart:html';
import 'dart:math' as math;

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:js/js.dart';
import 'package:js/js_util.dart';
import 'package:synchronized/synchronized.dart' as synchronized;

import 'enums/repeat_mode_enum.dart';
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

export 'package:spotify_sdk/enums/image_dimension_enum.dart';
export 'package:spotify_sdk/enums/repeat_mode_enum.dart';
export 'package:spotify_sdk/extensions/image_dimension_extension.dart';

///
/// [SpotifySdkPlugin] is the web implementation of the Spotify SDK plugin.
///
class SpotifySdkPlugin {
  /// authentication token error id
  static const String errorAuthenticationTokenError =
      'authenticationTokenError';

  /// spotify sdk url
  static const String spotifySdkUrl = 'https://sdk.scdn.co/spotify-player.js';

  /// Whether the Spotify SDK is loaded.
  bool _sdkLoaded = false;

  /// Future loading the Spotify SDK.
  Future? _sdkLoadFuture;

  /// Current Spotify SDK player instance.
  Player? _currentPlayer;

  /// Current Spotify auth token.
  SpotifyToken? _spotifyToken;

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
  final Dio _authDio = Dio(BaseOptions());

  /// Lock for getting the token
  final synchronized.Lock _getTokenLock = synchronized.Lock(reentrant: true);

  /// Default scopes that are required for Web SDK to work
  static const String defaultScopes =
      'streaming user-read-email user-read-private';

  static String? tokenSwapURL;
  static String? tokenRefreshURL;

  /// constructor
  SpotifySdkPlugin(
      this.playerContextEventController,
      this.playerStateEventController,
      this.playerCapabilitiesEventController,
      this.userStateEventController,
      this.connectionStatusEventController);

  /// registers plugin method channels
  static void registerWith(Registrar registrar) {
    // method channel
    final channel = MethodChannel(
        MethodChannels.spotifySdk, const StandardMethodCodec(), registrar);
    // event channels
    const playerContextEventChannel =
        PluginEventChannel(EventChannels.playerContext);
    final playerContextEventController = StreamController.broadcast();
    playerContextEventChannel.setController(playerContextEventController);
    const playerStateEventChannel =
        PluginEventChannel(EventChannels.playerState);
    final playerStateEventController = StreamController.broadcast();
    playerStateEventChannel.setController(playerStateEventController);
    const playerCapabilitiesEventChannel =
        PluginEventChannel(EventChannels.capabilities);
    final playerCapabilitiesEventController = StreamController.broadcast();
    playerCapabilitiesEventChannel
        .setController(playerCapabilitiesEventController);
    const userStatusEventChannel = PluginEventChannel(EventChannels.userStatus);
    final userStatusEventController = StreamController.broadcast();
    userStatusEventChannel.setController(userStatusEventController);
    const connectionStatusEventChannel =
        PluginEventChannel(EventChannels.connectionStatus);
    final connectionStatusEventController = StreamController.broadcast();
    connectionStatusEventChannel.setController(connectionStatusEventController);

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
      _sdkLoadFuture ??= _initializeSpotify();
      await _sdkLoadFuture;
    }

    switch (call.method) {
      case MethodNames.connectToSpotify:
        if (_currentPlayer != null) {
          return true;
        }
        log('Connecting to Spotify...');
        var clientId = call.arguments[ParamNames.clientId] as String?;
        var redirectUrl = call.arguments[ParamNames.redirectUrl] as String?;
        var playerName = call.arguments[ParamNames.playerName] as String?;
        var scopes =
            call.arguments[ParamNames.scope] as String? ?? defaultScopes;
        var accessToken = call.arguments[ParamNames.accessToken] as String?;

        // ensure that required arguments are present
        if (clientId == null ||
            clientId.isEmpty ||
            redirectUrl == null ||
            redirectUrl.isEmpty) {
          throw PlatformException(
              message:
                  'Client id or redirectUrl are not set or have invalid format',
              code: 'Authentication Error');
        }

        // get initial token if not supplied
        if (accessToken == null || accessToken.isEmpty) {
          await _authorizeSpotify(
              clientId: clientId, redirectUrl: redirectUrl, scopes: scopes);
        }

        // create player
        _currentPlayer = Player(PlayerOptions(
            name: playerName,
            getOAuthToken: allowInterop((Function callback, t) {
              _getSpotifyAuthToken().then((value) {
                callback(value);
              });
            })));

        _registerPlayerEvents(_currentPlayer!);
        var result = await promiseToFuture(_currentPlayer!.connect());
        if (result == true) {
          // wait for the confirmation
          num time = 0;
          while (_currentPlayer!.deviceID == null) {
            await Future.delayed(const Duration(milliseconds: 200));
            time += 200;
            if (time > 10000) {
              return false;
            }
          }
          return true;
        } else {
          // disconnected
          _onSpotifyDisconnected(
              errorCode: 'Initialization Error',
              errorDetails: 'Attempt to connect to the Spotify SDK failed');
          return false;
        }
      case MethodNames.getAccessToken:
        var clientId = call.arguments[ParamNames.clientId] as String?;
        var redirectUrl = call.arguments[ParamNames.redirectUrl] as String?;

        // ensure that required arguments are present
        if (clientId == null ||
            clientId.isEmpty ||
            redirectUrl == null ||
            redirectUrl.isEmpty) {
          throw PlatformException(
              message:
                  'Client id or redirectUrl are not set or have invalid format',
              code: 'Authentication Error');
        }

        return await _authorizeSpotify(
            clientId: clientId,
            redirectUrl: redirectUrl,
            scopes:
                call.arguments[ParamNames.scope] as String? ?? defaultScopes);
      case MethodNames.disconnectFromSpotify:
        log('Disconnecting from Spotify...');
        _spotifyToken = null;
        if (_currentPlayer == null) {
          return true;
        } else {
          _currentPlayer!.disconnect();
          _onSpotifyDisconnected();
          return true;
        }
      case MethodNames.play:
        await _play(call.arguments[ParamNames.spotifyUri] as String?);
        break;
      case MethodNames.queueTrack:
        await _queue(call.arguments[ParamNames.spotifyUri] as String?);
        break;
      case MethodNames.setShuffle:
        await _setShuffle(call.arguments[ParamNames.shuffle] as bool?);
        break;
      case MethodNames.setRepeatMode:
        await _setRepeatMode(
            call.arguments[ParamNames.repeatMode] as RepeatMode?);
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
            as WebPlaybackState?;
        if (stateRaw == null) return null;
        return jsonEncode(toPlayerState(stateRaw)!.toJson());
      default:
        throw PlatformException(
            code: 'Unimplemented',
            details:
                "Method '${call.method}' not implemented in web spotify_sdk");
    }
  }

  /// Loads the Spotify SDK library.
  Future _initializeSpotify() async {
    if (_onSpotifyWebPlaybackSDKReady == null) {
      log('Loading Spotify SDK...');

      // link spotify ready function
      _onSpotifyWebPlaybackSDKReady = allowInterop(_onSpotifyInitialized);

      // load spotify sdk
      querySelector('body')!.children.add(ScriptElement()..src = spotifySdkUrl);

      // wait for initialization
      while (_sdkLoaded == false) {
        await Future.delayed(const Duration(milliseconds: 200));
      }

      log('Spotify SDK loaded!');
    } else {
      // spotify sdk already loaded
      log('Reusing loaded Spotify SDK');
      _sdkLoaded = true;
    }
  }

  /// Registers Spotify event handlers.
  void _registerPlayerEvents(Player player) {
    // player state
    player.addListener('player_state_changed',
        allowInterop((WebPlaybackState? state) {
      if (state == null) return;
      playerStateEventController
          .add(jsonEncode(toPlayerState(state)!.toJson()));
      playerContextEventController
          .add(jsonEncode(toPlayerContext(state)!.toJson()));
    }));

    // ready/not ready
    player.addListener('ready', allowInterop((WebPlaybackPlayer player) {
      log('Spotify SDK ready!');
      _onSpotifyConnected(player.device_id);
    }));
    player.addListener('not_ready', allowInterop((event) {
      _onSpotifyDisconnected(
          errorCode: 'Spotify SDK not ready',
          errorDetails: 'Spotify SDK is not ready to take requests');
    }));

    // errors
    player.addListener('initialization_error',
        allowInterop((WebPlaybackError error) {
      _onSpotifyDisconnected(
          errorCode: 'Initialization Error', errorDetails: error.message);
    }));
    player.addListener('authentication_error',
        allowInterop((WebPlaybackError error) {
      // If the error is due to browser security, don't disconnect.
      // The user needs to interact with the SDK to trigger media activation.
      // https://developer.spotify.com/documentation/web-playback-sdk/quick-start/#mobile-support
      if (error.message.contains('Browser prevented autoplay')) {
        log('authentication_error: ${error.message}');
        return;
      }
      _onSpotifyDisconnected(
          errorCode: 'Authentication Error', errorDetails: error.message);
    }));
    player.addListener('account_error', allowInterop((WebPlaybackError error) {
      _onSpotifyDisconnected(
          errorCode: 'Account Error', errorDetails: error.message);
    }));
    player.addListener('playback_error', allowInterop((WebPlaybackError error) {
      log('playback_error: ${error.message}');
    }));
  }

  /// Called when the Spotify SDK is first loaded.
  void _onSpotifyInitialized() {
    _sdkLoaded = true;
  }

  /// Called when the plugin successfully connects to the spotify web sdk.
  void _onSpotifyConnected(String deviceId) {
    _currentPlayer!.deviceID = deviceId;

    // emit connected event
    connectionStatusEventController.add(jsonEncode(ConnectionStatus(
      'Spotify SDK connected',
      '',
      '',
      connected: true,
    ).toJson()));
  }

  /// Called when the plugin disconnects from the spotify sdk.
  void _onSpotifyDisconnected({String? errorCode, String? errorDetails}) {
    _unregisterPlayerEvents(_currentPlayer!);
    _currentPlayer = null;

    if (errorCode != null) {
      // disconnected due to error
      log('$errorCode: $errorDetails');
    }

    // emit not connected event
    connectionStatusEventController.add(jsonEncode(ConnectionStatus(
            'Spotify SDK disconnected', errorCode ?? '', errorDetails ?? '',
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
  /// refreshes the token if it expired.
  Future<String> _getSpotifyAuthToken() async {
    return await _getTokenLock.synchronized<String>(() async {
      if (_spotifyToken?.accessToken != null) {
        // attempt to use the previously authorized credentials
        if (_spotifyToken!.expiry >
            DateTime.now().millisecondsSinceEpoch / 1000) {
          // access token valid
          return _spotifyToken!.accessToken;
        } else {
          // access token invalid, refresh it
          var newToken = await _refreshSpotifyToken(
              _spotifyToken!.clientId, _spotifyToken!.refreshToken);
          _spotifyToken = SpotifyToken(
              clientId: _spotifyToken!.clientId,
              accessToken: newToken['access_token'] as String,
              refreshToken: newToken['refresh_token'] as String,
              expiry: (DateTime.now().millisecondsSinceEpoch / 1000).round() +
                  (newToken['expires_in'] as int));
          return _spotifyToken!.accessToken;
        }
      } else {
        throw PlatformException(
            message: 'Spotify user not logged in!',
            code: 'Authentication Error');
      }
    });
  }

  /// Authenticates a new user with Spotify and stores access token.
  Future<String> _authorizeSpotify(
      {required String clientId,
      required String redirectUrl,
      required String? scopes}) async {
    // creating auth uri
    var codeVerifier = _createCodeVerifier();
    var codeChallenge = _createCodeChallenge(codeVerifier);
    var state = _createAuthState();

    var params = {
      'client_id': clientId,
      'redirect_uri': redirectUrl,
      'response_type': 'code',
      'state': state,
      'scope': scopes,
    };

    if (tokenSwapURL == null) {
      params['code_challenge_method'] = 'S256';
      params['code_challenge'] = codeChallenge;
    }

    final authorizationUri = Uri.https(
      'accounts.spotify.com',
      'authorize',
      params,
    );

    // opening auth window
    var authPopup = window.open(
      authorizationUri.toString(),
      'Spotify Authorization',
    );
    String? message;
    var sub = window.onMessage.listen(allowInterop((event) {
      message = event.data.toString();
      // ensure the message contains auth code
      if (!message!.startsWith('?code=')) {
        message = null;
      }
    }));

    // loop and wait for auth
    while (authPopup.closed == false && message == null) {
      // await response from the window
      await Future.delayed(const Duration(milliseconds: 250));
    }

    // error if window closed by user
    if (message == null) {
      throw PlatformException(
          message: 'User closed authentication window',
          code: 'Authentication Error');
    }

    // parse the returned parameters
    var parsedMessage = Uri.parse(message!);

    // check if state is the same
    if (state != parsedMessage.queryParameters['state']) {
      throw PlatformException(
          message: 'Invalid state', code: 'Authentication Error');
    }

    // check for error
    if (parsedMessage.queryParameters['error'] != null ||
        parsedMessage.queryParameters['code'] == null) {
      throw PlatformException(
          message: "${parsedMessage.queryParameters['error']}",
          code: 'Authentication Error');
    }

    // close auth window
    if (authPopup.closed == false) {
      authPopup.close();
    }
    await sub.cancel();

    // exchange auth code for access and refresh tokens
    dynamic authResponse;

    RequestOptions req;

    if (tokenSwapURL == null) {
      // build request to exchange auth code with PKCE for access and refresh tokens
      req = RequestOptions(
        path: 'https://accounts.spotify.com/api/token',
        method: 'POST',
        data: {
          'client_id': clientId,
          'grant_type': 'authorization_code',
          'code': parsedMessage.queryParameters['code'],
          'redirect_uri': redirectUrl,
          'code_verifier': codeVerifier
        },
        contentType: Headers.formUrlEncodedContentType,
      );
    } else {
      // or build request to exchange code with token swap
      // https://developer.spotify.com/documentation/ios/guides/token-swap-and-refresh/
      req = RequestOptions(
        path: tokenSwapURL!,
        method: 'POST',
        data: {
          'code': parsedMessage.queryParameters['code'],
          'redirect_uri': redirectUrl,
        },
        contentType: Headers.formUrlEncodedContentType,
      );
    }

    try {
      var res = await _authDio.fetch(req);
      authResponse = res.data;
    } on DioException catch (e) {
      log('Spotify auth error: ${e.response?.data}');
      rethrow;
    }

    _spotifyToken = SpotifyToken(
        clientId: clientId,
        accessToken: authResponse['access_token'] as String,
        refreshToken: authResponse['refresh_token'] as String,
        expiry: (DateTime.now().millisecondsSinceEpoch / 1000).round() +
            (authResponse['expires_in'] as int));
    return _spotifyToken!.accessToken;
  }

  /// Refreshes the Spotify access token using the refresh token.
  Future<dynamic> _refreshSpotifyToken(
      String? clientId, String? refreshToken) async {
    RequestOptions req;
    if (tokenRefreshURL == null) {
      // build request to refresh PKCE for access and refresh tokens
      req = RequestOptions(
        path: 'https://accounts.spotify.com/api/token',
        method: 'POST',
        data: {
          'grant_type': 'refresh_token',
          'refresh_token': refreshToken,
          'client_id': clientId,
        },
        contentType: Headers.formUrlEncodedContentType,
      );
    } else {
      // or build request to refresh code with token swap
      // https://developer.spotify.com/documentation/ios/guides/token-swap-and-refresh/
      req = RequestOptions(
        path: tokenRefreshURL!,
        method: 'POST',
        data: {
          'refresh_token': refreshToken,
        },
        contentType: Headers.formUrlEncodedContentType,
      );
    }

    try {
      var res = await _authDio.fetch(req);
      var d = res.data;
      d['refresh_token'] = refreshToken;
      return d;
    } on DioException catch (e) {
      log('Token refresh error: ${e.response?.data}');
      rethrow;
    }
  }

  /// Creates a code verifier as per
  /// https://developer.spotify.com/documentation/general/guides/authorization-guide/#authorization-code-flow-with-proof-key-for-code-exchange-pkce
  String _createCodeVerifier() {
    return _createRandomString(127);
  }

  /// Creates a code challenge as per
  /// https://developer.spotify.com/documentation/general/guides/authorization-guide/#authorization-code-flow-with-proof-key-for-code-exchange-pkce
  String _createCodeChallenge(String codeVerifier) {
    return base64Url
        .encode(sha256.convert(ascii.encode(codeVerifier)).bytes)
        .replaceAll('=', '');
  }

  /// Creates a random string unique to a given authentication session.
  String _createAuthState() {
    return _createRandomString(64);
  }

  /// Creates a cryptographically random string.
  String _createRandomString(int length) {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
    return List.generate(
        128, (i) => chars[math.Random.secure().nextInt(chars.length)]).join();
  }

  /// Starts track playback on the device.
  Future _play(String? uri) async {
    if (_currentPlayer?.deviceID == null) {
      throw PlatformException(
          message: 'Spotify player not connected!', code: 'Playback Error');
    }

    await _dio.put(
      '/play',
      data: {
        'uris': [uri]
      },
      queryParameters: {'device_id': _currentPlayer!.deviceID},
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getSpotifyAuthToken()}'
        },
      ),
    );
  }

  /// Adds a given track to the playback queue.
  Future _queue(String? uri) async {
    if (_currentPlayer?.deviceID == null) {
      throw PlatformException(
          message: 'Spotify player not connected!', code: 'Playback Error');
    }

    await _dio.post(
      '/queue',
      queryParameters: {'uri': uri, 'device_id': _currentPlayer!.deviceID},
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getSpotifyAuthToken()}'
        },
      ),
    );
  }

  /// Sets whether shuffle should be enabled.
  Future _setShuffle(bool? shuffleEnabled) async {
    if (_currentPlayer?.deviceID == null) {
      throw PlatformException(
          message: 'Spotify player not connected!', code: 'Set Shuffle Error');
    }

    await _dio.put(
      '/shuffle',
      queryParameters: {
        'state': shuffleEnabled,
        'device_id': _currentPlayer!.deviceID
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
  Future _setRepeatMode(RepeatMode? repeatMode) async {
    if (_currentPlayer?.deviceID == null) {
      throw PlatformException(
          message: 'Spotify player not connected!',
          code: 'Set Repeat Mode Error');
    }

    await _dio.put(
      '/repeat',
      queryParameters: {
        'state': repeatMode.toString().substring(11),
        'device_id': _currentPlayer!.deviceID
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
  Future toggleShuffle({bool? state}) async {
    if (_currentPlayer?.deviceID == null) {
      throw PlatformException(
          message: 'Spotify player not connected!', code: 'Playback Error');
    }

    await _dio.put(
      '/shuffle',
      queryParameters: {'state': state, 'device_id': _currentPlayer!.deviceID},
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getSpotifyAuthToken()}'
        },
      ),
    );
  }

  /// Toggles repeat on the current player.
  Future toggleRepeat({bool? state}) async {
    if (_currentPlayer?.deviceID == null) {
      throw PlatformException(
          message: 'Spotify player not connected!', code: 'Playback Error');
    }

    await _dio.put(
      '/repeat',
      queryParameters: {'state': state, 'device_id': _currentPlayer!.deviceID},
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getSpotifyAuthToken()}'
        },
      ),
    );
  }

  /// Converts a native WebPlaybackState to the library PlayerState
  PlayerState? toPlayerState(WebPlaybackState? state) {
    if (state == null) return null;
    var trackRaw = state.track_window.current_track;
    var albumRaw = trackRaw?.album;
    var restrictionsRaw = state.disallows;
    var artists = <Artist>[];

    if (trackRaw != null) {
      for (var artist in trackRaw.artists) {
        artists.add(Artist(artist.name, artist.uri));
      }
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
              Album(albumRaw!.name, albumRaw.uri),
              artists[0],
              artists,
              -1,
              ImageUri(albumRaw.images[0].url),
              trackRaw.name,
              trackRaw.uri,
              trackRaw.linked_from.uri,
              isEpisode: trackRaw.type == 'episode',
              isPodcast: trackRaw.type == 'episode',
            )
          : null,
      1.0,
      state.position,
      options.PlayerOptions(repeatMode, isShuffling: state.shuffle),
      PlayerRestrictions(
          canSkipNext: restrictionsRaw.skipping_next || true,
          canSkipPrevious: restrictionsRaw.skipping_prev || true,
          canSeek: restrictionsRaw.seeking || true,
          canRepeatTrack: true,
          canRepeatContext: true,
          canToggleShuffle: true),
      isPaused: state.paused,
    );
  }

  /// Converts a native WebPlaybackState to the library PlayerContext
  PlayerContext? toPlayerContext(WebPlaybackState? state) {
    if (state == null) return null;
    return PlayerContext(
        state.context.metadata.title,
        state.context.metadata.subtitle,
        state.context.metadata.type,
        state.context.uri);
  }
}

/// Allows assigning the function onSpotifyWebPlaybackSDKReady
/// to be callable from `window.onSpotifyWebPlaybackSDKReady()`
@JS('onSpotifyWebPlaybackSDKReady')
external set _onSpotifyWebPlaybackSDKReady(void Function()? f);

/// Allows assigning the function onSpotifyWebPlaybackSDKReady
/// to be callable from `window.onSpotifyWebPlaybackSDKReady()`
@JS('onSpotifyWebPlaybackSDKReady')
external void Function()? get _onSpotifyWebPlaybackSDKReady;

/// Spotify Player Object
@JS('Spotify.Player')
class Player {
  /// Device id of the player.
  String? deviceID;

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
      {String? name, Function? getOAuthToken, double? volume});
}

/// Spotify playback object
@JS()
@anonymous
class WebPlaybackPlayer {
  // ignore: public_member_api_docs, non_constant_identifier_names
  external String get device_id;
  // ignore: public_member_api_docs, non_constant_identifier_names
  external factory WebPlaybackPlayer({String? device_id});
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
      {WebPlayerContext? context,
      WebPlayerDisallows? disallows,
      bool? paysed,
      int? position,
      // ignore: non_constant_identifier_names
      int? repeat_mode,
      bool? shuffle,
      // ignore: non_constant_identifier_names
      WebPlayerTrackWindow? track_window});
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
      {String? uri, WebPlayerContextMetadata? metadata});
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
      {String? title, String? subtitle, String? type});
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
      {bool? pausing,
      // ignore: non_constant_identifier_names
      bool? peeking_next,
      // ignore: non_constant_identifier_names
      bool? peeking_prev,
      bool? resuming,
      bool? seeking,
      // ignore: non_constant_identifier_names
      bool? skipping_next,
      // ignore: non_constant_identifier_names
      bool? skipping_prev});
}

/// Spotify player track window object
@JS()
@anonymous
class WebPlayerTrackWindow {
  // ignore: public_member_api_docs, non_constant_identifier_names
  external WebPlaybackTrack? get current_track;
  // ignore: public_member_api_docs, non_constant_identifier_names
  external List<WebPlaybackTrack>? get previous_tracks;
  // ignore: public_member_api_docs, non_constant_identifier_names
  external List<WebPlaybackTrack>? get next_tracks;

  // ignore: public_member_api_docs
  external factory WebPlayerTrackWindow(
      // ignore: non_constant_identifier_names
      {WebPlaybackTrack? current_track,
      // ignore: non_constant_identifier_names
      List<WebPlaybackTrack>? previous_tracks,
      // ignore: non_constant_identifier_names
      List<WebPlaybackTrack>? next_tracks});
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
  // ignore: non_constant_identifier_names
  external WebLinkedFrom get linked_from;

  // ignore: public_member_api_docs
  external factory WebPlaybackTrack(
      {String? uri,
      String? id,
      String? type,
      // ignore: non_constant_identifier_names
      String? media_type,
      String? name,
      // ignore: non_constant_identifier_names
      bool? is_playable,
      WebPlaybackAlbum? album,
      List<WebPlaybackArtist>? artists,
      // ignore: non_constant_identifier_names
      WebLinkedFrom? linked_from});
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
      {String? uri, String? name, List<WebPlaybackAlbumImage>? images});
}

/// Spotify playback album object
@JS()
@anonymous
class WebLinkedFrom {
  // ignore: public_member_api_docs
  external String get uri;
  // ignore: public_member_api_docs
  external String get id;

  // ignore: public_member_api_docs
  external factory WebLinkedFrom({String? uri, String? id});
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
  external factory WebPlaybackArtist({String? uri, String? name});
}

/// Spotify album image object
@JS()
@anonymous
class WebPlaybackAlbumImage {
  // ignore: public_member_api_docs
  external String get url;

  // ignore: public_member_api_docs
  external factory WebPlaybackAlbumImage({String? url});
}

/// Spotify playback error object
@JS()
@anonymous
class WebPlaybackError {
  // ignore: public_member_api_docs
  external String get message;

  // ignore: public_member_api_docs
  external factory WebPlaybackError({String? message});
}

/// Spotify token object.
class SpotifyToken {
  /// Currently used client id.
  final String clientId;

  /// Access token data.
  final String accessToken;

  /// Refresh token data.
  final String refreshToken;

  /// Token expiry time in unix seconds.
  final int expiry;

  // ignore: public_member_api_docs
  SpotifyToken(
      {required this.clientId,
      required this.accessToken,
      required this.refreshToken,
      required this.expiry});
}
