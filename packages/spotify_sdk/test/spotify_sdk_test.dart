import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

class MockSpotifySdkPlatform extends SpotifySdkPlatform
    with MockPlatformInterfaceMixin {
  final List<String> calls = <String>[];

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
    calls.add('connectToSpotifyRemote');
    return true;
  }

  @override
  Future<String> getAccessToken({
    required String clientId,
    required String redirectUrl,
    String spotifyUri = '',
    bool asRadio = false,
    String? scope,
  }) async {
    calls.add('getAccessToken');
    return 'mock_token';
  }

  @override
  Future<String> getSwapToken({
    required String clientId,
    required String redirectUrl,
    String? scope,
    String? tokenSwapUrl,
  }) async {
    calls.add('getSwapToken');
    return 'mock_swap';
  }

  @override
  Future<bool> isSpotifyInstalled() async {
    calls.add('isSpotifyInstalled');
    return true;
  }

  @override
  Future<bool> disconnect() async {
    calls.add('disconnect');
    return true;
  }

  @override
  Future<CrossfadeState?> getCrossFadeState() async {
    calls.add('getCrossFadeState');
    return CrossfadeState(5000, isEnabled: true);
  }

  @override
  Future<PlayerState?> getPlayerState() async {
    calls.add('getPlayerState');
    return PlayerState(
      null,
      1,
      0,
      PlayerOptions(SpotifyRepeatMode.off, isShuffling: false),
      PlayerRestrictions(
        canSkipNext: true,
        canSkipPrevious: true,
        canSeek: true,
        canToggleShuffle: true,
        canRepeatTrack: true,
        canRepeatContext: true,
      ),
      isPaused: false,
    );
  }

  @override
  Future<void> queue({required String spotifyUri}) async {
    calls.add('queue');
  }

  @override
  Future<void> play({
    required String spotifyUri,
    bool asRadio = false,
  }) async {
    calls.add('play');
  }

  @override
  Future<void> pause() async {
    calls.add('pause');
  }

  @override
  Future<void> resume() async {
    calls.add('resume');
  }

  @override
  Future<void> setPodcastPlaybackSpeed({
    required PodcastPlaybackSpeed podcastPlaybackSpeed,
  }) async {
    calls.add('setPodcastPlaybackSpeed');
  }

  @override
  Future<void> skipNext() async {
    calls.add('skipNext');
  }

  @override
  Future<void> skipPrevious() async {
    calls.add('skipPrevious');
  }

  @override
  Future<void> skipToIndex({
    required String spotifyUri,
    required int trackIndex,
  }) async {
    calls.add('skipToIndex');
  }

  @override
  Future<void> seekTo({required int positionedMilliseconds}) async {
    calls.add('seekTo');
  }

  @override
  Future<void> seekToRelativePosition({
    required int relativeMilliseconds,
  }) async {
    calls.add('seekToRelativePosition');
  }

  @override
  Future<void> switchToLocalDevice() async {
    calls.add('switchToLocalDevice');
  }

  @override
  Future<void> toggleShuffle() async {
    calls.add('toggleShuffle');
  }

  @override
  Future<void> toggleRepeat() async {
    calls.add('toggleRepeat');
  }

  @override
  Future<void> addToLibrary({required String spotifyUri}) async {
    calls.add('addToLibrary');
  }

  @override
  Future<void> removeFromLibrary({required String spotifyUri}) async {
    calls.add('removeFromLibrary');
  }

  @override
  Future<Capabilities?> getCapabilities({
    required String spotifyUri,
  }) async {
    calls.add('getCapabilities');
    return Capabilities(canPlayOnDemand: true);
  }

  @override
  Future<LibraryState?> getLibraryState({
    required String spotifyUri,
  }) async {
    calls.add('getLibraryState');
    return LibraryState('spotify:track:123', isSaved: true, canSave: true);
  }

  @override
  Future<Uint8List?> getImage({
    required ImageUri imageUri,
    ImageDimension dimension = ImageDimension.medium,
  }) async {
    calls.add('getImage');
    return Uint8List.fromList([1, 2, 3]);
  }

  @override
  Future<void> setShuffle({required bool shuffle}) async {
    calls.add('setShuffle');
  }

  @override
  Future<void> setRepeatMode({
    required SpotifyRepeatMode repeatMode,
  }) async {
    calls.add('setRepeatMode');
  }

  @override
  Stream<PlayerContext> subscribePlayerContext() {
    calls.add('subscribePlayerContext');
    return Stream.value(PlayerContext('title', 'subtitle', 'type', 'uri'));
  }

  @override
  Stream<PlayerState> subscribePlayerState() {
    calls.add('subscribePlayerState');
    return const Stream.empty();
  }

  @override
  Stream<ConnectionStatus> subscribeConnectionStatus() {
    calls.add('subscribeConnectionStatus');
    return Stream.value(ConnectionStatus('OK', null, null, connected: true));
  }

  @override
  Stream<Capabilities> subscribeCapabilities() {
    calls.add('subscribeCapabilities');
    return Stream.value(Capabilities(canPlayOnDemand: true));
  }

  @override
  Stream<UserStatus> subscribeUserStatus() {
    calls.add('subscribeUserStatus');
    return Stream.value(UserStatus(0, 'OK', 'User logged in'));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockSpotifySdkPlatform mockPlatform;

  setUp(() {
    mockPlatform = MockSpotifySdkPlatform();
    SpotifySdkPlatform.instance = mockPlatform;
  });

  group('SpotifySdk static methods delegation', () {
    test('connectToSpotifyRemote delegates to platform', () async {
      final result = await SpotifySdk.connectToSpotifyRemote(
        clientId: 'client_123',
        redirectUrl: 'redirect_123',
      );
      expect(result, true);
      expect(mockPlatform.calls, contains('connectToSpotifyRemote'));
    });

    test('getAccessToken delegates to platform', () async {
      final token = await SpotifySdk.getAccessToken(
        clientId: 'client_123',
        redirectUrl: 'redirect_123',
      );
      expect(token, 'mock_token');
      expect(mockPlatform.calls, contains('getAccessToken'));
    });

    test('getSwapToken delegates to platform', () async {
      final swapToken = await SpotifySdk.getSwapToken(
        clientId: 'client_123',
        redirectUrl: 'redirect_123',
      );
      expect(swapToken, 'mock_swap');
      expect(mockPlatform.calls, contains('getSwapToken'));
    });

    test('isSpotifyInstalled delegates to platform', () async {
      final installed = await SpotifySdk.isSpotifyInstalled();
      expect(installed, true);
      expect(mockPlatform.calls, contains('isSpotifyInstalled'));
    });

    test('disconnect delegates to platform', () async {
      final result = await SpotifySdk.disconnect();
      expect(result, true);
      expect(mockPlatform.calls, contains('disconnect'));
    });

    test('getCrossFadeState delegates to platform', () async {
      final crossfade = await SpotifySdk.getCrossFadeState();
      expect(crossfade?.isEnabled, true);
      expect(mockPlatform.calls, contains('getCrossFadeState'));
    });

    test('getPlayerState delegates to platform', () async {
      final playerState = await SpotifySdk.getPlayerState();
      expect(playerState, isNotNull);
      expect(mockPlatform.calls, contains('getPlayerState'));
    });

    test('queue delegates to platform', () async {
      await SpotifySdk.queue(spotifyUri: 'spotify:track:123');
      expect(mockPlatform.calls, contains('queue'));
    });

    test('play delegates to platform', () async {
      await SpotifySdk.play(spotifyUri: 'spotify:track:123');
      expect(mockPlatform.calls, contains('play'));
    });

    test('pause delegates to platform', () async {
      await SpotifySdk.pause();
      expect(mockPlatform.calls, contains('pause'));
    });

    test('resume delegates to platform', () async {
      await SpotifySdk.resume();
      expect(mockPlatform.calls, contains('resume'));
    });

    test('setPodcastPlaybackSpeed delegates to platform', () async {
      await SpotifySdk.setPodcastPlaybackSpeed(
        podcastPlaybackSpeed: PodcastPlaybackSpeed.playbackSpeed_150,
      );
      expect(mockPlatform.calls, contains('setPodcastPlaybackSpeed'));
    });

    test('skipNext delegates to platform', () async {
      await SpotifySdk.skipNext();
      expect(mockPlatform.calls, contains('skipNext'));
    });

    test('skipPrevious delegates to platform', () async {
      await SpotifySdk.skipPrevious();
      expect(mockPlatform.calls, contains('skipPrevious'));
    });

    test('skipToIndex delegates to platform', () async {
      await SpotifySdk.skipToIndex(
        spotifyUri: 'spotify:album:123',
        trackIndex: 2,
      );
      expect(mockPlatform.calls, contains('skipToIndex'));
    });

    test('seekTo delegates to platform', () async {
      await SpotifySdk.seekTo(positionedMilliseconds: 30000);
      expect(mockPlatform.calls, contains('seekTo'));
    });

    test('seekToRelativePosition delegates to platform', () async {
      await SpotifySdk.seekToRelativePosition(relativeMilliseconds: 10000);
      expect(mockPlatform.calls, contains('seekToRelativePosition'));
    });

    test('switchToLocalDevice delegates to platform', () async {
      await SpotifySdk.switchToLocalDevice();
      expect(mockPlatform.calls, contains('switchToLocalDevice'));
    });

    test('toggleShuffle delegates to platform', () async {
      await SpotifySdk.toggleShuffle();
      expect(mockPlatform.calls, contains('toggleShuffle'));
    });

    test('toggleRepeat delegates to platform', () async {
      await SpotifySdk.toggleRepeat();
      expect(mockPlatform.calls, contains('toggleRepeat'));
    });

    test('addToLibrary delegates to platform', () async {
      await SpotifySdk.addToLibrary(spotifyUri: 'spotify:track:123');
      expect(mockPlatform.calls, contains('addToLibrary'));
    });

    test('removeFromLibrary delegates to platform', () async {
      await SpotifySdk.removeFromLibrary(spotifyUri: 'spotify:track:123');
      expect(mockPlatform.calls, contains('removeFromLibrary'));
    });

    test('getCapabilities delegates to platform', () async {
      final capabilities = await SpotifySdk.getCapabilities(
        spotifyUri: 'spotify:track:123',
      );
      expect(capabilities?.canPlayOnDemand, true);
      expect(mockPlatform.calls, contains('getCapabilities'));
    });

    test('getLibraryState delegates to platform', () async {
      final state = await SpotifySdk.getLibraryState(
        spotifyUri: 'spotify:track:123',
      );
      expect(state?.isSaved, true);
      expect(mockPlatform.calls, contains('getLibraryState'));
    });

    test('getImage delegates to platform', () async {
      final image = await SpotifySdk.getImage(
        imageUri: ImageUri('spotify:image:123'),
      );
      expect(image, equals(Uint8List.fromList([1, 2, 3])));
      expect(mockPlatform.calls, contains('getImage'));
    });

    test('setShuffle delegates to platform', () async {
      await SpotifySdk.setShuffle(shuffle: true);
      expect(mockPlatform.calls, contains('setShuffle'));
    });

    test('setRepeatMode delegates to platform', () async {
      await SpotifySdk.setRepeatMode(repeatMode: SpotifyRepeatMode.track);
      expect(mockPlatform.calls, contains('setRepeatMode'));
    });

    test('subscribePlayerContext delegates to platform', () async {
      final stream = SpotifySdk.subscribePlayerContext();
      final context = await stream.first;
      expect(context.title, 'title');
      expect(mockPlatform.calls, contains('subscribePlayerContext'));
    });

    test('subscribePlayerState delegates to platform', () async {
      SpotifySdk.subscribePlayerState();
      expect(mockPlatform.calls, contains('subscribePlayerState'));
    });

    test('subscribeConnectionStatus delegates to platform', () async {
      final stream = SpotifySdk.subscribeConnectionStatus();
      final status = await stream.first;
      expect(status.connected, true);
      expect(mockPlatform.calls, contains('subscribeConnectionStatus'));
    });

    test('subscribeCapabilities delegates to platform', () async {
      final stream = SpotifySdk.subscribeCapabilities();
      final capabilities = await stream.first;
      expect(capabilities.canPlayOnDemand, true);
      expect(mockPlatform.calls, contains('subscribeCapabilities'));
    });

    test('subscribeUserStatus delegates to platform', () async {
      final stream = SpotifySdk.subscribeUserStatus();
      final userStatus = await stream.first;
      expect(userStatus.code, 0);
      expect(mockPlatform.calls, contains('subscribeUserStatus'));
    });
  });
}
