@JS()
library;

import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:developer';
import 'dart:js_interop';
import 'dart:math' as math;

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:synchronized/synchronized.dart' as synchronized;
import 'package:web/web.dart' as web;

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
  SpotifyPlayer? _currentPlayer;

  /// Device id of the current player, set once the SDK reports `ready`.
  String? _currentDeviceId;

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
  final Dio _dio = Dio(
    BaseOptions(baseUrl: 'https://api.spotify.com/v1/me/player'),
  );
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
    this.connectionStatusEventController,
  );

  /// registers plugin method channels
  static void registerWith(Registrar registrar) {
    // method channel
    final channel = MethodChannel(
      MethodChannels.spotifySdk,
      const StandardMethodCodec(),
      registrar,
    );
    // event channels
    const playerContextEventChannel = PluginEventChannel(
      EventChannels.playerContext,
    );
    final playerContextEventController = StreamController.broadcast();
    playerContextEventChannel.setController(playerContextEventController);
    const playerStateEventChannel = PluginEventChannel(
      EventChannels.playerState,
    );
    final playerStateEventController = StreamController.broadcast();
    playerStateEventChannel.setController(playerStateEventController);
    const playerCapabilitiesEventChannel = PluginEventChannel(
      EventChannels.capabilities,
    );
    final playerCapabilitiesEventController = StreamController.broadcast();
    playerCapabilitiesEventChannel.setController(
      playerCapabilitiesEventController,
    );
    const userStatusEventChannel = PluginEventChannel(EventChannels.userStatus);
    final userStatusEventController = StreamController.broadcast();
    userStatusEventChannel.setController(userStatusEventController);
    const connectionStatusEventChannel = PluginEventChannel(
      EventChannels.connectionStatus,
    );
    final connectionStatusEventController = StreamController.broadcast();
    connectionStatusEventChannel.setController(connectionStatusEventController);

    final instance = SpotifySdkPlugin(
      playerContextEventController,
      playerStateEventController,
      playerCapabilitiesEventController,
      userStatusEventController,
      connectionStatusEventController,
    );

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
            code: 'Authentication Error',
          );
        }

        // get initial token if not supplied
        if (accessToken == null || accessToken.isEmpty) {
          await _authorizeSpotify(
            clientId: clientId,
            redirectUrl: redirectUrl,
            scopes: scopes,
          );
        }

        // create player
        _currentPlayer = SpotifyPlayer(
          PlayerOptions(
            name: playerName,
            getOAuthToken: ((JSFunction callback) {
              _getSpotifyAuthToken().then((value) {
                callback.callAsFunction(null, value.toJS);
              });
            }).toJS,
          ),
        );

        _registerPlayerEvents(_currentPlayer!);
        var result = (await _currentPlayer!.connect().toDart).toDart;
        if (result == true) {
          // wait for the confirmation
          num time = 0;
          while (_currentDeviceId == null) {
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
            errorDetails: 'Attempt to connect to the Spotify SDK failed',
          );
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
            code: 'Authentication Error',
          );
        }

        return await _authorizeSpotify(
          clientId: clientId,
          redirectUrl: redirectUrl,
          scopes: call.arguments[ParamNames.scope] as String? ?? defaultScopes,
        );
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
          call.arguments[ParamNames.repeatMode] as RepeatMode?,
        );
        break;
      case MethodNames.resume:
        await _currentPlayer?.resume().toDart;
        break;
      case MethodNames.pause:
        await _currentPlayer?.pause().toDart;
        break;
      case MethodNames.skipNext:
        await _currentPlayer?.nextTrack().toDart;
        break;
      case MethodNames.skipPrevious:
        await _currentPlayer?.previousTrack().toDart;
        break;
      case MethodNames.getPlayerState:
        var stateRaw = await _currentPlayer?.getCurrentState().toDart;
        if (stateRaw == null) return null;
        return jsonEncode(toPlayerState(stateRaw)!.toJson());
      default:
        throw PlatformException(
          code: 'Unimplemented',
          details: "Method '${call.method}' not implemented in web spotify_sdk",
        );
    }
  }

  /// Loads the Spotify SDK library.
  Future _initializeSpotify() async {
    if (_onSpotifyWebPlaybackSDKReady == null) {
      log('Loading Spotify SDK...');

      // link spotify ready function
      _onSpotifyWebPlaybackSDKReady = _onSpotifyInitialized.toJS;

      // load spotify sdk
      final script =
          web.document.createElement('script') as web.HTMLScriptElement
            ..src = spotifySdkUrl;
      web.document.body!.appendChild(script);

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
  void _registerPlayerEvents(SpotifyPlayer player) {
    // player state
    player.addListener(
      'player_state_changed',
      ((WebPlaybackState? state) {
        if (state == null) return;
        playerStateEventController.add(
          jsonEncode(toPlayerState(state)!.toJson()),
        );
        playerContextEventController.add(
          jsonEncode(toPlayerContext(state)!.toJson()),
        );
      }).toJS,
    );

    // ready/not ready
    player.addListener(
      'ready',
      ((WebPlaybackPlayer player) {
        log('Spotify SDK ready!');
        _onSpotifyConnected(player.device_id);
      }).toJS,
    );
    player.addListener(
      'not_ready',
      ((JSObject? _) {
        _onSpotifyDisconnected(
          errorCode: 'Spotify SDK not ready',
          errorDetails: 'Spotify SDK is not ready to take requests',
        );
      }).toJS,
    );

    // errors
    player.addListener(
      'initialization_error',
      ((WebPlaybackError error) {
        _onSpotifyDisconnected(
          errorCode: 'Initialization Error',
          errorDetails: error.message,
        );
      }).toJS,
    );
    player.addListener(
      'authentication_error',
      ((WebPlaybackError error) {
        // If the error is due to browser security, don't disconnect.
        // The user needs to interact with the SDK to trigger media activation.
        // https://developer.spotify.com/documentation/web-playback-sdk/quick-start/#mobile-support
        if (error.message.contains('Browser prevented autoplay')) {
          log('authentication_error: ${error.message}');
          return;
        }
        _onSpotifyDisconnected(
          errorCode: 'Authentication Error',
          errorDetails: error.message,
        );
      }).toJS,
    );
    player.addListener(
      'account_error',
      ((WebPlaybackError error) {
        _onSpotifyDisconnected(
          errorCode: 'Account Error',
          errorDetails: error.message,
        );
      }).toJS,
    );
    player.addListener(
      'playback_error',
      ((WebPlaybackError error) {
        log('playback_error: ${error.message}');
      }).toJS,
    );
  }

  /// Called when the Spotify SDK is first loaded.
  void _onSpotifyInitialized() {
    _sdkLoaded = true;
  }

  /// Called when the plugin successfully connects to the spotify web sdk.
  void _onSpotifyConnected(String deviceId) {
    _currentDeviceId = deviceId;

    // emit connected event
    connectionStatusEventController.add(
      jsonEncode(
        ConnectionStatus(
          'Spotify SDK connected',
          '',
          '',
          connected: true,
        ).toJson(),
      ),
    );
  }

  /// Called when the plugin disconnects from the spotify sdk.
  void _onSpotifyDisconnected({String? errorCode, String? errorDetails}) {
    _unregisterPlayerEvents(_currentPlayer!);
    _currentPlayer = null;
    _currentDeviceId = null;

    if (errorCode != null) {
      // disconnected due to error
      log('$errorCode: $errorDetails');
    }

    // emit not connected event
    connectionStatusEventController.add(
      jsonEncode(
        ConnectionStatus(
          'Spotify SDK disconnected',
          errorCode ?? '',
          errorDetails ?? '',
          connected: false,
        ).toJson(),
      ),
    );
  }

  void _unregisterPlayerEvents(SpotifyPlayer player) {
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
            _spotifyToken!.clientId,
            _spotifyToken!.refreshToken,
          );
          _spotifyToken = SpotifyToken(
            clientId: _spotifyToken!.clientId,
            accessToken: newToken['access_token'] as String,
            refreshToken: newToken['refresh_token'] as String,
            expiry:
                (DateTime.now().millisecondsSinceEpoch / 1000).round() +
                (newToken['expires_in'] as int),
          );
          return _spotifyToken!.accessToken;
        }
      } else {
        throw PlatformException(
          message: 'Spotify user not logged in!',
          code: 'Authentication Error',
        );
      }
    });
  }

  /// Authenticates a new user with Spotify and stores access token.
  Future<String> _authorizeSpotify({
    required String clientId,
    required String redirectUrl,
    required String? scopes,
  }) async {
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
    final authPopup = web.window.open(
      authorizationUri.toString(),
      'Spotify Authorization',
    );
    String? message;
    void messageListener(web.MessageEvent event) {
      message = event.data.dartify()?.toString();
      // ensure the message contains auth code
      if (message != null && !message!.startsWith('?code=')) {
        message = null;
      }
    }

    final messageListenerJs = messageListener.toJS;
    web.window.addEventListener('message', messageListenerJs);

    // loop and wait for auth
    while (authPopup?.closed == false && message == null) {
      // await response from the window
      await Future.delayed(const Duration(milliseconds: 250));
    }

    // error if window closed by user
    if (message == null) {
      throw PlatformException(
        message: 'User closed authentication window',
        code: 'Authentication Error',
      );
    }

    // parse the returned parameters
    var parsedMessage = Uri.parse(message!);

    // check if state is the same
    if (state != parsedMessage.queryParameters['state']) {
      throw PlatformException(
        message: 'Invalid state',
        code: 'Authentication Error',
      );
    }

    // check for error
    if (parsedMessage.queryParameters['error'] != null ||
        parsedMessage.queryParameters['code'] == null) {
      throw PlatformException(
        message: "${parsedMessage.queryParameters['error']}",
        code: 'Authentication Error',
      );
    }

    // close auth window
    if (authPopup?.closed == false) {
      authPopup?.close();
    }
    web.window.removeEventListener('message', messageListenerJs);

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
          'code_verifier': codeVerifier,
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
      expiry:
          (DateTime.now().millisecondsSinceEpoch / 1000).round() +
          (authResponse['expires_in'] as int),
    );
    return _spotifyToken!.accessToken;
  }

  /// Refreshes the Spotify access token using the refresh token.
  Future<dynamic> _refreshSpotifyToken(
    String? clientId,
    String? refreshToken,
  ) async {
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
        data: {'refresh_token': refreshToken},
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
      128,
      (i) => chars[math.Random.secure().nextInt(chars.length)],
    ).join();
  }

  /// Starts track playback on the device.
  Future _play(String? uri) async {
    if (_currentDeviceId == null) {
      throw PlatformException(
        message: 'Spotify player not connected!',
        code: 'Playback Error',
      );
    }

    await _dio.put(
      '/play',
      data: {
        'uris': [uri],
      },
      queryParameters: {'device_id': _currentDeviceId},
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getSpotifyAuthToken()}',
        },
      ),
    );
  }

  /// Adds a given track to the playback queue.
  Future _queue(String? uri) async {
    if (_currentDeviceId == null) {
      throw PlatformException(
        message: 'Spotify player not connected!',
        code: 'Playback Error',
      );
    }

    await _dio.post(
      '/queue',
      queryParameters: {'uri': uri, 'device_id': _currentDeviceId},
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getSpotifyAuthToken()}',
        },
      ),
    );
  }

  /// Sets whether shuffle should be enabled.
  Future _setShuffle(bool? shuffleEnabled) async {
    if (_currentDeviceId == null) {
      throw PlatformException(
        message: 'Spotify player not connected!',
        code: 'Set Shuffle Error',
      );
    }

    await _dio.put(
      '/shuffle',
      queryParameters: {'state': shuffleEnabled, 'device_id': _currentDeviceId},
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getSpotifyAuthToken()}',
        },
      ),
    );
  }

  /// Sets the repeat mode.
  Future _setRepeatMode(RepeatMode? repeatMode) async {
    if (_currentDeviceId == null) {
      throw PlatformException(
        message: 'Spotify player not connected!',
        code: 'Set Repeat Mode Error',
      );
    }

    await _dio.put(
      '/repeat',
      queryParameters: {
        'state': repeatMode.toString().substring(11),
        'device_id': _currentDeviceId,
      },
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getSpotifyAuthToken()}',
        },
      ),
    );
  }

  /// Toggles shuffle on the current player.
  Future toggleShuffle({bool? state}) async {
    if (_currentDeviceId == null) {
      throw PlatformException(
        message: 'Spotify player not connected!',
        code: 'Playback Error',
      );
    }

    await _dio.put(
      '/shuffle',
      queryParameters: {'state': state, 'device_id': _currentDeviceId},
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getSpotifyAuthToken()}',
        },
      ),
    );
  }

  /// Toggles repeat on the current player.
  Future toggleRepeat({bool? state}) async {
    if (_currentDeviceId == null) {
      throw PlatformException(
        message: 'Spotify player not connected!',
        code: 'Playback Error',
      );
    }

    await _dio.put(
      '/repeat',
      queryParameters: {'state': state, 'device_id': _currentDeviceId},
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getSpotifyAuthToken()}',
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
      for (var artist in trackRaw.artists.toDart) {
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
              ImageUri(albumRaw.images.toDart[0].url),
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
        canToggleShuffle: true,
      ),
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
      state.context.uri,
    );
  }
}

/// Allows assigning the function onSpotifyWebPlaybackSDKReady
/// to be callable from `window.onSpotifyWebPlaybackSDKReady()`
@JS('onSpotifyWebPlaybackSDKReady')
external set _onSpotifyWebPlaybackSDKReady(JSFunction? f);

/// Allows assigning the function onSpotifyWebPlaybackSDKReady
/// to be callable from `window.onSpotifyWebPlaybackSDKReady()`
@JS('onSpotifyWebPlaybackSDKReady')
external JSFunction? get _onSpotifyWebPlaybackSDKReady;

/// Spotify Player Object
@JS('Spotify.Player')
extension type SpotifyPlayer._(JSObject _) implements JSObject {
  /// The main constructor for initializing the Web Playback SDK.
  /// It should contain an object with the player name, volume and access token.
  external SpotifyPlayer(PlayerOptions options);

  /// Connects Web Playback SDK instance to Spotify
  /// with the credentials provided during initialization.
  external JSPromise<JSBoolean> connect();

  /// Closes the current session that Web Playback SDK has with Spotify.
  external void disconnect();

  /// Create a new event listener in the Web Playback SDK.
  external void addListener(String type, JSFunction callback);

  /// Remove an event listener in the Web Playback SDK.
  external void removeListener(String eventName);

  /// Collect metadata on local playback.
  external JSPromise<WebPlaybackState?> getCurrentState();

  /// Rename the Spotify Player device.
  /// This is visible across all Spotify Connect devices.
  external JSPromise<JSAny?> setName(String name);

  /// Set the local volume for the Web Playback SDK.
  external JSPromise<JSAny?> setVolume(double volume);

  /// Pause the local playback.
  external JSPromise<JSAny?> pause();

  /// Resume the local playback.
  external JSPromise<JSAny?> resume();

  /// Resume/pause the local playback.
  external JSPromise<JSAny?> togglePlay();

  /// Seek to a position in the current track in local playback.
  external JSPromise<JSAny?> seek(int positionMs);

  /// Switch to the previous track in local playback.
  external JSPromise<JSAny?> previousTrack();

  /// Skip to the next track in local playback.
  external JSPromise<JSAny?> nextTrack();
}

/// Spotify player options object
extension type PlayerOptions._(JSObject _) implements JSObject {
  // ignore: public_member_api_docs
  external factory PlayerOptions({
    String? name,
    JSFunction? getOAuthToken,
    double? volume,
  });

  // ignore: public_member_api_docs
  external String get name;
  // ignore: public_member_api_docs
  external JSFunction get getOAuthToken;
  // ignore: public_member_api_docs
  external double get volume;
}

/// Spotify playback object
extension type WebPlaybackPlayer._(JSObject _) implements JSObject {
  // ignore: public_member_api_docs, non_constant_identifier_names
  external String get device_id;
}

/// Spotify playback state object
extension type WebPlaybackState._(JSObject _) implements JSObject {
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
}

/// Spotify player context object
extension type WebPlayerContext._(JSObject _) implements JSObject {
  // ignore: public_member_api_docs
  external String get uri;
  // ignore: public_member_api_docs
  external WebPlayerContextMetadata get metadata;
}

/// Spotify player context metadata object
extension type WebPlayerContextMetadata._(JSObject _) implements JSObject {
  // ignore: public_member_api_docs
  external String get title;
  // ignore: public_member_api_docs
  external String get subtitle;
  // ignore: public_member_api_docs
  external String get type;
}

/// Spotify player disallows object
extension type WebPlayerDisallows._(JSObject _) implements JSObject {
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
}

/// Spotify player track window object
extension type WebPlayerTrackWindow._(JSObject _) implements JSObject {
  // ignore: public_member_api_docs, non_constant_identifier_names
  external WebPlaybackTrack? get current_track;
  // ignore: public_member_api_docs, non_constant_identifier_names
  external JSArray<WebPlaybackTrack>? get previous_tracks;
  // ignore: public_member_api_docs, non_constant_identifier_names
  external JSArray<WebPlaybackTrack>? get next_tracks;
}

/// Spotify playback track object
extension type WebPlaybackTrack._(JSObject _) implements JSObject {
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
  external JSArray<WebPlaybackArtist> get artists;
  // ignore: public_member_api_docs, non_constant_identifier_names
  external WebLinkedFrom get linked_from;
}

/// Spotify playback album object
extension type WebPlaybackAlbum._(JSObject _) implements JSObject {
  // ignore: public_member_api_docs
  external String get uri;
  // ignore: public_member_api_docs
  external String get name;
  // ignore: public_member_api_docs
  external JSArray<WebPlaybackAlbumImage> get images;
}

/// Spotify playback album object
extension type WebLinkedFrom._(JSObject _) implements JSObject {
  // ignore: public_member_api_docs
  external String get uri;
  // ignore: public_member_api_docs
  external String get id;
}

/// Spotify artist object
extension type WebPlaybackArtist._(JSObject _) implements JSObject {
  // ignore: public_member_api_docs
  external String get uri;
  // ignore: public_member_api_docs
  external String get name;
}

/// Spotify album image object
extension type WebPlaybackAlbumImage._(JSObject _) implements JSObject {
  // ignore: public_member_api_docs
  external String get url;
}

/// Spotify playback error object
extension type WebPlaybackError._(JSObject _) implements JSObject {
  // ignore: public_member_api_docs
  external String get message;
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
  SpotifyToken({
    required this.clientId,
    required this.accessToken,
    required this.refreshToken,
    required this.expiry,
  });
}
