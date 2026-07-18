import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:spotify_sdk_platform_interface/platform_channels.dart';
import 'package:spotify_sdk_platform_interface/spotify_sdk_platform_interface.dart';

/// An implementation of [SpotifySdkPlatform] that uses method channels.
class MethodChannelSpotifySdk extends SpotifySdkPlatform {
  // method channel
  static const MethodChannel _channel = MethodChannel(
    MethodChannels.spotifySdk,
  );

  //player event channels
  static const EventChannel _playerContextChannel = EventChannel(
    EventChannels.playerContext,
  );
  static const EventChannel _playerStateChannel = EventChannel(
    EventChannels.playerState,
  );

  // user event channels
  static const EventChannel _userStatusChannel = EventChannel(
    EventChannels.userStatus,
  );
  static const EventChannel _capabilitiesChannel = EventChannel(
    EventChannels.capabilities,
  );

  // connection status channel
  static const EventChannel _connectionStatusChannel = EventChannel(
    EventChannels.connectionStatus,
  );

  //logging
  static final Logger _logger = Logger(
    printer: PrettyPrinter(),
  );

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
    try {
      final result = await _channel.invokeMethod<bool>(
        MethodNames.connectToSpotify,
        {
          ParamNames.clientId: clientId,
          ParamNames.redirectUrl: redirectUrl,
          ParamNames.playerName: playerName,
          ParamNames.accessToken: accessToken,
          ParamNames.scope: scope,
          ParamNames.spotifyUri: spotifyUri,
          ParamNames.asRadio: asRadio,
        },
      );
      return result ?? false;
    } on Exception catch (e) {
      _logException(MethodNames.connectToSpotify, e);
      rethrow;
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
    try {
      final authorization = await _channel.invokeMethod(
        MethodNames.getAccessToken,
        {
          ParamNames.clientId: clientId,
          ParamNames.redirectUrl: redirectUrl,
          ParamNames.scope: scope,
          ParamNames.spotifyUri: spotifyUri,
          ParamNames.asRadio: asRadio,
        },
      );
      return authorization.toString();
    } on Exception catch (e) {
      _logException(MethodNames.getAccessToken, e);
      rethrow;
    }
  }

  @override
  Future<bool> disconnect() async {
    try {
      final result = await _channel.invokeMethod<bool>(
        MethodNames.disconnectFromSpotify,
      );
      return result ?? false;
    } on Exception catch (e) {
      _logException(MethodNames.disconnectFromSpotify, e);
      rethrow;
    }
  }

  @override
  Future<CrossfadeState?> getCrossFadeState() async {
    try {
      final crossfadeStateJson = await _channel.invokeMethod<String>(
        MethodNames.getCrossfadeState,
      );
      if (crossfadeStateJson == null) {
        return null;
      }
      final crossfadeStateMap =
          jsonDecode(crossfadeStateJson) as Map<String, dynamic>;
      final crossfadeState = CrossfadeState.fromJson(crossfadeStateMap);
      return crossfadeState;
    } on Exception catch (e) {
      _logException(MethodNames.getCrossfadeState, e);
      rethrow;
    }
  }

  @override
  Future<PlayerState?> getPlayerState() async {
    try {
      final playerStateJson = await _channel.invokeMethod<String>(
        MethodNames.getPlayerState,
      );
      if (playerStateJson == null) {
        return null;
      }
      final playerStateMap =
          jsonDecode(playerStateJson) as Map<String, dynamic>;
      final playerState = PlayerState.fromJson(playerStateMap);
      return playerState;
    } on Exception catch (e) {
      _logException(MethodNames.getPlayerState, e);
      rethrow;
    }
  }

  @override
  Future<void> queue({required String spotifyUri}) async {
    try {
      await _channel.invokeMethod(MethodNames.queueTrack, {
        ParamNames.spotifyUri: spotifyUri,
      });
    } on Exception catch (e) {
      _logException(MethodNames.queueTrack, e);
      rethrow;
    }
  }

  @override
  Future<void> play({
    required String spotifyUri,
    bool asRadio = false,
  }) async {
    try {
      await _channel.invokeMethod(MethodNames.play, {
        ParamNames.spotifyUri: spotifyUri,
        ParamNames.asRadio: asRadio,
      });
    } on Exception catch (e) {
      _logException(MethodNames.play, e);
      rethrow;
    }
  }

  @override
  Future<void> pause() async {
    try {
      await _channel.invokeMethod(MethodNames.pause);
    } on Exception catch (e) {
      _logException(MethodNames.pause, e);
      rethrow;
    }
  }

  @override
  Future<void> resume() async {
    try {
      await _channel.invokeMethod(MethodNames.resume);
    } on Exception catch (e) {
      _logException(MethodNames.resume, e);
      rethrow;
    }
  }

  @override
  Future<void> setPodcastPlaybackSpeed({
    required PodcastPlaybackSpeed podcastPlaybackSpeed,
  }) async {
    try {
      await _channel.invokeMethod(MethodNames.setPodcastPlaybackSpeed, {
        ParamNames.podcastPlaybackSpeed: podcastPlaybackSpeed.value,
      });
    } on Exception catch (e) {
      _logException(MethodNames.resume, e);
      rethrow;
    }
  }

  @override
  Future<void> skipNext() async {
    try {
      await _channel.invokeMethod(MethodNames.skipNext);
    } on Exception catch (e) {
      _logException(MethodNames.skipNext, e);
      rethrow;
    }
  }

  @override
  Future<void> skipPrevious() async {
    try {
      await _channel.invokeMethod(MethodNames.skipPrevious);
    } on Exception catch (e) {
      _logException(MethodNames.skipPrevious, e);
      rethrow;
    }
  }

  @override
  Future<void> skipToIndex({
    required String spotifyUri,
    required int trackIndex,
  }) async {
    try {
      await _channel.invokeMethod(MethodNames.skipToIndex, {
        ParamNames.spotifyUri: spotifyUri,
        ParamNames.trackIndex: trackIndex,
      });
    } on Exception catch (e) {
      _logException(MethodNames.skipToIndex, e);
      rethrow;
    }
  }

  @override
  Future<void> seekTo({required int positionedMilliseconds}) async {
    try {
      await _channel.invokeMethod(MethodNames.seekTo, {
        ParamNames.positionedMilliseconds: positionedMilliseconds,
      });
    } on Exception catch (e) {
      _logException(MethodNames.seekTo, e);
      rethrow;
    }
  }

  @override
  Future<void> seekToRelativePosition({
    required int relativeMilliseconds,
  }) async {
    try {
      await _channel.invokeMethod(MethodNames.seekToRelativePosition, {
        ParamNames.relativeMilliseconds: relativeMilliseconds,
      });
    } on Exception catch (e) {
      _logException(MethodNames.seekToRelativePosition, e);
      rethrow;
    }
  }

  @override
  Future<void> switchToLocalDevice() async {
    try {
      await _channel.invokeMethod(MethodNames.switchToLocalDevice);
    } on Exception catch (e) {
      _logException(MethodNames.switchToLocalDevice, e);
      rethrow;
    }
  }

  @override
  Future<void> toggleShuffle() async {
    try {
      await _channel.invokeMethod(MethodNames.toggleShuffle);
    } on Exception catch (e) {
      _logException(MethodNames.toggleShuffle, e);
      rethrow;
    }
  }

  @override
  Future<void> toggleRepeat() async {
    try {
      await _channel.invokeMethod(MethodNames.toggleRepeat);
    } on Exception catch (e) {
      _logException(MethodNames.toggleRepeat, e);
      rethrow;
    }
  }

  @override
  Future<void> addToLibrary({required String spotifyUri}) async {
    try {
      await _channel.invokeMethod(MethodNames.addToLibrary, {
        ParamNames.spotifyUri: spotifyUri,
      });
    } on Exception catch (e) {
      _logException(MethodNames.addToLibrary, e);
      rethrow;
    }
  }

  @override
  Future<void> removeFromLibrary({required String spotifyUri}) async {
    try {
      await _channel.invokeMethod(MethodNames.removeFromLibrary, {
        ParamNames.spotifyUri: spotifyUri,
      });
    } on Exception catch (e) {
      _logException(MethodNames.removeFromLibrary, e);
      rethrow;
    }
  }

  @override
  Future<Capabilities?> getCapabilities({
    required String spotifyUri,
  }) async {
    try {
      final capabilitiesJson = await _channel.invokeMethod<String>(
        MethodNames.getCapabilities,
      );

      if (capabilitiesJson != null && capabilitiesJson.isNotEmpty) {
        final capabilitiesMap =
            jsonDecode(capabilitiesJson) as Map<String, dynamic>;
        return Capabilities.fromJson(capabilitiesMap);
      }

      return null;
    } on Exception catch (e) {
      _logException(MethodNames.getCapabilities, e);
      rethrow;
    }
  }

  @override
  Future<LibraryState?> getLibraryState({
    required String spotifyUri,
  }) async {
    try {
      final libraryStateJson = await _channel.invokeMethod<String>(
        MethodNames.getLibraryState,
        {ParamNames.spotifyUri: spotifyUri},
      );
      if (libraryStateJson == null) {
        return null;
      }
      final libraryStateMap =
          jsonDecode(libraryStateJson) as Map<String, dynamic>;
      return LibraryState.fromJson(libraryStateMap);
    } on Exception catch (e) {
      _logException(MethodNames.getLibraryState, e);
      rethrow;
    }
  }

  @override
  Future<Uint8List?> getImage({
    required ImageUri imageUri,
    ImageDimension dimension = ImageDimension.medium,
  }) async {
    try {
      return _channel.invokeMethod(MethodNames.getImage, {
        ParamNames.imageUri: imageUri.raw,
        ParamNames.imageDimension: dimension.value,
      });
    } on Exception catch (e) {
      _logException(MethodNames.getImage, e);
      rethrow;
    }
  }

  @override
  Future<void> setShuffle({required bool shuffle}) async {
    try {
      return _channel.invokeMethod(MethodNames.setShuffle, {
        ParamNames.shuffle: shuffle,
      });
    } on Exception catch (e) {
      _logException(MethodNames.setShuffle, e);
      rethrow;
    }
  }

  @override
  Future<void> setRepeatMode({
    required SpotifyRepeatMode repeatMode,
  }) async {
    try {
      return _channel.invokeMethod(MethodNames.setRepeatMode, {
        ParamNames.repeatMode: repeatMode.index,
      });
    } on Exception catch (e) {
      _logException(MethodNames.setRepeatMode, e);
      rethrow;
    }
  }

  @override
  Stream<PlayerContext> subscribePlayerContext() {
    try {
      final playerContextSubscription = _playerContextChannel
          .receiveBroadcastStream();
      return playerContextSubscription.asyncMap((playerContextJson) {
        final playerContextMap =
            jsonDecode(playerContextJson.toString()) as Map<String, dynamic>;
        return PlayerContext.fromJson(playerContextMap);
      });
    } on Exception catch (e) {
      _logException(MethodNames.subscribePlayerContext, e);
      rethrow;
    }
  }

  @override
  Stream<PlayerState> subscribePlayerState() {
    try {
      final playerStateSubscription = _playerStateChannel
          .receiveBroadcastStream();
      return playerStateSubscription.asyncMap((playerStateJson) {
        final playerStateMap =
            jsonDecode(playerStateJson.toString()) as Map<String, dynamic>;
        return PlayerState.fromJson(playerStateMap);
      });
    } on Exception catch (e) {
      _logException(MethodNames.subscribePlayerState, e);
      rethrow;
    }
  }

  @override
  Stream<ConnectionStatus> subscribeConnectionStatus() {
    try {
      final connectionStatusSubscription = _connectionStatusChannel
          .receiveBroadcastStream();
      return connectionStatusSubscription.asyncMap((connectionStatusJson) {
        final connectionStatusMap =
            jsonDecode(connectionStatusJson.toString()) as Map<String, dynamic>;
        return ConnectionStatus.fromJson(connectionStatusMap);
      });
    } on Exception catch (e) {
      _logException(MethodNames.subscribeConnectionStatus, e);
      rethrow;
    }
  }

  @override
  Stream<Capabilities> subscribeCapabilities() {
    try {
      final capabilitiesSubscription = _capabilitiesChannel
          .receiveBroadcastStream();
      return capabilitiesSubscription.asyncMap((capabilitiesJson) {
        final capabilitiesMap =
            jsonDecode(capabilitiesJson.toString()) as Map<String, dynamic>;
        return Capabilities.fromJson(capabilitiesMap);
      });
    } on Exception catch (e) {
      _logException(MethodNames.subscribePlayerContext, e);
      rethrow;
    }
  }

  @override
  Stream<UserStatus> subscribeUserStatus() {
    try {
      final userStatusSubscription = _userStatusChannel
          .receiveBroadcastStream();
      return userStatusSubscription.asyncMap((userStatusJson) {
        final userStatusMap =
            jsonDecode(userStatusJson.toString()) as Map<String, dynamic>;
        return UserStatus.fromJson(userStatusMap);
      });
    } on Exception catch (e) {
      _logException(MethodNames.subscribePlayerContext, e);
      rethrow;
    }
  }

  void _logException(String method, Exception e) {
    if (e is PlatformException) {
      var message = e.message ?? '';
      message += e.details != null ? '\n${e.details}' : '';
      _logger.e('$method failed with: $message');
    } else if (e is MissingPluginException) {
      _logger.e('$method not implemented');
    } else {
      _logger.e('$method throws unhandled exception: $e');
    }
  }
}
