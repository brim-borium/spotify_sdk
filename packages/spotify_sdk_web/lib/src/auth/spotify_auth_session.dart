import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:spotify_sdk_web/src/auth/auth_session_storage.dart';
import 'package:spotify_sdk_web/src/auth/oauth_window_adapter.dart';
import 'package:synchronized/synchronized.dart' as synchronized;

/// A deep module encapsulating OAuth PKCE authorization, token storage,
/// and synchronized token refresh locks.
class SpotifyAuthSession {
  /// Creates a [SpotifyAuthSession].
  SpotifyAuthSession({
    AuthSessionStorage? storage,
    OAuthWindowAdapter? windowAdapter,
    Dio? authDio,
  }) : _storage = storage ?? BrowserAuthStorage(),
       _windowAdapter = windowAdapter ?? BrowserWindowAdapter(),
       _authDio = authDio ?? Dio();

  final AuthSessionStorage _storage;
  final OAuthWindowAdapter _windowAdapter;
  final Dio _authDio;
  final synchronized.Lock _tokenLock = synchronized.Lock(reentrant: true);

  /// Default scopes required for Web SDK to work.
  static const String defaultScopes =
      'streaming user-read-email user-read-private';

  /// Service URL for token swap.
  static String? tokenSwapURL;

  /// Service URL for token refresh.
  static String? tokenRefreshURL;

  SpotifyToken? _currentToken;

  /// Current token if available.
  SpotifyToken? get currentToken => _currentToken ??= _storage.loadToken();

  /// Retrieves a valid access token, performing background refresh if expired.
  Future<String> getValidToken() async {
    return _tokenLock.synchronized<String>(() async {
      final token = currentToken;
      if (token == null || token.accessToken.isEmpty) {
        throw PlatformException(
          message: 'Spotify user not logged in!',
          code: 'Authentication Error',
        );
      }

      final nowSeconds = (DateTime.now().millisecondsSinceEpoch / 1000).round();
      if (token.expiry > nowSeconds) {
        return token.accessToken;
      }

      final refreshed = await refreshSpotifyToken(
        token.clientId,
        token.refreshToken,
      );

      final updatedToken = SpotifyToken(
        clientId: token.clientId,
        accessToken: refreshed['access_token'] as String,
        refreshToken:
            (refreshed['refresh_token'] as String?) ?? token.refreshToken,
        expiry: nowSeconds + (refreshed['expires_in'] as int),
      );

      _currentToken = updatedToken;
      _storage.saveToken(updatedToken);
      return updatedToken.accessToken;
    });
  }

  /// Authorizes user with Spotify PKCE flow and saves token.
  Future<String> authorize({
    required String clientId,
    required String redirectUrl,
    required String? scopes,
  }) async {
    final codeVerifier = createCodeVerifier();
    final codeChallenge = createCodeChallenge(codeVerifier);
    final state = createAuthState();

    final params = <String, String>{
      'client_id': clientId,
      'redirect_uri': redirectUrl,
      'response_type': 'code',
      'state': state,
      'scope': scopes ?? defaultScopes,
    };

    if (tokenSwapURL == null) {
      params['code_challenge_method'] = 'S256';
      params['code_challenge'] = codeChallenge;
    }

    final authorizationUri = Uri.https(
      'accounts.spotify.com',
      'authorize',
      params,
    );

    final authCode = await _windowAdapter.requestAuthCode(
      authorizationUri: authorizationUri,
      expectedState: state,
    );

    final tokenResponse = await exchangeAuthCode(
      clientId: clientId,
      redirectUrl: redirectUrl,
      authCode: authCode,
      codeVerifier: codeVerifier,
    );

    final nowSeconds = (DateTime.now().millisecondsSinceEpoch / 1000).round();
    final newToken = SpotifyToken(
      clientId: clientId,
      accessToken: tokenResponse['access_token'] as String,
      refreshToken: tokenResponse['refresh_token'] as String,
      expiry: nowSeconds + (tokenResponse['expires_in'] as int),
    );

    _currentToken = newToken;
    _storage.saveToken(newToken);
    return newToken.accessToken;
  }

  /// Clears active token.
  void clearToken() {
    _currentToken = null;
    _storage.clearToken();
  }

  /// Exchanges auth code for access token via REST call.
  Future<Map<String, dynamic>> exchangeAuthCode({
    required String clientId,
    required String redirectUrl,
    required String authCode,
    required String codeVerifier,
  }) async {
    final RequestOptions req;
    if (tokenSwapURL == null) {
      req = RequestOptions(
        path: 'https://accounts.spotify.com/api/token',
        method: 'POST',
        data: {
          'client_id': clientId,
          'grant_type': 'authorization_code',
          'code': authCode,
          'redirect_uri': redirectUrl,
          'code_verifier': codeVerifier,
        },
        contentType: Headers.formUrlEncodedContentType,
      );
    } else {
      req = RequestOptions(
        path: tokenSwapURL!,
        method: 'POST',
        data: {
          'code': authCode,
          'redirect_uri': redirectUrl,
        },
        contentType: Headers.formUrlEncodedContentType,
      );
    }

    try {
      final response = await _authDio.fetch<Map<String, dynamic>>(req);
      if (response.data == null) {
        throw PlatformException(
          message: 'Failed to exchange authorization code for token',
          code: 'Authentication Error',
        );
      }
      return response.data!;
    } catch (e) {
      throw PlatformException(
        message: 'Token exchange failed: $e',
        code: 'Authentication Error',
      );
    }
  }

  /// Refreshes access token via REST call.
  Future<Map<String, dynamic>> refreshSpotifyToken(
    String clientId,
    String refreshToken,
  ) async {
    final RequestOptions req;
    if (tokenRefreshURL == null) {
      req = RequestOptions(
        path: 'https://accounts.spotify.com/api/token',
        method: 'POST',
        data: {
          'client_id': clientId,
          'grant_type': 'refresh_token',
          'refresh_token': refreshToken,
        },
        contentType: Headers.formUrlEncodedContentType,
      );
    } else {
      req = RequestOptions(
        path: tokenRefreshURL!,
        method: 'POST',
        data: {'refresh_token': refreshToken},
        contentType: Headers.formUrlEncodedContentType,
      );
    }

    try {
      final response = await _authDio.fetch<Map<String, dynamic>>(req);
      if (response.data == null) {
        throw PlatformException(
          message: 'Failed to refresh token',
          code: 'Authentication Error',
        );
      }
      return response.data!;
    } catch (e) {
      throw PlatformException(
        message: 'Token refresh failed: $e',
        code: 'Authentication Error',
      );
    }
  }

  /// Creates PKCE code verifier.
  static String createCodeVerifier() {
    final rand = math.Random.secure();
    final codeUnits = List.generate(128, (index) {
      return rand.nextInt(33) + 89;
    });
    return base64Url.encode(codeUnits).replaceAll('=', '');
  }

  /// Creates PKCE code challenge.
  static String createCodeChallenge(String codeVerifier) {
    final bytes = utf8.encode(codeVerifier);
    final digest = sha256.convert(bytes);
    return base64Url.encode(digest.bytes).replaceAll('=', '');
  }

  /// Creates PKCE auth state.
  static String createAuthState() {
    final rand = math.Random.secure();
    final codeUnits = List.generate(16, (index) {
      return rand.nextInt(33) + 89;
    });
    return base64Url.encode(codeUnits).replaceAll('=', '');
  }
}
