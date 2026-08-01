import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:spotify_sdk_platform_interface/spotify_sdk_platform_interface.dart';
import 'package:spotify_sdk_web/spotify_sdk_web.dart';

void main() {
  group('SpotifyWebApiClient', () {
    late InMemoryAuthStorage storage;
    late SpotifyAuthSession session;
    late http.Client httpClient;
    late SpotifyWebApiClient client;
    late List<http.BaseRequest> requests;

    setUp(() {
      requests = [];
      storage = InMemoryAuthStorage();
      final nowSec = (DateTime.now().millisecondsSinceEpoch / 1000).round();
      storage.saveToken(
        SpotifyToken(
          clientId: 'client_123',
          accessToken: 'test_token_abc',
          refreshToken: 'refresh_xyz',
          expiry: nowSec + 3600,
        ),
      );
      session = SpotifyAuthSession(storage: storage);

      httpClient = MockClient((request) async {
        requests.add(request);
        if (request.url.path.contains('/tracks/contains')) {
          return http.Response(jsonEncode([true]), 200);
        } else if (request.url.path.contains('image')) {
          return http.Response.bytes([1, 2, 3, 4], 200);
        }
        return http.Response('', 200);
      });

      client = SpotifyWebApiClient(
        authSession: session,
        httpClient: httpClient,
      );
    });

    test('getLibraryState fetches saved status & attaches token', () async {
      final state = await client.getLibraryState(
        spotifyUri: 'spotify:track:track123',
      );

      expect(state, isNotNull);
      expect(state!.isSaved, isTrue);
      expect(requests.length, 1);
      expect(requests.first.headers['Authorization'], 'Bearer test_token_abc');
      expect(requests.first.url.queryParameters['ids'], 'track123');
    });

    test('addToLibrary sends PUT request with extracted track ID', () async {
      await client.addToLibrary(spotifyUri: 'spotify:track:track456');

      expect(requests.length, 1);
      expect(requests.first.method, 'PUT');
      expect(
        requests.first.url.toString(),
        'https://api.spotify.com/v1/me/tracks?ids=track456',
      );
    });

    test('removeFromLibrary sends DELETE with track ID', () async {
      await client.removeFromLibrary(spotifyUri: 'spotify:track:track789');

      expect(requests.length, 1);
      expect(requests.first.method, 'DELETE');
      expect(
        requests.first.url.toString(),
        'https://api.spotify.com/v1/me/tracks?ids=track789',
      );
    });

    test('skipToIndex throws PlatformException when deviceId null', () async {
      expect(
        () => client.skipToIndex(
          spotifyUri: 'spotify:album:123',
          trackIndex: 2,
          deviceId: null,
        ),
        throwsA(isA<PlatformException>()),
      );
    });

    test('switchToLocalDevice throws PlatformException when empty', () async {
      expect(
        () => client.switchToLocalDevice(deviceId: ''),
        throwsA(isA<PlatformException>()),
      );
    });

    test('getImage fetches byte data for spotify image URI', () async {
      final bytes = await client.getImage(
        imageUri: ImageUri('spotify:image:abc123hash'),
      );

      expect(bytes, isNotNull);
      expect(bytes, Uint8List.fromList([1, 2, 3, 4]));
      expect(
        requests.first.url.toString(),
        'https://i.scdn.co/image/abc123hash',
      );
    });
  });
}
