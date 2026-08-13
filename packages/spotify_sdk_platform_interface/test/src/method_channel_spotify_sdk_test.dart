import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spotify_sdk_platform_interface/spotify_sdk_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MethodChannelSpotifySdk', () {
    const channel = MethodChannel('spotify_sdk');
    late MethodChannelSpotifySdk platform;
    late List<MethodCall> log;

    setUp(() {
      platform = MethodChannelSpotifySdk();
      log = <MethodCall>[];

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (methodCall) async {
            log.add(methodCall);
            switch (methodCall.method) {
              case 'connectToSpotify':
                return true;
              case 'getAccessToken':
                return 'mock_access_token';
              case 'getSwapToken':
                return 'mock_swap_code';
              case 'isSpotifyInstalled':
                return true;
              case 'disconnectFromSpotify':
                return true;
              case 'getCrossfadeState':
                return jsonEncode({
                  'isEnabled': true,
                  'duration': 5000,
                });
              case 'getPlayerState':
                return jsonEncode({
                  'track': {
                    'name': 'Test Track',
                    'uri': 'spotify:track:123',
                    'duration_ms': 180000,
                    'artist': {
                      'name': 'Test Artist',
                      'uri': 'spotify:artist:123',
                    },
                    'artists': [
                      {'name': 'Test Artist', 'uri': 'spotify:artist:123'},
                    ],
                    'album': {'name': 'Test Album', 'uri': 'spotify:album:123'},
                    'image_id': {'raw': 'spotify:image:123'},
                    'is_episode': false,
                    'is_podcast': false,
                  },
                  'is_paused': false,
                  'playback_speed': 1.0,
                  'playback_position': 1000,
                  'playback_options': {'shuffle': false, 'repeat': 0},
                  'playback_restrictions': {
                    'can_skip_next': true,
                    'can_skip_prev': true,
                    'can_seek': true,
                    'can_toggle_shuffle': true,
                    'can_repeat_track': true,
                    'can_repeat_context': true,
                  },
                });
              case 'getCapabilities':
                return jsonEncode({'can_play_on_demand': true});
              case 'getLibraryState':
                return jsonEncode({
                  'uri': 'spotify:track:123',
                  'saved': true,
                  'can_save': true,
                });
              case 'getImage':
                return Uint8List.fromList([1, 2, 3]);
              default:
                return null;
            }
          });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('connectToSpotifyRemote sends expected parameters', () async {
      final result = await platform.connectToSpotifyRemote(
        clientId: 'test_client_id',
        redirectUrl: 'test_redirect_url',
      );

      expect(result, true);
      expect(log, hasLength(1));
      expect(log.first.method, 'connectToSpotify');
      final args = log.first.arguments as Map<dynamic, dynamic>;
      expect(args['clientId'], 'test_client_id');
      expect(args['redirectUrl'], 'test_redirect_url');
    });

    test('getAccessToken returns access token string', () async {
      final token = await platform.getAccessToken(
        clientId: 'test_client_id',
        redirectUrl: 'test_redirect_url',
      );

      expect(token, 'mock_access_token');
      expect(log.first.method, 'getAccessToken');
    });

    test('getSwapToken returns swap token string', () async {
      final token = await platform.getSwapToken(
        clientId: 'test_client_id',
        redirectUrl: 'test_redirect_url',
      );

      expect(token, 'mock_swap_code');
      expect(log.first.method, 'getSwapToken');
    });

    test('isSpotifyInstalled returns boolean', () async {
      final result = await platform.isSpotifyInstalled();

      expect(result, true);
      expect(log.first.method, 'isSpotifyInstalled');
    });

    test('disconnect returns confirmation boolean', () async {
      final result = await platform.disconnect();

      expect(result, true);
      expect(log.first.method, 'disconnectFromSpotify');
    });

    test('getCrossFadeState deserializes CrossfadeState', () async {
      final crossfade = await platform.getCrossFadeState();

      expect(crossfade, isNotNull);
      expect(crossfade!.isEnabled, true);
      expect(crossfade.duration, 5000);
      expect(log.first.method, 'getCrossfadeState');
    });

    test('getPlayerState deserializes PlayerState correctly', () async {
      final playerState = await platform.getPlayerState();

      expect(playerState, isNotNull);
      expect(playerState!.track?.name, 'Test Track');
      expect(playerState.isPaused, false);
      expect(log.first.method, 'getPlayerState');
    });

    test('queue sends expected parameters', () async {
      await platform.queue(spotifyUri: 'spotify:track:123');

      expect(log, hasLength(1));
      expect(log.first.method, 'queueTrack');
      final args = log.first.arguments as Map<dynamic, dynamic>;
      expect(args['spotifyUri'], 'spotify:track:123');
    });

    test('play sends expected parameters', () async {
      await platform.play(spotifyUri: 'spotify:track:123', asRadio: true);

      expect(log, hasLength(1));
      expect(log.first.method, 'play');
      final args = log.first.arguments as Map<dynamic, dynamic>;
      expect(args['spotifyUri'], 'spotify:track:123');
      expect(args['asRadio'], true);
    });

    test('pause sends method call', () async {
      await platform.pause();

      expect(log, hasLength(1));
      expect(log.first.method, 'pause');
    });

    test('resume sends method call', () async {
      await platform.resume();

      expect(log, hasLength(1));
      expect(log.first.method, 'resume');
    });

    test('setPodcastPlaybackSpeed sends expected speed value', () async {
      await platform.setPodcastPlaybackSpeed(
        podcastPlaybackSpeed: PodcastPlaybackSpeed.playbackSpeed_150,
      );

      expect(log, hasLength(1));
      expect(log.first.method, 'setPodcastPlaybackSpeed');
      final args = log.first.arguments as Map<dynamic, dynamic>;
      expect(
        args['podcastPlaybackSpeed'],
        PodcastPlaybackSpeed.playbackSpeed_150.value,
      );
    });

    test('skipNext sends method call', () async {
      await platform.skipNext();

      expect(log, hasLength(1));
      expect(log.first.method, 'skipNext');
    });

    test('skipPrevious sends method call', () async {
      await platform.skipPrevious();

      expect(log, hasLength(1));
      expect(log.first.method, 'skipPrevious');
    });

    test('skipToIndex sends expected parameters', () async {
      await platform.skipToIndex(
        spotifyUri: 'spotify:album:123',
        trackIndex: 3,
      );

      expect(log, hasLength(1));
      expect(log.first.method, 'skipToIndex');
      final args = log.first.arguments as Map<dynamic, dynamic>;
      expect(args['spotifyUri'], 'spotify:album:123');
      expect(args['trackIndex'], 3);
    });

    test('seekTo sends expected position', () async {
      await platform.seekTo(positionedMilliseconds: 45000);

      expect(log, hasLength(1));
      expect(log.first.method, 'seekTo');
      final args = log.first.arguments as Map<dynamic, dynamic>;
      expect(args['positionedMilliseconds'], 45000);
    });

    test('seekToRelativePosition sends expected relative ms', () async {
      await platform.seekToRelativePosition(relativeMilliseconds: 15000);

      expect(log, hasLength(1));
      expect(log.first.method, 'seekToRelativePosition');
      final args = log.first.arguments as Map<dynamic, dynamic>;
      expect(args['relativeMilliseconds'], 15000);
    });

    test('switchToLocalDevice sends method call', () async {
      await platform.switchToLocalDevice();

      expect(log, hasLength(1));
      expect(log.first.method, 'switchToLocalDevice');
    });

    test('toggleShuffle sends method call', () async {
      await platform.toggleShuffle();

      expect(log, hasLength(1));
      expect(log.first.method, 'toggleShuffle');
    });

    test('toggleRepeat sends method call', () async {
      await platform.toggleRepeat();

      expect(log, hasLength(1));
      expect(log.first.method, 'toggleRepeat');
    });

    test('addToLibrary sends expected uri', () async {
      await platform.addToLibrary(spotifyUri: 'spotify:track:123');

      expect(log, hasLength(1));
      expect(log.first.method, 'addToLibrary');
      final args = log.first.arguments as Map<dynamic, dynamic>;
      expect(args['spotifyUri'], 'spotify:track:123');
    });

    test('removeFromLibrary sends expected uri', () async {
      await platform.removeFromLibrary(spotifyUri: 'spotify:track:123');

      expect(log, hasLength(1));
      expect(log.first.method, 'removeFromLibrary');
      final args = log.first.arguments as Map<dynamic, dynamic>;
      expect(args['spotifyUri'], 'spotify:track:123');
    });

    test('getCapabilities deserializes Capabilities', () async {
      final capabilities = await platform.getCapabilities(
        spotifyUri: 'spotify:track:123',
      );

      expect(capabilities, isNotNull);
      expect(capabilities!.canPlayOnDemand, true);
      expect(log.first.method, 'getCapabilities');
    });

    test('getLibraryState deserializes LibraryState', () async {
      final state = await platform.getLibraryState(
        spotifyUri: 'spotify:track:123',
      );

      expect(state, isNotNull);
      expect(state!.isSaved, true);
      expect(state.canSave, true);
      expect(log.first.method, 'getLibraryState');
    });

    test('getImage returns Uint8List bytes', () async {
      final bytes = await platform.getImage(
        imageUri: ImageUri('spotify:image:123'),
        dimension: ImageDimension.large,
      );

      expect(bytes, equals(Uint8List.fromList([1, 2, 3])));
      expect(log.first.method, 'getImage');
      final args = log.first.arguments as Map<dynamic, dynamic>;
      expect(args['imageUri'], 'spotify:image:123');
      expect(args['imageDimension'], ImageDimension.large.value);
    });

    test('setShuffle sends expected boolean', () async {
      await platform.setShuffle(shuffle: true);

      expect(log, hasLength(1));
      expect(log.first.method, 'setShuffle');
      final args = log.first.arguments as Map<dynamic, dynamic>;
      expect(args['shuffle'], true);
    });

    test('setRepeatMode sends expected mode index', () async {
      await platform.setRepeatMode(repeatMode: SpotifyRepeatMode.track);

      expect(log, hasLength(1));
      expect(log.first.method, 'setRepeatMode');
      final args = log.first.arguments as Map<dynamic, dynamic>;
      expect(args['repeatMode'], SpotifyRepeatMode.track.index);
    });

    test('rethrows PlatformException when method channel fails', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (methodCall) async {
            throw PlatformException(
              code: 'TEST_ERROR',
              message: 'Failed operation',
            );
          });

      expect(
        () => platform.play(spotifyUri: 'spotify:track:123'),
        throwsA(isA<PlatformException>()),
      );
    });

    test('event stream subscriptions return streams without error', () {
      expect(platform.subscribePlayerContext(), isA<Stream<PlayerContext>>());
      expect(platform.subscribePlayerState(), isA<Stream<PlayerState>>());
      expect(
        platform.subscribeConnectionStatus(),
        isA<Stream<ConnectionStatus>>(),
      );
      expect(platform.subscribeCapabilities(), isA<Stream<Capabilities>>());
      expect(platform.subscribeUserStatus(), isA<Stream<UserStatus>>());
    });
  });
}
