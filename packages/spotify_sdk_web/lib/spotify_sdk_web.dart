import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:developer';
import 'dart:js_interop';

import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:spotify_sdk_platform_interface/platform_channels.dart';
import 'package:spotify_sdk_platform_interface/spotify_sdk_platform_interface.dart'
    hide PlayerOptions;
import 'package:spotify_sdk_web/src/api/spotify_web_api_client.dart';
import 'package:spotify_sdk_web/src/auth/oauth_window_adapter.dart';
import 'package:spotify_sdk_web/src/auth/spotify_auth_session.dart';
import 'package:spotify_sdk_web/src/interop/web_playback_sdk.dart';
import 'package:spotify_sdk_web/src/player/web_player_dispatcher.dart';
import 'package:web/web.dart' as web;

export 'package:spotify_sdk_platform_interface/enums/image_dimension_enum.dart';
export 'package:spotify_sdk_platform_interface/enums/repeat_mode_enum.dart';
export 'package:spotify_sdk_platform_interface/extensions/image_dimension_extension.dart';
export 'package:spotify_sdk_web/src/api/spotify_web_api_client.dart';
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
    SpotifyWebApiClient? webApiClient,
  }) : _authSession = authSession ?? SpotifyAuthSession() {
    _webApiClient =
        webApiClient ?? SpotifyWebApiClient(authSession: _authSession);
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
  late final SpotifyWebApiClient _webApiClient;

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

  /// Default scopes that are required for Web SDK to work
  static const String defaultScopes =
      'streaming user-read-email user-read-private '
      'user-modify-playback-state user-read-playback-state '
      'user-library-modify user-library-read';

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
      case MethodNames.getCrossfadeState:
        final crossfade = await getCrossFadeState();
        if (crossfade == null) return null;
        return jsonEncode(crossfade.toJson());
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
      case MethodNames.toggleShuffle:
        await toggleShuffle();
      case MethodNames.toggleRepeat:
        await toggleRepeat();
      case MethodNames.skipToIndex:
        final spotifyUri = arguments?[ParamNames.spotifyUri] as String?;
        final trackIndex = arguments?[ParamNames.trackIndex] as int?;
        if (spotifyUri != null && trackIndex != null) {
          await skipToIndex(spotifyUri: spotifyUri, trackIndex: trackIndex);
        }
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
        return jsonEncode(_playerDispatcher.toPlayerState(stateRaw)!.toJson());
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
  Future<CrossfadeState?> getCrossFadeState() async {
    if (!_sdkLoaded) {
      _sdkLoadFuture ??= _initializeSpotify();
      await _sdkLoadFuture;
    }
    return CrossfadeState(0, isEnabled: false);
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
    return _playerDispatcher.toPlayerState(stateRaw);
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
  Future<void> setPodcastPlaybackSpeed({
    required PodcastPlaybackSpeed podcastPlaybackSpeed,
  }) async {
    if (!_sdkLoaded) {
      _sdkLoadFuture ??= _initializeSpotify();
      await _sdkLoadFuture;
    }
    log('setPodcastPlaybackSpeed is not supported on Spotify Web API');
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
  Future<void> skipToIndex({
    required String spotifyUri,
    required int trackIndex,
  }) async {
    if (!_sdkLoaded) {
      _sdkLoadFuture ??= _initializeSpotify();
      await _sdkLoadFuture;
    }
    return _webApiClient.skipToIndex(
      spotifyUri: spotifyUri,
      trackIndex: trackIndex,
      deviceId: _currentPlayer?.deviceID,
    );
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
  Future<void> toggleShuffle() async {
    if (!_sdkLoaded) {
      _sdkLoadFuture ??= _initializeSpotify();
      await _sdkLoadFuture;
    }
    final currentState = await getPlayerState();
    final currentShuffle = currentState?.playbackOptions.isShuffling ?? false;
    await setShuffle(shuffle: !currentShuffle);
  }

  @override
  Future<void> toggleRepeat() async {
    if (!_sdkLoaded) {
      _sdkLoadFuture ??= _initializeSpotify();
      await _sdkLoadFuture;
    }
    final currentState = await getPlayerState();
    final currentMode =
        currentState?.playbackOptions.repeatMode ?? SpotifyRepeatMode.off;
    final nextMode = currentMode == SpotifyRepeatMode.off
        ? SpotifyRepeatMode.context
        : (currentMode == SpotifyRepeatMode.context
              ? SpotifyRepeatMode.track
              : SpotifyRepeatMode.off);
    await setRepeatMode(repeatMode: nextMode);
  }

  @override
  Future<void> addToLibrary({required String spotifyUri}) async {
    if (!_sdkLoaded) {
      _sdkLoadFuture ??= _initializeSpotify();
      await _sdkLoadFuture;
    }
    await _webApiClient.addToLibrary(spotifyUri: spotifyUri);
  }

  @override
  Future<void> removeFromLibrary({required String spotifyUri}) async {
    if (!_sdkLoaded) {
      _sdkLoadFuture ??= _initializeSpotify();
      await _sdkLoadFuture;
    }
    await _webApiClient.removeFromLibrary(spotifyUri: spotifyUri);
  }

  @override
  Future<Capabilities?> getCapabilities({
    required String spotifyUri,
  }) async {
    if (!_sdkLoaded) {
      _sdkLoadFuture ??= _initializeSpotify();
      await _sdkLoadFuture;
    }
    return Capabilities(canPlayOnDemand: true);
  }

  @override
  Future<LibraryState?> getLibraryState({
    required String spotifyUri,
  }) async {
    if (!_sdkLoaded) {
      _sdkLoadFuture ??= _initializeSpotify();
      await _sdkLoadFuture;
    }
    return _webApiClient.getLibraryState(spotifyUri: spotifyUri);
  }

  @override
  Future<void> switchToLocalDevice() async {
    if (!_sdkLoaded) {
      _sdkLoadFuture ??= _initializeSpotify();
      await _sdkLoadFuture;
    }
    return _webApiClient.switchToLocalDevice(
      deviceId: _currentPlayer?.deviceID,
    );
  }

  @override
  Future<Uint8List?> getImage({
    required ImageUri imageUri,
    ImageDimension dimension = ImageDimension.medium,
  }) async {
    if (!_sdkLoaded) {
      _sdkLoadFuture ??= _initializeSpotify();
      await _sdkLoadFuture;
    }
    return _webApiClient.getImage(imageUri: imageUri, dimension: dimension);
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

  /// Plays a track or context on the Spotify Web player.
  Future<void> _play(String? uri) => _webApiClient.play(
    uri: uri,
    deviceId: _currentPlayer?.deviceID,
  );

  /// Adds a given track to the playback queue.
  Future<void> _queue(String? uri) => _webApiClient.queue(
    uri: uri,
    deviceId: _currentPlayer?.deviceID,
  );

  /// Sets whether shuffle should be enabled.
  Future<void> _setShuffle(bool? shuffleEnabled) => _webApiClient.setShuffle(
    shuffleEnabled: shuffleEnabled,
    deviceId: _currentPlayer?.deviceID,
  );

  /// Sets the repeat mode.
  Future<void> _setRepeatMode(SpotifyRepeatMode? repeatMode) =>
      _webApiClient.setRepeatMode(
        repeatMode: repeatMode,
        deviceId: _currentPlayer?.deviceID,
      );
}
