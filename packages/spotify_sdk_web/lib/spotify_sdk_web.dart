import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:spotify_sdk_platform_interface/platform_channels.dart';
import 'package:spotify_sdk_platform_interface/spotify_sdk_platform_interface.dart'
    hide PlayerOptions;
import 'package:spotify_sdk_web/src/api/spotify_web_api_client.dart';
import 'package:spotify_sdk_web/src/auth/oauth_window_adapter.dart';
import 'package:spotify_sdk_web/src/auth/spotify_auth_session.dart';
import 'package:spotify_sdk_web/src/loader/web_sdk_loader.dart';
import 'package:spotify_sdk_web/src/player/web_player_dispatcher.dart';
import 'package:spotify_sdk_web/src/player/web_player_manager.dart';

export 'package:spotify_sdk_platform_interface/enums/image_dimension_enum.dart';
export 'package:spotify_sdk_platform_interface/enums/repeat_mode_enum.dart';
export 'package:spotify_sdk_platform_interface/extensions/image_dimension_extension.dart';
export 'package:spotify_sdk_web/src/api/spotify_web_api_client.dart';
export 'package:spotify_sdk_web/src/auth/auth_session_storage.dart';
export 'package:spotify_sdk_web/src/auth/oauth_window_adapter.dart';
export 'package:spotify_sdk_web/src/auth/spotify_auth_session.dart';
export 'package:spotify_sdk_web/src/interop/web_playback_sdk.dart';
export 'package:spotify_sdk_web/src/loader/web_sdk_loader.dart';
export 'package:spotify_sdk_web/src/player/web_player_dispatcher.dart';
export 'package:spotify_sdk_web/src/player/web_player_manager.dart';

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
    WebSdkLoader? sdkLoader,
    WebPlayerManager? playerManager,
  }) : _authSession = authSession ?? SpotifyAuthSession(),
       _sdkLoader = sdkLoader ?? WebSdkLoader() {
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
    _playerManager =
        playerManager ??
        WebPlayerManager(
          authSession: _authSession,
          playerDispatcher: _playerDispatcher,
        );
  }

  final SpotifyAuthSession _authSession;
  final WebSdkLoader _sdkLoader;
  late final WebPlayerDispatcher _playerDispatcher;
  late final SpotifyWebApiClient _webApiClient;
  late final WebPlayerManager _playerManager;

  /// authentication token error id
  static const String errorAuthenticationTokenError =
      'authenticationTokenError';

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
    connectionStatusEventChannel.setController(
      connectionStatusEventController,
    );

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

  /// Handles legacy method channel invocations by delegating directly to typed
  /// platform interface methods.
  Future<dynamic> handleMethodCall(MethodCall call) async {
    final arguments = call.arguments as Map<dynamic, dynamic>?;

    switch (call.method) {
      case MethodNames.connectToSpotify:
        return connectToSpotifyRemote(
          clientId: arguments?[ParamNames.clientId] as String? ?? '',
          redirectUrl: arguments?[ParamNames.redirectUrl] as String? ?? '',
          spotifyUri: arguments?[ParamNames.spotifyUri] as String? ?? '',
          asRadio: arguments?[ParamNames.asRadio] as bool? ?? false,
          scope: arguments?[ParamNames.scope] as String?,
          playerName:
              arguments?[ParamNames.playerName] as String? ?? 'Spotify SDK',
          accessToken: arguments?[ParamNames.accessToken] as String?,
        );
      case MethodNames.getAccessToken:
        return getAccessToken(
          clientId: arguments?[ParamNames.clientId] as String? ?? '',
          redirectUrl: arguments?[ParamNames.redirectUrl] as String? ?? '',
          spotifyUri: arguments?[ParamNames.spotifyUri] as String? ?? '',
          asRadio: arguments?[ParamNames.asRadio] as bool? ?? false,
          scope: arguments?[ParamNames.scope] as String?,
        );
      case MethodNames.disconnectFromSpotify:
        return disconnect();
      case MethodNames.getCrossfadeState:
        final crossfade = await getCrossFadeState();
        return crossfade != null ? jsonEncode(crossfade.toJson()) : null;
      case MethodNames.play:
        await play(
          spotifyUri: arguments?[ParamNames.spotifyUri] as String? ?? '',
          asRadio: arguments?[ParamNames.asRadio] as bool? ?? false,
        );
      case MethodNames.queueTrack:
        await queue(
          spotifyUri: arguments?[ParamNames.spotifyUri] as String? ?? '',
        );
      case MethodNames.setShuffle:
        await setShuffle(
          shuffle: arguments?[ParamNames.shuffle] as bool? ?? false,
        );
      case MethodNames.setRepeatMode:
        final rawMode = arguments?[ParamNames.repeatMode];
        final repeatMode = rawMode is SpotifyRepeatMode
            ? rawMode
            : (rawMode is int
                  ? SpotifyRepeatMode.values[rawMode]
                  : SpotifyRepeatMode.off);
        await setRepeatMode(repeatMode: repeatMode);
      case MethodNames.toggleShuffle:
        await toggleShuffle();
      case MethodNames.toggleRepeat:
        await toggleRepeat();
      case MethodNames.skipToIndex:
        final spotifyUri = arguments?[ParamNames.spotifyUri] as String? ?? '';
        final trackIndex = arguments?[ParamNames.trackIndex] as int? ?? 0;
        await skipToIndex(spotifyUri: spotifyUri, trackIndex: trackIndex);
      case MethodNames.resume:
        await resume();
      case MethodNames.pause:
        await pause();
      case MethodNames.skipNext:
        await skipNext();
      case MethodNames.skipPrevious:
        await skipPrevious();
      case MethodNames.getPlayerState:
        final state = await getPlayerState();
        return state != null ? jsonEncode(state.toJson()) : null;
      case MethodNames.switchToLocalDevice:
        await switchToLocalDevice();
      case MethodNames.addToLibrary:
        await addToLibrary(
          spotifyUri: arguments?[ParamNames.spotifyUri] as String? ?? '',
        );
      case MethodNames.removeFromLibrary:
        await removeFromLibrary(
          spotifyUri: arguments?[ParamNames.spotifyUri] as String? ?? '',
        );
      case MethodNames.getLibraryState:
        final libraryState = await getLibraryState(
          spotifyUri: arguments?[ParamNames.spotifyUri] as String? ?? '',
        );
        return libraryState != null ? jsonEncode(libraryState.toJson()) : null;
      case MethodNames.getImage:
        final rawDimension = arguments?[ParamNames.imageDimension];
        final dimension = rawDimension is ImageDimension
            ? rawDimension
            : (rawDimension is int
                  ? ImageDimension.values.firstWhere(
                      (d) => d.value == rawDimension,
                      orElse: () => ImageDimension.medium,
                    )
                  : ImageDimension.medium);
        return getImage(
          imageUri: ImageUri(arguments?[ParamNames.imageUri] as String? ?? ''),
          dimension: dimension,
        );
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
    await _sdkLoader.ensureSdkLoaded();
    if (_playerManager.currentPlayer != null) {
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

    final success = await _playerManager.connectPlayer(
      playerName: playerName,
    );

    if (!success) {
      _onSpotifyDisconnected(
        errorCode: 'Initialization Error',
        errorDetails: 'Attempt to connect to the Spotify SDK failed',
      );
    }
    return success;
  }

  @override
  Future<String> getAccessToken({
    required String clientId,
    required String redirectUrl,
    String spotifyUri = '',
    bool asRadio = false,
    String? scope,
  }) async {
    await _sdkLoader.ensureSdkLoaded();
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
  Future<String> getSwapToken({
    required String clientId,
    required String redirectUrl,
    String? scope,
    String? tokenSwapUrl,
  }) async {
    return getAccessToken(
      clientId: clientId,
      redirectUrl: redirectUrl,
      scope: scope,
    );
  }

  @override
  Future<bool> isSpotifyInstalled() async {
    return _sdkLoader.isLoaded;
  }

  @override
  Future<bool> disconnect() async {
    await _sdkLoader.ensureSdkLoaded();
    log('Disconnecting from Spotify...');
    _authSession.clearToken();
    if (_playerManager.currentPlayer == null) {
      return true;
    } else {
      _playerManager.disconnect();
      _onSpotifyDisconnected();
      return true;
    }
  }

  @override
  Future<CrossfadeState?> getCrossFadeState() async {
    await _sdkLoader.ensureSdkLoaded();
    return null;
  }

  @override
  Future<PlayerState?> getPlayerState() async {
    await _sdkLoader.ensureSdkLoaded();
    return _playerDispatcher.lastPlayerState;
  }

  @override
  Future<void> play({
    required String spotifyUri,
    bool asRadio = false,
  }) async {
    await _sdkLoader.ensureSdkLoaded();
    await _webApiClient.play(
      uri: spotifyUri,
      deviceId: _playerManager.deviceId,
    );
  }

  @override
  Future<void> queue({required String spotifyUri}) async {
    await _sdkLoader.ensureSdkLoaded();
    await _webApiClient.queue(
      uri: spotifyUri,
      deviceId: _playerManager.deviceId,
    );
  }

  @override
  Future<void> pause() async {
    await _sdkLoader.ensureSdkLoaded();
    await _webApiClient.pause(deviceId: _playerManager.deviceId);
  }

  @override
  Future<void> resume() async {
    await _sdkLoader.ensureSdkLoaded();
    await _webApiClient.resume(deviceId: _playerManager.deviceId);
  }

  @override
  Future<void> seekTo({required int positionedMilliseconds}) async {
    await _sdkLoader.ensureSdkLoaded();
    await _webApiClient.seekTo(
      positionedMilliseconds: positionedMilliseconds,
      deviceId: _playerManager.deviceId,
    );
  }

  @override
  Future<void> seekToRelativePosition({
    required int relativeMilliseconds,
  }) async {
    await _sdkLoader.ensureSdkLoaded();
    final currentState = await getPlayerState();
    final currentPosition = currentState?.playbackPosition ?? 0;
    final targetPosition = (currentPosition + relativeMilliseconds)
        .clamp(
          0,
          double.infinity,
        )
        .toInt();
    await seekTo(positionedMilliseconds: targetPosition);
  }

  @override
  Future<void> setPodcastPlaybackSpeed({
    required PodcastPlaybackSpeed podcastPlaybackSpeed,
  }) async {
    await _sdkLoader.ensureSdkLoaded();
  }

  @override
  Future<void> skipNext() async {
    await _sdkLoader.ensureSdkLoaded();
    await _webApiClient.skipNext(deviceId: _playerManager.deviceId);
  }

  @override
  Future<void> skipPrevious() async {
    await _sdkLoader.ensureSdkLoaded();
    await _webApiClient.skipPrevious(deviceId: _playerManager.deviceId);
  }

  @override
  Future<void> skipToIndex({
    required String spotifyUri,
    required int trackIndex,
  }) async {
    await _sdkLoader.ensureSdkLoaded();
    await _webApiClient.skipToIndex(
      spotifyUri: spotifyUri,
      trackIndex: trackIndex,
      deviceId: _playerManager.deviceId,
    );
  }

  @override
  Future<void> toggleShuffle() async {
    await _sdkLoader.ensureSdkLoaded();
    final currentState = await getPlayerState();
    final currentShuffle = currentState?.playbackOptions.isShuffling ?? false;
    await setShuffle(shuffle: !currentShuffle);
  }

  @override
  Future<void> toggleRepeat() async {
    await _sdkLoader.ensureSdkLoaded();
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
    await _sdkLoader.ensureSdkLoaded();
    await _webApiClient.addToLibrary(spotifyUri: spotifyUri);
  }

  @override
  Future<void> removeFromLibrary({required String spotifyUri}) async {
    await _sdkLoader.ensureSdkLoaded();
    await _webApiClient.removeFromLibrary(spotifyUri: spotifyUri);
  }

  @override
  Future<Capabilities?> getCapabilities({
    required String spotifyUri,
  }) async {
    await _sdkLoader.ensureSdkLoaded();
    return Capabilities(canPlayOnDemand: true);
  }

  @override
  Future<LibraryState?> getLibraryState({
    required String spotifyUri,
  }) async {
    await _sdkLoader.ensureSdkLoaded();
    return _webApiClient.getLibraryState(spotifyUri: spotifyUri);
  }

  @override
  Future<void> switchToLocalDevice() async {
    await _sdkLoader.ensureSdkLoaded();
    return _webApiClient.switchToLocalDevice(
      deviceId: _playerManager.deviceId,
    );
  }

  @override
  Future<Uint8List?> getImage({
    required ImageUri imageUri,
    ImageDimension dimension = ImageDimension.medium,
  }) async {
    await _sdkLoader.ensureSdkLoaded();
    return _webApiClient.getImage(imageUri: imageUri, dimension: dimension);
  }

  @override
  Future<void> setShuffle({required bool shuffle}) async {
    await _sdkLoader.ensureSdkLoaded();
    await _webApiClient.setShuffle(
      shuffleEnabled: shuffle,
      deviceId: _playerManager.deviceId,
    );
  }

  @override
  Future<void> setRepeatMode({required SpotifyRepeatMode repeatMode}) async {
    await _sdkLoader.ensureSdkLoaded();
    await _webApiClient.setRepeatMode(
      repeatMode: repeatMode,
      deviceId: _playerManager.deviceId,
    );
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

  /// Called when the plugin successfully connects to the spotify web sdk.
  void _onSpotifyConnected(String deviceId) {
    _playerManager.handleConnected(deviceId);

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
    if (_playerManager.currentPlayer != null) {
      _playerManager.disconnect();
    }

    if (errorCode != null) {
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
}
