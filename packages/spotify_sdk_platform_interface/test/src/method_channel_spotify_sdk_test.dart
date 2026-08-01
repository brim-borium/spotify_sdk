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
              case 'disconnectFromSpotify':
                return true;
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

    test('disconnect returns confirmation boolean', () async {
      final result = await platform.disconnect();

      expect(result, true);
      expect(log.first.method, 'disconnectFromSpotify');
    });

    test('getPlayerState deserializes PlayerState correctly', () async {
      final playerState = await platform.getPlayerState();

      expect(playerState, isNotNull);
      expect(playerState!.track?.name, 'Test Track');
      expect(playerState.isPaused, false);
      expect(log.first.method, 'getPlayerState');
    });
  });
}
