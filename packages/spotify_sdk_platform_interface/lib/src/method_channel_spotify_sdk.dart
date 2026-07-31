import 'dart:async';

import 'package:flutter/services.dart';
import 'package:spotify_sdk_platform_interface/platform_channels.dart';
import 'package:spotify_sdk_platform_interface/spotify_sdk_platform_interface.dart';
import 'package:spotify_sdk_platform_interface/src/platform_channel_gateway.dart';

/// An implementation of [SpotifySdkPlatform] that uses method channels.
class MethodChannelSpotifySdk extends SpotifySdkPlatform {
  /// Creates a [MethodChannelSpotifySdk], optionally taking a custom [gateway].
  MethodChannelSpotifySdk({PlatformChannelGateway? gateway})
    : _gateway = gateway ?? PlatformChannelGateway();

  final PlatformChannelGateway _gateway;

  // player event channels
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
    final result = await _gateway.invoke<bool>(
      MethodNames.connectToSpotify,
      arguments: {
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
  }

  @override
  Future<String> getAccessToken({
    required String clientId,
    required String redirectUrl,
    String spotifyUri = '',
    bool asRadio = false,
    String? scope,
  }) async {
    final authorization = await _gateway.invoke<dynamic>(
      MethodNames.getAccessToken,
      arguments: {
        ParamNames.clientId: clientId,
        ParamNames.redirectUrl: redirectUrl,
        ParamNames.scope: scope,
        ParamNames.spotifyUri: spotifyUri,
        ParamNames.asRadio: asRadio,
      },
    );
    return authorization.toString();
  }

  @override
  Future<bool> disconnect() async {
    final result = await _gateway.invoke<bool>(
      MethodNames.disconnectFromSpotify,
    );
    return result ?? false;
  }

  @override
  Future<CrossfadeState?> getCrossFadeState() =>
      _gateway.invoke<CrossfadeState>(
        MethodNames.getCrossfadeState,
        decode: (json) => CrossfadeState.fromJson(json as Map<String, dynamic>),
      );

  @override
  Future<PlayerState?> getPlayerState() => _gateway.invoke<PlayerState>(
    MethodNames.getPlayerState,
    decode: (json) => PlayerState.fromJson(json as Map<String, dynamic>),
  );

  @override
  Future<void> queue({required String spotifyUri}) => _gateway.invoke<void>(
    MethodNames.queueTrack,
    arguments: {ParamNames.spotifyUri: spotifyUri},
  );

  @override
  Future<void> play({
    required String spotifyUri,
    bool asRadio = false,
  }) => _gateway.invoke<void>(
    MethodNames.play,
    arguments: {
      ParamNames.spotifyUri: spotifyUri,
      ParamNames.asRadio: asRadio,
    },
  );

  @override
  Future<void> pause() => _gateway.invoke<void>(MethodNames.pause);

  @override
  Future<void> resume() => _gateway.invoke<void>(MethodNames.resume);

  @override
  Future<void> setPodcastPlaybackSpeed({
    required PodcastPlaybackSpeed podcastPlaybackSpeed,
  }) => _gateway.invoke<void>(
    MethodNames.setPodcastPlaybackSpeed,
    arguments: {
      ParamNames.podcastPlaybackSpeed: podcastPlaybackSpeed.value,
    },
  );

  @override
  Future<void> skipNext() => _gateway.invoke<void>(MethodNames.skipNext);

  @override
  Future<void> skipPrevious() =>
      _gateway.invoke<void>(MethodNames.skipPrevious);

  @override
  Future<void> skipToIndex({
    required String spotifyUri,
    required int trackIndex,
  }) => _gateway.invoke<void>(
    MethodNames.skipToIndex,
    arguments: {
      ParamNames.spotifyUri: spotifyUri,
      ParamNames.trackIndex: trackIndex,
    },
  );

  @override
  Future<void> seekTo({required int positionedMilliseconds}) =>
      _gateway.invoke<void>(
        MethodNames.seekTo,
        arguments: {
          ParamNames.positionedMilliseconds: positionedMilliseconds,
        },
      );

  @override
  Future<void> seekToRelativePosition({
    required int relativeMilliseconds,
  }) => _gateway.invoke<void>(
    MethodNames.seekToRelativePosition,
    arguments: {
      ParamNames.relativeMilliseconds: relativeMilliseconds,
    },
  );

  @override
  Future<void> switchToLocalDevice() =>
      _gateway.invoke<void>(MethodNames.switchToLocalDevice);

  @override
  Future<void> toggleShuffle() =>
      _gateway.invoke<void>(MethodNames.toggleShuffle);

  @override
  Future<void> toggleRepeat() =>
      _gateway.invoke<void>(MethodNames.toggleRepeat);

  @override
  Future<void> addToLibrary({required String spotifyUri}) =>
      _gateway.invoke<void>(
        MethodNames.addToLibrary,
        arguments: {ParamNames.spotifyUri: spotifyUri},
      );

  @override
  Future<void> removeFromLibrary({required String spotifyUri}) =>
      _gateway.invoke<void>(
        MethodNames.removeFromLibrary,
        arguments: {ParamNames.spotifyUri: spotifyUri},
      );

  @override
  Future<Capabilities?> getCapabilities({
    required String spotifyUri,
  }) => _gateway.invoke<Capabilities>(
    MethodNames.getCapabilities,
    decode: (json) => Capabilities.fromJson(json as Map<String, dynamic>),
  );

  @override
  Future<LibraryState?> getLibraryState({
    required String spotifyUri,
  }) => _gateway.invoke<LibraryState>(
    MethodNames.getLibraryState,
    arguments: {ParamNames.spotifyUri: spotifyUri},
    decode: (json) => LibraryState.fromJson(json as Map<String, dynamic>),
  );

  @override
  Future<Uint8List?> getImage({
    required ImageUri imageUri,
    ImageDimension dimension = ImageDimension.medium,
  }) => _gateway.invoke<Uint8List>(
    MethodNames.getImage,
    arguments: {
      ParamNames.imageUri: imageUri.raw,
      ParamNames.imageDimension: dimension.value,
    },
  );

  @override
  Future<void> setShuffle({required bool shuffle}) => _gateway.invoke<void>(
    MethodNames.setShuffle,
    arguments: {ParamNames.shuffle: shuffle},
  );

  @override
  Future<void> setRepeatMode({
    required SpotifyRepeatMode repeatMode,
  }) => _gateway.invoke<void>(
    MethodNames.setRepeatMode,
    arguments: {ParamNames.repeatMode: repeatMode.index},
  );

  @override
  Stream<PlayerContext> subscribePlayerContext() =>
      _gateway.listen<PlayerContext>(
        _playerContextChannel,
        MethodNames.subscribePlayerContext,
        PlayerContext.fromJson,
      );

  @override
  Stream<PlayerState> subscribePlayerState() => _gateway.listen<PlayerState>(
    _playerStateChannel,
    MethodNames.subscribePlayerState,
    PlayerState.fromJson,
  );

  @override
  Stream<ConnectionStatus> subscribeConnectionStatus() =>
      _gateway.listen<ConnectionStatus>(
        _connectionStatusChannel,
        MethodNames.subscribeConnectionStatus,
        ConnectionStatus.fromJson,
      );

  @override
  Stream<Capabilities> subscribeCapabilities() => _gateway.listen<Capabilities>(
    _capabilitiesChannel,
    MethodNames.getCapabilities,
    Capabilities.fromJson,
  );

  @override
  Stream<UserStatus> subscribeUserStatus() => _gateway.listen<UserStatus>(
    _userStatusChannel,
    EventChannels.userStatus,
    UserStatus.fromJson,
  );
}
