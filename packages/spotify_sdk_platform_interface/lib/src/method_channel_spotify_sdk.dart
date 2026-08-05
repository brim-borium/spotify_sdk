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
  Future<String> getSwapToken({
    required String clientId,
    required String redirectUrl,
    String? scope,
    String? tokenSwapUrl,
  }) async {
    final token = await _gateway.invoke<dynamic>(
      MethodNames.getSwapToken,
      arguments: {
        ParamNames.clientId: clientId,
        ParamNames.redirectUrl: redirectUrl,
        ParamNames.scope: scope,
        ParamNames.tokenSwapUrl: tokenSwapUrl,
      },
    );
    return token.toString();
  }

  @override
  Future<bool> isSpotifyInstalled() async {
    final installed = await _gateway.invoke<bool>(
      MethodNames.isSpotifyInstalled,
    );
    return installed ?? false;
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
      _gateway.invokeJson<CrossfadeState>(
        MethodNames.getCrossfadeState,
        decode: CrossfadeState.fromJson,
      );

  @override
  Future<PlayerState?> getPlayerState() => _gateway.invokeJson<PlayerState>(
    MethodNames.getPlayerState,
    decode: PlayerState.fromJson,
  );

  @override
  Future<void> queue({required String spotifyUri}) => _gateway.invokeVoid(
    MethodNames.queueTrack,
    arguments: {ParamNames.spotifyUri: spotifyUri},
  );

  @override
  Future<void> play({
    required String spotifyUri,
    bool asRadio = false,
  }) => _gateway.invokeVoid(
    MethodNames.play,
    arguments: {
      ParamNames.spotifyUri: spotifyUri,
      ParamNames.asRadio: asRadio,
    },
  );

  @override
  Future<void> pause() => _gateway.invokeVoid(MethodNames.pause);

  @override
  Future<void> resume() => _gateway.invokeVoid(MethodNames.resume);

  @override
  Future<void> setPodcastPlaybackSpeed({
    required PodcastPlaybackSpeed podcastPlaybackSpeed,
  }) => _gateway.invokeVoid(
    MethodNames.setPodcastPlaybackSpeed,
    arguments: {
      ParamNames.podcastPlaybackSpeed: podcastPlaybackSpeed.value,
    },
  );

  @override
  Future<void> skipNext() => _gateway.invokeVoid(MethodNames.skipNext);

  @override
  Future<void> skipPrevious() => _gateway.invokeVoid(MethodNames.skipPrevious);

  @override
  Future<void> skipToIndex({
    required String spotifyUri,
    required int trackIndex,
  }) => _gateway.invokeVoid(
    MethodNames.skipToIndex,
    arguments: {
      ParamNames.spotifyUri: spotifyUri,
      ParamNames.trackIndex: trackIndex,
    },
  );

  @override
  Future<void> seekTo({required int positionedMilliseconds}) =>
      _gateway.invokeVoid(
        MethodNames.seekTo,
        arguments: {
          ParamNames.positionedMilliseconds: positionedMilliseconds,
        },
      );

  @override
  Future<void> seekToRelativePosition({
    required int relativeMilliseconds,
  }) => _gateway.invokeVoid(
    MethodNames.seekToRelativePosition,
    arguments: {
      ParamNames.relativeMilliseconds: relativeMilliseconds,
    },
  );

  @override
  Future<void> switchToLocalDevice() =>
      _gateway.invokeVoid(MethodNames.switchToLocalDevice);

  @override
  Future<void> toggleShuffle() =>
      _gateway.invokeVoid(MethodNames.toggleShuffle);

  @override
  Future<void> toggleRepeat() => _gateway.invokeVoid(MethodNames.toggleRepeat);

  @override
  Future<void> addToLibrary({required String spotifyUri}) =>
      _gateway.invokeVoid(
        MethodNames.addToLibrary,
        arguments: {ParamNames.spotifyUri: spotifyUri},
      );

  @override
  Future<void> removeFromLibrary({required String spotifyUri}) =>
      _gateway.invokeVoid(
        MethodNames.removeFromLibrary,
        arguments: {ParamNames.spotifyUri: spotifyUri},
      );

  @override
  Future<Capabilities?> getCapabilities({
    required String spotifyUri,
  }) => _gateway.invokeJson<Capabilities>(
    MethodNames.getCapabilities,
    decode: Capabilities.fromJson,
  );

  @override
  Future<LibraryState?> getLibraryState({
    required String spotifyUri,
  }) => _gateway.invokeJson<LibraryState>(
    MethodNames.getLibraryState,
    arguments: {ParamNames.spotifyUri: spotifyUri},
    decode: LibraryState.fromJson,
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
  Future<void> setShuffle({required bool shuffle}) => _gateway.invokeVoid(
    MethodNames.setShuffle,
    arguments: {ParamNames.shuffle: shuffle},
  );

  @override
  Future<void> setRepeatMode({
    required SpotifyRepeatMode repeatMode,
  }) => _gateway.invokeVoid(
    MethodNames.setRepeatMode,
    arguments: {ParamNames.repeatMode: repeatMode.index},
  );

  @override
  Stream<PlayerContext> subscribePlayerContext() =>
      _gateway.listenJson<PlayerContext>(
        EventChannels.playerContext,
        MethodNames.subscribePlayerContext,
        PlayerContext.fromJson,
      );

  @override
  Stream<PlayerState> subscribePlayerState() =>
      _gateway.listenJson<PlayerState>(
        EventChannels.playerState,
        MethodNames.subscribePlayerState,
        PlayerState.fromJson,
      );

  @override
  Stream<ConnectionStatus> subscribeConnectionStatus() =>
      _gateway.listenJson<ConnectionStatus>(
        EventChannels.connectionStatus,
        MethodNames.subscribeConnectionStatus,
        ConnectionStatus.fromJson,
      );

  @override
  Stream<Capabilities> subscribeCapabilities() =>
      _gateway.listenJson<Capabilities>(
        EventChannels.capabilities,
        MethodNames.getCapabilities,
        Capabilities.fromJson,
      );

  @override
  Stream<UserStatus> subscribeUserStatus() => _gateway.listenJson<UserStatus>(
    EventChannels.userStatus,
    EventChannels.userStatus,
    UserStatus.fromJson,
  );
}
