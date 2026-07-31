// Known issue with JS interop analyzer in Dart - these functions are
// available at runtime
// but the analyzer cannot resolve them. This is a known limitation.
// See: https://github.com/dart-lang/sdk/issues/49651
// // The Spotify Web Playback SDK JS library uses snake_case and features
// methods that cannot be statically resolved by the Dart JS analyzer.
// ignore_for_file: non_constant_identifier_names
import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:developer';
import 'dart:js_interop';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:spotify_sdk_platform_interface/models/player_options.dart'
    as options;
import 'package:spotify_sdk_platform_interface/platform_channels.dart';
import 'package:spotify_sdk_platform_interface/spotify_sdk_platform_interface.dart';
import 'package:spotify_sdk_web/src/auth/spotify_auth_session.dart';
import 'package:web/web.dart' as web;

export 'package:spotify_sdk_platform_interface/enums/image_dimension_enum.dart';
export 'package:spotify_sdk_platform_interface/enums/repeat_mode_enum.dart';
export 'package:spotify_sdk_platform_interface/extensions/image_dimension_extension.dart';
export 'package:spotify_sdk_web/src/auth/auth_session_storage.dart';
export 'package:spotify_sdk_web/src/auth/oauth_window_adapter.dart';
export 'package:spotify_sdk_web/src/auth/spotify_auth_session.dart';

///
/// [SpotifySdkPlugin] is the web implementation of the Spotify SDK plugin.
///
class SpotifySdkPlugin extends SpotifySdkPlatform {
  /// constructor
  SpotifySdkPlugin(
    this.playerContextEventController,
    this.playerStateEventController,
    this.playerCapabilitiesEventController,
    this.userStateEventController,
    this.connectionStatusEventController, {
    SpotifyAuthSession? authSession,
  }) : _authSession = authSession ?? SpotifyAuthSession();

  final SpotifyAuthSession _authSession;

  /// authentication token error id
  static const String errorAuthenticationTokenError =
      'authenticationTokenError';

  /// spotify sdk url
  static const String spotifySdkUrl = 'https://sdk.scdn.co/spotify-player.js';

  /// Whether the Spotify SDK is loaded.
  bool _sdkLoaded = false;

  /// Future loading the Spotify SDK.
  Future<void>? _sdkLoadFuture;

  /// Current Spotify SDK player instance.
  Player? _currentPlayer;

  /// player context event stream controller
  final StreamController<String> playerContextEventController;

  /// player state event stream controller
  final StreamController<String> playerStateEventController;

  /// player capabilities event stream controller
  final StreamController<String> playerCapabilitiesEventController;

  /// user state event stream controller
  final StreamController<String> userStateEventController;

  /// connection status event stream controller
  final StreamController<String> connectionStatusEventController;

  /// Dio http client
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.spotify.com/v1/me/player',
    ),
  );

  /// Default scopes that are required for Web SDK to work
  static const String defaultScopes =
      'streaming user-read-email user-read-private';

  /// The URL for the token swap service.
  static String? get tokenSwapURL => SpotifyAuthSession.tokenSwapURL;
  static set tokenSwapURL(String? value) =>
      SpotifyAuthSession.tokenSwapURL = value;

  /// The URL for the token refresh service.
  static String? get tokenRefreshURL => SpotifyAuthSession.tokenRefreshURL;
  static set tokenRefreshURL(String? value) =>
      SpotifyAuthSession.tokenRefreshURL = value;

  /// registers plugin method channels
  static void registerWith(Registrar registrar) {
    // method channel
    final channel = MethodChannel(
      MethodChannels.spotifySdk,
      const StandardMethodCodec(),
      registrar,
    );
    // event channels
    const playerContextEventChannel = PluginEventChannel<String>(
      EventChannels.playerContext,
    );
    final playerContextEventController = StreamController<String>.broadcast();
    playerContextEventChannel.setController(playerContextEventController);
    const playerStateEventChannel = PluginEventChannel<String>(
      EventChannels.playerState,
    );
    final playerStateEventController = StreamController<String>.broadcast();
    playerStateEventChannel.setController(playerStateEventController);
    const playerCapabilitiesEventChannel = PluginEventChannel<String>(
      EventChannels.capabilities,
    );
    final playerCapabilitiesEventController =
        StreamController<String>.broadcast();
    playerCapabilitiesEventChannel.setController(
      playerCapabilitiesEventController,
    );
    const userStatusEventChannel = PluginEventChannel<String>(
      EventChannels.userStatus,
    );
    final userStatusEventController = StreamController<String>.broadcast();
    userStatusEventChannel.setController(userStatusEventController);
    const connectionStatusEventChannel = PluginEventChannel<String>(
      EventChannels.connectionStatus,
    );
    final connectionStatusEventController =
        StreamController<String>.broadcast();
    connectionStatusEventChannel.setController(connectionStatusEventController);

    final instance = SpotifySdkPlugin(
      playerContextEventController,
      playerStateEventController,
      playerCapabilitiesEventController,
      userStatusEventController,
      connectionStatusEventController,
    );

    SpotifySdkPlatform.instance = instance;
    channel.setMethodCallHandler(instance.handleMethodCall);
  }

  /// handles method coming through the method channel
  Future<dynamic> handleMethodCall(MethodCall call) async {
    // check if spotify is loaded
    if (!_sdkLoaded) {
      _sdkLoadFuture ??= _initializeSpotify();
      await _sdkLoadFuture;
    }

    final arguments = call.arguments as Map<dynamic, dynamic>?;

    switch (call.method) {
      case MethodNames.connectToSpotify:
        if (_currentPlayer != null) {
          return true;
        }
        log('Connecting to Spotify...');
        final clientId = arguments?[ParamNames.clientId] as String?;
        final redirectUrl = arguments?[ParamNames.redirectUrl] as String?;
        final playerName = arguments?[ParamNames.playerName] as String?;
        final scopes = arguments?[ParamNames.scope] as String? ?? defaultScopes;
        final accessToken = arguments?[ParamNames.accessToken] as String?;

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
          await _authSession.authorize(
            clientId: clientId,
            redirectUrl: redirectUrl,
            scopes: scopes,
          );
        }

        // create player
        _currentPlayer = Player(
          PlayerOptions(
            name: playerName,
            getOAuthToken: ((JSFunction callback, JSAny? t) {
              unawaited(
                _authSession.getValidToken().then((value) {
                  callback.callAsFunction(null, value.toJS);
                }),
              );
            }).toJS,
          ),
        );

        _registerPlayerEvents(_currentPlayer!);
        final result = await _currentPlayer!.connect().toDart;
        if (result != null && (result as JSBoolean).toDart) {
          // wait for the confirmation
          num time = 0;
          while (_currentPlayer!.deviceID == null) {
            await Future<void>.delayed(const Duration(milliseconds: 200));
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
        final clientId = arguments?[ParamNames.clientId] as String?;
        final redirectUrl = arguments?[ParamNames.redirectUrl] as String?;

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

        return _authSession.authorize(
          clientId: clientId,
          redirectUrl: redirectUrl,
          scopes: arguments?[ParamNames.scope] as String? ?? defaultScopes,
        );
      case MethodNames.disconnectFromSpotify:
        log('Disconnecting from Spotify...');
        _authSession.clearToken();
        if (_currentPlayer == null) {
          return true;
        } else {
          _currentPlayer!.disconnect();
          _onSpotifyDisconnected();
          return true;
        }
      case MethodNames.play:
        await _play(arguments?[ParamNames.spotifyUri] as String?);
      case MethodNames.queueTrack:
        await _queue(arguments?[ParamNames.spotifyUri] as String?);
      case MethodNames.setShuffle:
        await _setShuffle(arguments?[ParamNames.shuffle] as bool?);
      case MethodNames.setRepeatMode:
        await _setRepeatMode(
          arguments?[ParamNames.repeatMode] as SpotifyRepeatMode?,
        );
      case MethodNames.resume:
        await _currentPlayer?.resume().toDart;
      case MethodNames.pause:
        await _currentPlayer?.pause().toDart;
      case MethodNames.skipNext:
        await _currentPlayer?.nextTrack().toDart;
      case MethodNames.skipPrevious:
        await _currentPlayer?.previousTrack().toDart;
      case MethodNames.getPlayerState:
        final stateRaw =
            (await _currentPlayer?.getCurrentState().toDart)
                as WebPlaybackState?;
        if (stateRaw == null) return null;
        return jsonEncode(toPlayerState(stateRaw)!.toJson());
      default:
        throw PlatformException(
          code: 'Unimplemented',
          details: "Method '${call.method}' not implemented in web spotify_sdk",
        );
    }
  }

  @override
  Future<bool> connectToSpotifyRemote({
    required String clientId,
    required String redirectUrl,
    String spotifyUri = '',
    bool asRadio = false,
    String? scope,
    String playerName = 'Spotify SDK',
    String? accessToken,
  }) async {
    if (!_sdkLoaded) {
      _sdkLoadFuture ??= _initializeSpotify();
      await _sdkLoadFuture;
    }
    if (_currentPlayer != null) {
      return true;
    }
    log('Connecting to Spotify...');
    final scopes = scope ?? defaultScopes;

    if (clientId.isEmpty || redirectUrl.isEmpty) {
      throw PlatformException(
        message: 'Client id or redirectUrl are not set or have invalid format',
        code: 'Authentication Error',
      );
    }

    if (accessToken == null || accessToken.isEmpty) {
      await _authSession.authorize(
        clientId: clientId,
        redirectUrl: redirectUrl,
        scopes: scopes,
      );
    }

    _currentPlayer = Player(
      PlayerOptions(
        name: playerName,
        getOAuthToken: ((JSFunction callback, JSAny? t) {
          unawaited(
            _authSession.getValidToken().then((value) {
              callback.callAsFunction(null, value.toJS);
            }),
          );
        }).toJS,
      ),
    );

    _registerPlayerEvents(_currentPlayer!);
    final result = await _currentPlayer!.connect().toDart;
    if (result != null && (result as JSBoolean).toDart) {
      num time = 0;
      while (_currentPlayer!.deviceID == null) {
        await Future<void>.delayed(const Duration(milliseconds: 200));
        time += 200;
        if (time > 10000) {
          return false;
        }
      }
      return true;
    } else {
      _onSpotifyDisconnected(
        errorCode: 'Initialization Error',
        errorDetails: 'Attempt to connect to the Spotify SDK failed',
      );
      return false;
    }
  }

  @override
  Future<String> getAccessToken({
    required String clientId,
    required String redirectUrl,
    String spotifyUri = '',
    bool asRadio = false,
    String? scope,
  }) async {
    if (!_sdkLoaded) {
      _sdkLoadFuture ??= _initializeSpotify();
      await _sdkLoadFuture;
    }
    if (clientId.isEmpty || redirectUrl.isEmpty) {
      throw PlatformException(
        message: 'Client id or redirectUrl are not set or have invalid format',
        code: 'Authentication Error',
      );
    }
    return _authSession.authorize(
      clientId: clientId,
      redirectUrl: redirectUrl,
      scopes: scope ?? defaultScopes,
    );
  }

  @override
  Future<bool> disconnect() async {
    if (!_sdkLoaded) {
      _sdkLoadFuture ??= _initializeSpotify();
      await _sdkLoadFuture;
    }
    log('Disconnecting from Spotify...');
    _authSession.clearToken();
    if (_currentPlayer == null) {
      return true;
    } else {
      _currentPlayer!.disconnect();
      _onSpotifyDisconnected();
      return true;
    }
  }

  @override
  Future<PlayerState?> getPlayerState() async {
    if (!_sdkLoaded) {
      _sdkLoadFuture ??= _initializeSpotify();
      await _sdkLoadFuture;
    }
    final stateRaw =
        (await _currentPlayer?.getCurrentState().toDart) as WebPlaybackState?;
    if (stateRaw == null) return null;
    return toPlayerState(stateRaw);
  }

  @override
  Future<void> queue({required String spotifyUri}) async {
    if (!_sdkLoaded) {
      _sdkLoadFuture ??= _initializeSpotify();
      await _sdkLoadFuture;
    }
    await _queue(spotifyUri);
  }

  @override
  Future<void> play({
    required String spotifyUri,
    bool asRadio = false,
  }) async {
    if (!_sdkLoaded) {
      _sdkLoadFuture ??= _initializeSpotify();
      await _sdkLoadFuture;
    }
    await _play(spotifyUri);
  }

  @override
  Future<void> pause() async {
    if (!_sdkLoaded) {
      _sdkLoadFuture ??= _initializeSpotify();
      await _sdkLoadFuture;
    }
    await _currentPlayer?.pause().toDart;
  }

  @override
  Future<void> resume() async {
    if (!_sdkLoaded) {
      _sdkLoadFuture ??= _initializeSpotify();
      await _sdkLoadFuture;
    }
    await _currentPlayer?.resume().toDart;
  }

  @override
  Future<void> skipNext() async {
    if (!_sdkLoaded) {
      _sdkLoadFuture ??= _initializeSpotify();
      await _sdkLoadFuture;
    }
    await _currentPlayer?.nextTrack().toDart;
  }

  @override
  Future<void> skipPrevious() async {
    if (!_sdkLoaded) {
      _sdkLoadFuture ??= _initializeSpotify();
      await _sdkLoadFuture;
    }
    await _currentPlayer?.previousTrack().toDart;
  }

  @override
  Future<void> seekTo({required int positionedMilliseconds}) async {
    if (!_sdkLoaded) {
      _sdkLoadFuture ??= _initializeSpotify();
      await _sdkLoadFuture;
    }
    await _currentPlayer?.seek(positionedMilliseconds).toDart;
  }

  @override
  Future<void> setShuffle({required bool shuffle}) async {
    if (!_sdkLoaded) {
      _sdkLoadFuture ??= _initializeSpotify();
      await _sdkLoadFuture;
    }
    await _setShuffle(shuffle);
  }

  @override
  Future<void> setRepeatMode({required SpotifyRepeatMode repeatMode}) async {
    if (!_sdkLoaded) {
      _sdkLoadFuture ??= _initializeSpotify();
      await _sdkLoadFuture;
    }
    await _setRepeatMode(repeatMode);
  }

  @override
  Stream<PlayerContext> subscribePlayerContext() {
    return playerContextEventController.stream.map((playerContextJson) {
      final playerContextMap =
          jsonDecode(playerContextJson) as Map<String, dynamic>;
      return PlayerContext.fromJson(playerContextMap);
    });
  }

  @override
  Stream<PlayerState> subscribePlayerState() {
    return playerStateEventController.stream.map((playerStateJson) {
      final playerStateMap =
          jsonDecode(playerStateJson) as Map<String, dynamic>;
      return PlayerState.fromJson(playerStateMap);
    });
  }

  @override
  Stream<ConnectionStatus> subscribeConnectionStatus() {
    return connectionStatusEventController.stream.map((connectionStatusJson) {
      final connectionStatusMap =
          jsonDecode(connectionStatusJson) as Map<String, dynamic>;
      return ConnectionStatus.fromJson(connectionStatusMap);
    });
  }

  @override
  Stream<Capabilities> subscribeCapabilities() {
    return playerCapabilitiesEventController.stream.map((capabilitiesJson) {
      final capabilitiesMap =
          jsonDecode(capabilitiesJson) as Map<String, dynamic>;
      return Capabilities.fromJson(capabilitiesMap);
    });
  }

  @override
  Stream<UserStatus> subscribeUserStatus() {
    return userStateEventController.stream.map((userStatusJson) {
      final userStatusMap = jsonDecode(userStatusJson) as Map<String, dynamic>;
      return UserStatus.fromJson(userStatusMap);
    });
  }

  /// Loads the Spotify SDK library.
  Future<void> _initializeSpotify() async {
    if (_onSpotifyWebPlaybackSDKReady == null) {
      log('Loading Spotify SDK...');

      // link spotify ready function
      _onSpotifyWebPlaybackSDKReady = _onSpotifyInitialized.toJS;

      // load spotify sdk
      final script = web.HTMLScriptElement()..src = spotifySdkUrl;
      web.document.body?.append(script);

      // wait for initialization
      while (!_sdkLoaded) {
        await Future<void>.delayed(const Duration(milliseconds: 200));
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
    player
      ..addListener(
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
      )
      // ready/not ready
      ..addListener(
        'ready',
        ((WebPlaybackPlayer player) {
          log('Spotify SDK ready!');
          _onSpotifyConnected(player.device_id ?? '');
        }).toJS,
      )
      ..addListener(
        'not_ready',
        ((JSAny? event) {
          _onSpotifyDisconnected(
            errorCode: 'Spotify SDK not ready',
            errorDetails: 'Spotify SDK is not ready to take requests',
          );
        }).toJS,
      )
      ..addListener(
        'initialization_error',
        ((WebPlaybackError error) {
          _onSpotifyDisconnected(
            errorCode: 'Initialization Error',
            errorDetails: error.message ?? '',
          );
        }).toJS,
      )
      ..addListener(
        'authentication_error',
        ((WebPlaybackError error) {
          // If the error is due to browser security, don't disconnect.
          // The user needs to interact with the SDK to trigger media
          // activation.
          // https://developer.spotify.com/documentation/web-playback-sdk/quick-start/#mobile-support
          if (error.message != null &&
              error.message!.contains('Browser prevented autoplay')) {
            log('authentication_error: ${error.message}');
            return;
          }
          _onSpotifyDisconnected(
            errorCode: 'Authentication Error',
            errorDetails: error.message ?? '',
          );
        }).toJS,
      )
      ..addListener(
        'account_error',
        ((WebPlaybackError error) {
          _onSpotifyDisconnected(
            errorCode: 'Account Error',
            errorDetails: error.message ?? '',
          );
        }).toJS,
      )
      ..addListener(
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
    _currentPlayer!.deviceID = deviceId;

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

  void _unregisterPlayerEvents(Player player) {
    player
      ..removeListener('player_state_changed')
      ..removeListener('ready')
      ..removeListener('not_ready')
      ..removeListener('initialization_error')
      ..removeListener('authentication_error')
      ..removeListener('account_error')
      ..removeListener('playback_error');
  }

  /// Starts track playback on the device.
  Future<void> _play(String? uri) async {
    if (_currentPlayer?.deviceID == null) {
      throw PlatformException(
        message: 'Spotify player not connected!',
        code: 'Playback Error',
      );
    }

    await _dio.put<void>(
      '/play',
      data: {
        'uris': [uri],
      },
      queryParameters: {'device_id': _currentPlayer!.deviceID},
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _authSession.getValidToken()}',
        },
      ),
    );
  }

  /// Adds a given track to the playback queue.
  Future<void> _queue(String? uri) async {
    if (_currentPlayer?.deviceID == null) {
      throw PlatformException(
        message: 'Spotify player not connected!',
        code: 'Playback Error',
      );
    }

    await _dio.post<void>(
      '/queue',
      queryParameters: {'uri': uri, 'device_id': _currentPlayer!.deviceID},
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _authSession.getValidToken()}',
        },
      ),
    );
  }

  /// Sets whether shuffle should be enabled.
  Future<void> _setShuffle(bool? shuffleEnabled) async {
    if (_currentPlayer?.deviceID == null) {
      throw PlatformException(
        message: 'Spotify player not connected!',
        code: 'Set Shuffle Error',
      );
    }

    await _dio.put<void>(
      '/shuffle',
      queryParameters: {
        'state': shuffleEnabled,
        'device_id': _currentPlayer!.deviceID,
      },
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _authSession.getValidToken()}',
        },
      ),
    );
  }

  /// Sets the repeat mode.
  Future<void> _setRepeatMode(SpotifyRepeatMode? repeatMode) async {
    if (_currentPlayer?.deviceID == null) {
      throw PlatformException(
        message: 'Spotify player not connected!',
        code: 'Set Repeat Mode Error',
      );
    }

    await _dio.put<void>(
      '/repeat',
      queryParameters: {
        'state': repeatMode.toString().substring(18),
        'device_id': _currentPlayer!.deviceID,
      },
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _authSession.getValidToken()}',
        },
      ),
    );
  }

  /// Toggles shuffle on the current player.
  @override
  Future<void> toggleShuffle({bool? state}) async {
    if (_currentPlayer?.deviceID == null) {
      throw PlatformException(
        message: 'Spotify player not connected!',
        code: 'Playback Error',
      );
    }

    await _dio.put<void>(
      '/shuffle',
      queryParameters: {'state': state, 'device_id': _currentPlayer!.deviceID},
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _authSession.getValidToken()}',
        },
      ),
    );
  }

  /// Toggles repeat on the current player.
  @override
  Future<void> toggleRepeat({bool? state}) async {
    if (_currentPlayer?.deviceID == null) {
      throw PlatformException(
        message: 'Spotify player not connected!',
        code: 'Playback Error',
      );
    }

    await _dio.put<void>(
      '/repeat',
      queryParameters: {'state': state, 'device_id': _currentPlayer!.deviceID},
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _authSession.getValidToken()}',
        },
      ),
    );
  }

  /// Converts a native WebPlaybackState to the library PlayerState
  PlayerState? toPlayerState(WebPlaybackState? state) {
    if (state == null) return null;
    final trackRaw = state.track_window?.current_track;
    final albumRaw = trackRaw?.album;
    final artists = <Artist>[];

    if (trackRaw != null && trackRaw.artists != null) {
      for (final artist in trackRaw.artists!.toDart) {
        artists.add(Artist(artist.name ?? '', artist.uri ?? ''));
      }
    }

    if (artists.isEmpty) {
      artists.add(Artist('', ''));
    }

    // getting repeat mode
    SpotifyRepeatMode repeatMode;
    switch (state.repeat_mode) {
      case 1:
        repeatMode = SpotifyRepeatMode.context;
      case 2:
        repeatMode = SpotifyRepeatMode.track;
      default:
        repeatMode = SpotifyRepeatMode.off;
    }

    final imageUrl =
        (albumRaw?.images != null && albumRaw!.images!.toDart.isNotEmpty)
        ? albumRaw.images!.toDart[0].url ?? ''
        : '';

    return PlayerState(
      trackRaw != null
          ? Track(
              Album(albumRaw?.name ?? '', albumRaw?.uri ?? ''),
              artists[0],
              artists,
              -1,
              ImageUri(imageUrl),
              trackRaw.name ?? '',
              trackRaw.uri ?? '',
              trackRaw.linked_from?.uri ?? '',
              isEpisode: trackRaw.type == 'episode',
              isPodcast: trackRaw.type == 'episode',
            )
          : null,
      1,
      state.position ?? 0,
      options.PlayerOptions(repeatMode, isShuffling: state.shuffle ?? false),
      PlayerRestrictions(
        canSkipNext: true,
        canSkipPrevious: true,
        canSeek: true,
        canRepeatTrack: true,
        canRepeatContext: true,
        canToggleShuffle: true,
      ),
      isPaused: state.paused ?? true,
    );
  }

  /// Converts a native WebPlaybackState to the library PlayerContext
  PlayerContext? toPlayerContext(WebPlaybackState? state) {
    if (state == null) return null;
    final context = state.context;
    final metadata = context?.metadata;
    return PlayerContext(
      metadata?.title ?? '',
      metadata?.subtitle ?? '',
      metadata?.type ?? '',
      context?.uri ?? '',
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
extension type Player._(JSObject _) implements JSObject {
  /// The main constructor for initializing the Web Playback SDK.
  /// It should contain an object with the player name, volume and access token.
  external Player(PlayerOptions options);

  /// Device id of the player.
  external String? get deviceID;
  external set deviceID(String? value);

  /// Connects Web Playback SDK instance to Spotify
  /// with the credentials provided during initialization.
  external JSPromise connect();

  /// Closes the current session that Web Playback SDK has with Spotify.
  external void disconnect();

  /// Create a new event listener in the Web Playback SDK.
  external void addListener(String type, JSFunction callback);

  /// Remove an event listener in the Web Playback SDK.
  external void removeListener(String eventName);

  /// Collect metadata on local playback.
  external JSPromise getCurrentState();

  /// Rename the Spotify Player device.
  /// This is visible across all Spotify Connect devices.
  external JSPromise setName(String name);

  /// Set the local volume for the Web Playback SDK.
  external JSPromise setVolume(double volume);

  /// Pause the local playback.
  external JSPromise pause();

  /// Resume the local playback.
  external JSPromise resume();

  /// Resume/pause the local playback.
  external JSPromise togglePlay();

  /// Seek to a position in the current track in local playback.
  external JSPromise seek(int positionMs);

  /// Switch to the previous track in local playback.
  external JSPromise previousTrack();

  /// Skip to the next track in local playback.
  external JSPromise nextTrack();
}

/// Spotify player options object
@JS()
extension type PlayerOptions._(JSObject _) implements JSObject {
  /// constructor
  external factory PlayerOptions({
    String? name,
    JSFunction? getOAuthToken,
    double? volume,
  });

  /// name
  external String? get name;

  /// getOAuthToken
  external JSFunction? get getOAuthToken;

  /// volume
  external double? get volume;
}

/// Spotify playback object
@JS()
extension type WebPlaybackPlayer._(JSObject _) implements JSObject {
  /// constructor
  external factory WebPlaybackPlayer({String? device_id});

  /// device id
  external String? get device_id;
}

/// Spotify playback state object
@JS()
extension type WebPlaybackState._(JSObject _) implements JSObject {
  /// constructor
  external factory WebPlaybackState({
    WebPlayerContext? context,
    WebPlayerDisallows? disallows,
    bool? paused,
    int? position,
    int? repeat_mode,
    bool? shuffle,
    WebPlayerTrackWindow? track_window,
  });

  /// context
  external WebPlayerContext? get context;

  /// disallows
  external WebPlayerDisallows? get disallows;

  /// paused
  external bool? get paused;

  /// position
  external int? get position;

  /// repeat mode
  external int? get repeat_mode;

  /// shuffle
  external bool? get shuffle;

  /// track window
  external WebPlayerTrackWindow? get track_window;
}

/// Spotify player context object
@JS()
extension type WebPlayerContext._(JSObject _) implements JSObject {
  /// constructor
  external factory WebPlayerContext({
    String? uri,
    WebPlayerContextMetadata? metadata,
  });

  /// uri
  external String? get uri;

  /// metadata
  external WebPlayerContextMetadata? get metadata;
}

/// Spotify player context metadata object
@JS()
extension type WebPlayerContextMetadata._(JSObject _) implements JSObject {
  /// constructor
  external factory WebPlayerContextMetadata({
    String? title,
    String? subtitle,
    String? type,
  });

  /// title
  external String? get title;

  /// subtitle
  external String? get subtitle;

  /// type
  external String? get type;
}

/// Spotify player disallows object
@JS()
extension type WebPlayerDisallows._(JSObject _) implements JSObject {
  /// constructor
  external factory WebPlayerDisallows({
    bool? pausing,
    bool? peeking_next,
    bool? peeking_prev,
    bool? resuming,
    bool? seeking,
    bool? skipping_next,
    bool? skipping_prev,
  });

  /// pausing
  external bool? get pausing;

  /// peeking next
  external bool? get peeking_next;

  /// peeking prev
  external bool? get peeking_prev;

  /// resuming
  external bool? get resuming;

  /// seeking
  external bool? get seeking;

  /// skipping next
  external bool? get skipping_next;

  /// skipping prev
  external bool? get skipping_prev;
}

/// Spotify player track window object
@JS()
extension type WebPlayerTrackWindow._(JSObject _) implements JSObject {
  /// constructor
  external factory WebPlayerTrackWindow({
    WebPlaybackTrack? current_track,
    JSArray<WebPlaybackTrack>? previous_tracks,
    JSArray<WebPlaybackTrack>? next_tracks,
  });

  /// current track
  external WebPlaybackTrack? get current_track;

  /// previous tracks
  external JSArray<WebPlaybackTrack>? get previous_tracks;

  /// next tracks
  external JSArray<WebPlaybackTrack>? get next_tracks;
}

/// Spotify playback track object
@JS()
extension type WebPlaybackTrack._(JSObject _) implements JSObject {
  /// constructor
  external factory WebPlaybackTrack({
    String? uri,
    String? id,
    String? type,
    String? media_type,
    String? name,
    bool? is_playable,
    WebPlaybackAlbum? album,
    JSArray<WebPlaybackArtist>? artists,
    WebLinkedFrom? linked_from,
  });

  /// uri
  external String? get uri;

  /// id
  external String? get id;

  /// type
  external String? get type;

  /// media type
  external String? get media_type;

  /// name
  external String? get name;

  /// is playable
  external bool? get is_playable;

  /// album
  external WebPlaybackAlbum? get album;

  /// artists
  external JSArray<WebPlaybackArtist>? get artists;

  /// linked from
  external WebLinkedFrom? get linked_from;
}

/// Spotify playback album object
@JS()
extension type WebPlaybackAlbum._(JSObject _) implements JSObject {
  /// constructor
  external factory WebPlaybackAlbum({
    String? uri,
    String? name,
    JSArray<WebPlaybackAlbumImage>? images,
  });

  /// uri
  external String? get uri;

  /// name
  external String? get name;

  /// images
  external JSArray<WebPlaybackAlbumImage>? get images;
}

/// Spotify playback album object
@JS()
extension type WebLinkedFrom._(JSObject _) implements JSObject {
  /// constructor
  external factory WebLinkedFrom({String? uri, String? id});

  /// uri
  external String? get uri;

  /// id
  external String? get id;
}

/// Spotify artist object
@JS()
extension type WebPlaybackArtist._(JSObject _) implements JSObject {
  /// constructor
  external factory WebPlaybackArtist({String? uri, String? name});

  /// uri
  external String? get uri;

  /// name
  external String? get name;
}

/// Spotify album image object
@JS()
extension type WebPlaybackAlbumImage._(JSObject _) implements JSObject {
  /// constructor
  external factory WebPlaybackAlbumImage({String? url});

  /// url
  external String? get url;
}

/// Spotify playback error object
@JS()
extension type WebPlaybackError._(JSObject _) implements JSObject {
  /// constructor
  external factory WebPlaybackError({String? message});

  /// message
  external String? get message;
}

/// Spotify token object.
class SpotifyToken {
  /// constructor
  SpotifyToken({
    required this.clientId,
    required this.accessToken,
    required this.refreshToken,
    required this.expiry,
  });

  /// Currently used client id.
  final String clientId;

  /// Access token data.
  final String accessToken;

  /// Refresh token data.
  final String refreshToken;

  /// Token expiry time in unix seconds.
  final int expiry;
}
