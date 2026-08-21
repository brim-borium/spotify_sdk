import 'dart:convert';

import 'package:web/web.dart' as web;

/// Spotify token data object.
class SpotifyToken {
  /// Creates a [SpotifyToken].
  SpotifyToken({
    required this.clientId,
    required this.accessToken,
    required this.refreshToken,
    required this.expiry,
  });

  /// Converts JSON map to [SpotifyToken].
  factory SpotifyToken.fromJson(Map<String, dynamic> json) => SpotifyToken(
    clientId: json['client_id'] as String,
    accessToken: json['access_token'] as String,
    refreshToken: json['refresh_token'] as String,
    expiry: json['expiry'] as int,
  );

  /// Currently used client id.
  final String clientId;

  /// Access token data.
  final String accessToken;

  /// Refresh token data.
  final String refreshToken;

  /// Token expiry time in unix seconds.
  final int expiry;

  /// Converts [SpotifyToken] to JSON map.
  Map<String, dynamic> toJson() => {
    'client_id': clientId,
    'access_token': accessToken,
    'refresh_token': refreshToken,
    'expiry': expiry,
  };
}

/// Interface for persisting Spotify authentication tokens.
abstract class AuthSessionStorage {
  /// Saves the active [token].
  void saveToken(SpotifyToken token);

  /// Loads the active token if available.
  SpotifyToken? loadToken();

  /// Clears stored token.
  void clearToken();
}

/// Production implementation of [AuthSessionStorage]
/// backed by `web.window.localStorage`.
class BrowserAuthStorage implements AuthSessionStorage {
  static const String _storageKey = 'spotify_sdk_token';

  @override
  void saveToken(SpotifyToken token) {
    web.window.localStorage.setItem(
      _storageKey,
      jsonEncode(token.toJson()),
    );
  }

  @override
  SpotifyToken? loadToken() {
    final rawJson = web.window.localStorage.getItem(_storageKey);
    if (rawJson == null || rawJson.isEmpty) {
      return null;
    }
    try {
      final map = jsonDecode(rawJson) as Map<String, dynamic>;
      return SpotifyToken.fromJson(map);
    } on Exception catch (_) {
      return null;
    }
  }

  @override
  void clearToken() {
    web.window.localStorage.removeItem(_storageKey);
  }
}

/// In-memory implementation of [AuthSessionStorage] for testing.
class InMemoryAuthStorage implements AuthSessionStorage {
  SpotifyToken? _token;

  @override
  void saveToken(SpotifyToken token) {
    _token = token;
  }

  @override
  SpotifyToken? loadToken() => _token;

  @override
  void clearToken() {
    _token = null;
  }
}
