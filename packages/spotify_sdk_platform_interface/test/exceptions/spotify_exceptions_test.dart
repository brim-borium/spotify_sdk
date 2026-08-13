import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spotify_sdk_platform_interface/exceptions/spotify_exceptions.dart';

void main() {
  group('SpotifyException mapping', () {
    test('maps not installed codes to SpotifyNotInstalledException', () {
      final pe = PlatformException(
        code: 'spotifyNotInstalled',
        message: 'Spotify app is not installed',
      );
      final ex = SpotifyException.fromPlatformException(pe);

      expect(ex, isA<SpotifyNotInstalledException>());
      expect(ex.message, equals('Spotify app is not installed'));
      expect(ex.code, equals('spotifyNotInstalled'));
      expect(ex.cause, equals(pe));
    });

    test('maps authentication codes to SpotifyAuthenticationException', () {
      final pe = PlatformException(
        code: 'authenticationTokenError',
        message: 'Failed to retrieve access token',
        details: 'User cancelled',
      );
      final ex = SpotifyException.fromPlatformException(pe);

      expect(ex, isA<SpotifyAuthenticationException>());
      expect(ex.message, equals('Failed to retrieve access token'));
      expect(ex.details, equals('User cancelled'));
      expect(ex.cause, equals(pe));
    });

    test('maps connection codes to SpotifyConnectionException', () {
      final pe = PlatformException(
        code: 'errorConnecting',
        message: 'Could not connect to Spotify remote',
      );
      final ex = SpotifyException.fromPlatformException(pe);

      expect(ex, isA<SpotifyConnectionException>());
      expect(ex.message, equals('Could not connect to Spotify remote'));
      expect(ex.code, equals('errorConnecting'));
    });

    test('maps playback codes to SpotifyPlaybackException', () {
      final pe = PlatformException(
        code: 'playError',
        message: 'Failed to initiate playback',
      );
      final ex = SpotifyException.fromPlatformException(pe);

      expect(ex, isA<SpotifyPlaybackException>());
      expect(ex.message, equals('Failed to initiate playback'));
      expect(ex.code, equals('playError'));
    });

    test('maps library codes to SpotifyLibraryException', () {
      final pe = PlatformException(
        code: 'addToLibraryError',
        message: 'Failed to add to library',
      );
      final ex = SpotifyException.fromPlatformException(pe);

      expect(ex, isA<SpotifyLibraryException>());
      expect(ex.message, equals('Failed to add to library'));
      expect(ex.code, equals('addToLibraryError'));
    });

    test('maps image codes to SpotifyImageException', () {
      final pe = PlatformException(
        code: 'getImageError',
        message: 'Failed to fetch image',
      );
      final ex = SpotifyException.fromPlatformException(pe);

      expect(ex, isA<SpotifyImageException>());
      expect(ex.message, equals('Failed to fetch image'));
      expect(ex.code, equals('getImageError'));
    });

    test('maps MissingPluginException to SpotifyUnimplementedException', () {
      final mpe = MissingPluginException('No implementation found');
      final ex = SpotifyException.fromException(mpe);

      expect(ex, isA<SpotifyUnimplementedException>());
      expect(ex.message, equals('No implementation found'));
      expect(ex.cause, equals(mpe));
    });

    test('maps unknown codes to SpotifyGeneralException', () {
      final pe = PlatformException(
        code: 'UNKNOWN_CODE',
        message: 'An unknown error occurred',
      );
      final ex = SpotifyException.fromPlatformException(pe);

      expect(ex, isA<SpotifyGeneralException>());
      expect(ex.message, equals('An unknown error occurred'));
      expect(ex.code, equals('UNKNOWN_CODE'));
    });

    test('toString formats type, message, code and details', () {
      const ex = SpotifyAuthenticationException(
        'Auth failed',
        code: 'AUTH_01',
        details: 'Bad Request',
      );

      expect(
        ex.toString(),
        equals(
          'SpotifyAuthenticationException: Auth failed '
          '(code: AUTH_01) [details: Bad Request]',
        ),
      );
    });
  });
}
