import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:developer';
import 'dart:js_interop';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:spotify_sdk_platform_interface/platform_channels.dart';
import 'package:spotify_sdk_platform_interface/spotify_sdk_platform_interface.dart'
    hide PlayerOptions;
import 'package:spotify_sdk_web/src/auth/oauth_window_adapter.dart';
import 'package:spotify_sdk_web/src/auth/spotify_auth_session.dart';
import 'package:spotify_sdk_web/src/interop/web_playback_sdk.dart';
import 'package:spotify_sdk_web/src/player/web_player_dispatcher.dart';
import 'package:web/web.dart' as web;

export 'package:spotify_sdk_platform_interface/enums/image_dimension_enum.dart';
export 'package:spotify_sdk_platform_interface/enums/repeat_mode_enum.dart';
export 'package:spotify_sdk_platform_interface/extensions/image_dimension_extension.dart';
export 'package:spotify_sdk_web/src/auth/auth_session_storage.dart';
export 'package:spotify_sdk_web/src/auth/oauth_window_adapter.dart';
export 'package:spotify_sdk_web/src/auth/spotify_auth_session.dart';
export 'package:spotify_sdk_web/src/interop/web_playback_sdk.dart';
export 'package:spotify_sdk_web/src/player/web_player_dispatcher.dart';

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
    WebPlayerDispatcher? playerDispatcher,
  }) : _authSession = authSession ?? SpotifyAuthSession() {
    _playerDispatcher =
        playerDispatcher ??
        WebPlayerDispatcher(
          playerContextEventController: playerContextEventController,
          playerStateEventController: playerStateEventController,
          connectionStatusEventController: connectionStatusEventController,
          onSpotifyConnected: _onSpotifyConnected,
          onSpotifyDisconnected: _onSpotifyDisconnected,
        );
  }

  final SpotifyAuthSession _authSession;
  late final WebPlayerDispatcher _playerDispatcher;

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
      'streaming user-read-email user-read-private '
      'user-modify-playback-state user-read-playback-state';

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
    BrowserWindowAdapter.handlePopupCallback();

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
  Future<void> seekToRelativePosition({
    required int relativeMilliseconds,
  }) async {
    if (!_sdkLoaded) {
      _sdkLoadFuture ??= _initializeSpotify();
      await _sdkLoadFuture;
    }
    final stateRaw =
        (await _currentPlayer?.getCurrentState().toDart) as WebPlaybackState?;
    final currentPos = stateRaw?.position ?? 0;
    final targetPos = (currentPos + relativeMilliseconds).clamp(0, 86400000);
    await _currentPlayer?.seek(targetPos).toDart;
  }

  @override
  Future<void> switchToLocalDevice() async {
    if (_currentPlayer?.deviceID == null) {
      throw PlatformException(
        message: 'Spotify player not connected!',
        code: 'Connect Error',
      );
    }
    try {
      final token = await _authSession.getValidToken();
      await _dio.put<void>(
        '',
        data: {
          'device_ids': [_currentPlayer!.deviceID],
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );
    } on Object catch (e) {
      final message = e is DioException && e.response?.data != null
          ? '${e.response?.data}'
          : '$e';
      throw PlatformException(
        message: 'Switch to local device failed: $message',
        code: 'Connect Error',
      );
    }
  }

  @override
  Future<Uint8List?> getImage({
    required ImageUri imageUri,
    ImageDimension dimension = ImageDimension.medium,
  }) async {
    final rawUri = imageUri.raw;
    if (rawUri.isEmpty) {
      return null;
    }

    final String imageUrl;
    if (rawUri.startsWith('http://') || rawUri.startsWith('https://')) {
      imageUrl = rawUri;
    } else if (rawUri.startsWith('spotify:image:')) {
      final imageHash = rawUri.split(':').last;
      imageUrl = 'https://i.scdn.co/image/$imageHash';
    } else {
      imageUrl = 'https://i.scdn.co/image/$rawUri';
    }

    try {
      final response = await _dio.get<List<int>>(
        imageUrl,
        options: Options(responseType: ResponseType.bytes),
      );
      if (response.data != null) {
        return Uint8List.fromList(response.data!);
      }
      return null;
    } on Object catch (e) {
      log('Failed to fetch image: $e');
      return null;
    }
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
    if (onSpotifyWebPlaybackSDKReady == null) {
      log('Loading Spotify SDK...');

      // link spotify ready function
      onSpotifyWebPlaybackSDKReady = _onSpotifyInitialized.toJS;

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
    _playerDispatcher.registerPlayerEvents(player);
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
    if (_currentPlayer != null) {
      _unregisterPlayerEvents(_currentPlayer!);
      _currentPlayer = null;
    }

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
    _playerDispatcher.unregisterPlayerEvents(player);
  }

  /// Starts track playback on the device.
  Future<void> _play(String? uri) async {
    if (_currentPlayer?.deviceID == null) {
      throw PlatformException(
        message: 'Spotify player not connected!',
        code: 'Playback Error',
      );
    }

    try {
      final token = await _authSession.getValidToken();
      await _dio.put<void>(
        '/play',
        data: {
          if (uri != null && uri.isNotEmpty) 'uris': [uri],
        },
        queryParameters: {'device_id': _currentPlayer!.deviceID},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );
    } on Object catch (e) {
      final message = e is DioException && e.response?.data != null
          ? '${e.response?.data}'
          : '$e';
      throw PlatformException(
        message: 'Play failed: $message',
        code: 'Playback Error',
      );
    }
  }

  /// Adds a given track to the playback queue.
  Future<void> _queue(String? uri) async {
    if (_currentPlayer?.deviceID == null) {
      throw PlatformException(
        message: 'Spotify player not connected!',
        code: 'Playback Error',
      );
    }

    try {
      final token = await _authSession.getValidToken();
      await _dio.post<void>(
        '/queue',
        queryParameters: {'uri': uri, 'device_id': _currentPlayer!.deviceID},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );
    } on Object catch (e) {
      final message = e is DioException && e.response?.data != null
          ? '${e.response?.data}'
          : '$e';
      throw PlatformException(
        message: 'Queue failed: $message',
        code: 'Playback Error',
      );
    }
  }

  /// Sets whether shuffle should be enabled.
  Future<void> _setShuffle(bool? shuffleEnabled) async {
    if (_currentPlayer?.deviceID == null) {
      throw PlatformException(
        message: 'Spotify player not connected!',
        code: 'Set Shuffle Error',
      );
    }

    try {
      final token = await _authSession.getValidToken();
      await _dio.put<void>(
        '/shuffle',
        queryParameters: {
          'state': (shuffleEnabled ?? true).toString(),
          'device_id': _currentPlayer!.deviceID,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );
    } on Object catch (e) {
      final message = e is DioException && e.response?.data != null
          ? '${e.response?.data}'
          : '$e';
      throw PlatformException(
        message: 'Set shuffle failed: $message',
        code: 'Set Shuffle Error',
      );
    }
  }

  /// Sets the repeat mode.
  Future<void> _setRepeatMode(SpotifyRepeatMode? repeatMode) async {
    if (_currentPlayer?.deviceID == null) {
      throw PlatformException(
        message: 'Spotify player not connected!',
        code: 'Set Repeat Mode Error',
      );
    }

    try {
      final token = await _authSession.getValidToken();
      final modeStr = repeatMode?.name ?? 'off';
      await _dio.put<void>(
        '/repeat',
        queryParameters: {
          'state': modeStr,
          'device_id': _currentPlayer!.deviceID,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );
    } on Object catch (e) {
      final message = e is DioException && e.response?.data != null
          ? '${e.response?.data}'
          : '$e';
      throw PlatformException(
        message: 'Set repeat mode failed: $message',
        code: 'Set Repeat Mode Error',
      );
    }
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

    try {
      final token = await _authSession.getValidToken();
      final bool targetState;
      if (state != null) {
        targetState = state;
      } else {
        final currentState =
            (await _currentPlayer?.getCurrentState().toDart)
                as WebPlaybackState?;
        targetState = !(currentState?.shuffle ?? false);
      }
      await _dio.put<void>(
        '/shuffle',
        queryParameters: {
          'state': targetState.toString(),
          'device_id': _currentPlayer!.deviceID,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );
    } on Object catch (e) {
      final message = e is DioException && e.response?.data != null
          ? '${e.response?.data}'
          : '$e';
      throw PlatformException(
        message: 'Toggle shuffle failed: $message',
        code: 'Playback Error',
      );
    }
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

    try {
      final token = await _authSession.getValidToken();
      final String targetMode;
      if (state != null) {
        targetMode = state ? 'context' : 'off';
      } else {
        final currentState =
            (await _currentPlayer?.getCurrentState().toDart)
                as WebPlaybackState?;
        final currentMode = currentState?.repeat_mode ?? 0;
        switch (currentMode) {
          case 0:
            targetMode = 'context';
          case 1:
            targetMode = 'track';
          case 2:
          default:
            targetMode = 'off';
        }
      }
      await _dio.put<void>(
        '/repeat',
        queryParameters: {
          'state': targetMode,
          'device_id': _currentPlayer!.deviceID,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );
    } on Object catch (e) {
      final message = e is DioException && e.response?.data != null
          ? '${e.response?.data}'
          : '$e';
      throw PlatformException(
        message: 'Toggle repeat failed: $message',
        code: 'Playback Error',
      );
    }
  }

  /// Converts a native WebPlaybackState to the library PlayerState
  PlayerState? toPlayerState(WebPlaybackState? state) {
    return _playerDispatcher.toPlayerState(state);
  }

  /// Converts a native WebPlaybackState to the library PlayerContext
  PlayerContext? toPlayerContext(WebPlaybackState? state) {
    return _playerDispatcher.toPlayerContext(state);
  }
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
