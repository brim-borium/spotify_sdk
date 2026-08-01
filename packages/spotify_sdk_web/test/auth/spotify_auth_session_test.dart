import 'package:flutter_test/flutter_test.dart';
import 'package:spotify_sdk_web/src/auth/auth_session_storage.dart';
import 'package:spotify_sdk_web/src/auth/oauth_window_adapter.dart';
import 'package:spotify_sdk_web/src/auth/spotify_auth_session.dart';

void main() {
  group('SpotifyAuthSession', () {
    late InMemoryAuthStorage storage;
    late FakeWindowAdapter windowAdapter;
    late SpotifyAuthSession session;

    setUp(() {
      storage = InMemoryAuthStorage();
      windowAdapter = FakeWindowAdapter(authCodeToReturn: 'fake_code_123');
      session = SpotifyAuthSession(
        storage: storage,
        windowAdapter: windowAdapter,
      );
    });

    test('PKCE code verifier and challenge helpers generate valid strings', () {
      final verifier = SpotifyAuthSession.createCodeVerifier();
      final challenge = SpotifyAuthSession.createCodeChallenge(verifier);
      final state = SpotifyAuthSession.createAuthState();

      expect(verifier, isNotEmpty);
      expect(challenge, isNotEmpty);
      expect(state, isNotEmpty);
    });

    test('getValidToken returns active token if not expired', () async {
      final futureExpiry =
          (DateTime.now().millisecondsSinceEpoch / 1000).round() + 3600;
      storage.saveToken(
        SpotifyToken(
          clientId: 'client_123',
          accessToken: 'valid_token_abc',
          refreshToken: 'refresh_xyz',
          expiry: futureExpiry,
        ),
      );

      final token = await session.getValidToken();
      expect(token, 'valid_token_abc');
    });

    test('clearToken removes token from storage', () {
      storage.saveToken(
        SpotifyToken(
          clientId: 'client_123',
          accessToken: 'valid_token_abc',
          refreshToken: 'refresh_xyz',
          expiry: 9999999999,
        ),
      );

      session.clearToken();
      expect(storage.loadToken(), isNull);
    });
  });
}
