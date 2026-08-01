import 'dart:convert';
import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:spotify_sdk_platform_interface/spotify_sdk_platform_interface.dart';
import 'package:spotify_sdk_web/src/auth/spotify_auth_session.dart';

/// Deep module managing all Spotify Web REST API endpoints.
///
/// Encapsulates authentication headers, URI parsing, endpoint URLs,
/// JSON deserialization, and HTTP exception handling using standard
/// [http.Client].
class SpotifyWebApiClient {
  /// Creates a [SpotifyWebApiClient].
  SpotifyWebApiClient({
    SpotifyAuthSession? authSession,
    http.Client? httpClient,
  }) : _authSession = authSession ?? SpotifyAuthSession(),
       _httpClient = httpClient ?? http.Client();

  final SpotifyAuthSession _authSession;
  final http.Client _httpClient;

  static const String _playerBaseUrl = 'https://api.spotify.com/v1/me/player';

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _authSession.getValidToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Plays a given [uri] (track or context) on player device [deviceId].
  Future<void> play({
    required String? uri,
    required String? deviceId,
  }) async {
    if (deviceId == null || deviceId.isEmpty) {
      throw PlatformException(
        message: 'Spotify player not connected!',
        code: 'Playback Error',
      );
    }
    try {
      final headers = await _getAuthHeaders();
      final body = <String, dynamic>{};
      if (uri != null && uri.isNotEmpty) {
        if (uri.contains(':track:')) {
          body['uris'] = [uri];
        } else {
          body['context_uri'] = uri;
        }
      }

      final url = Uri.parse('$_playerBaseUrl/play?device_id=$deviceId');
      final response = await _httpClient.put(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode >= 400) {
        throw PlatformException(
          message: 'Play failed: ${response.body}',
          code: 'Playback Error',
        );
      }
    } on Exception catch (e) {
      if (e is PlatformException) rethrow;
      throw PlatformException(
        message: 'Play failed: $e',
        code: 'Playback Error',
      );
    }
  }

  /// Adds a given track [uri] to the playback queue on player
  /// device [deviceId].
  Future<void> queue({
    required String? uri,
    required String? deviceId,
  }) async {
    if (deviceId == null || deviceId.isEmpty) {
      throw PlatformException(
        message: 'Spotify player not connected!',
        code: 'Playback Error',
      );
    }
    try {
      final headers = await _getAuthHeaders();
      final url = Uri.parse(
        '$_playerBaseUrl/queue?uri=${Uri.encodeComponent(uri ?? '')}&device_id=$deviceId',
      );
      final response = await _httpClient.post(url, headers: headers);

      if (response.statusCode >= 400) {
        throw PlatformException(
          message: 'Queue failed: ${response.body}',
          code: 'Playback Error',
        );
      }
    } on Exception catch (e) {
      if (e is PlatformException) rethrow;
      throw PlatformException(
        message: 'Queue failed: $e',
        code: 'Playback Error',
      );
    }
  }

  /// Sets whether shuffle should be enabled for player device [deviceId].
  Future<void> setShuffle({
    required bool? shuffleEnabled,
    required String? deviceId,
  }) async {
    if (deviceId == null || deviceId.isEmpty) {
      throw PlatformException(
        message: 'Spotify player not connected!',
        code: 'Set Shuffle Error',
      );
    }
    try {
      final headers = await _getAuthHeaders();
      final state = (shuffleEnabled ?? true).toString();
      final url = Uri.parse(
        '$_playerBaseUrl/shuffle?state=$state&device_id=$deviceId',
      );
      final response = await _httpClient.put(url, headers: headers);

      if (response.statusCode >= 400) {
        throw PlatformException(
          message: 'Set shuffle failed: ${response.body}',
          code: 'Set Shuffle Error',
        );
      }
    } on Exception catch (e) {
      if (e is PlatformException) rethrow;
      throw PlatformException(
        message: 'Set shuffle failed: $e',
        code: 'Set Shuffle Error',
      );
    }
  }

  /// Sets the repeat mode for player device [deviceId].
  Future<void> setRepeatMode({
    required SpotifyRepeatMode? repeatMode,
    required String? deviceId,
  }) async {
    if (deviceId == null || deviceId.isEmpty) {
      throw PlatformException(
        message: 'Spotify player not connected!',
        code: 'Set Repeat Mode Error',
      );
    }

    late String state;
    switch (repeatMode) {
      case SpotifyRepeatMode.context:
        state = 'context';
      case SpotifyRepeatMode.track:
        state = 'track';
      case SpotifyRepeatMode.off:
      case null:
        state = 'off';
    }

    try {
      final headers = await _getAuthHeaders();
      final url = Uri.parse(
        '$_playerBaseUrl/repeat?state=$state&device_id=$deviceId',
      );
      final response = await _httpClient.put(url, headers: headers);

      if (response.statusCode >= 400) {
        throw PlatformException(
          message: 'Set repeat mode failed: ${response.body}',
          code: 'Set Repeat Mode Error',
        );
      }
    } on Exception catch (e) {
      if (e is PlatformException) rethrow;
      throw PlatformException(
        message: 'Set repeat mode failed: $e',
        code: 'Set Repeat Mode Error',
      );
    }
  }

  /// Skips to a track at specified [trackIndex] in album/playlist or track list.
  Future<void> skipToIndex({
    required String spotifyUri,
    required int trackIndex,
    required String? deviceId,
  }) async {
    if (deviceId == null || deviceId.isEmpty) {
      throw PlatformException(
        message: 'Spotify player not connected!',
        code: 'Playback Error',
      );
    }
    try {
      final headers = await _getAuthHeaders();
      final body = <String, dynamic>{
        if (spotifyUri.contains(':track:'))
          'uris': [spotifyUri]
        else
          'context_uri': spotifyUri,
        'offset': {'position': trackIndex},
      };

      final url = Uri.parse('$_playerBaseUrl/play?device_id=$deviceId');
      final response = await _httpClient.put(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode >= 400) {
        throw PlatformException(
          message: 'Skip to index failed: ${response.body}',
          code: 'Playback Error',
        );
      }
    } on Exception catch (e) {
      if (e is PlatformException) rethrow;
      throw PlatformException(
        message: 'Skip to index failed: $e',
        code: 'Playback Error',
      );
    }
  }

  /// Switches playback to local web player device [deviceId].
  Future<void> switchToLocalDevice({required String? deviceId}) async {
    if (deviceId == null || deviceId.isEmpty) {
      throw PlatformException(
        message: 'Spotify player not connected!',
        code: 'Connect Error',
      );
    }
    try {
      final headers = await _getAuthHeaders();
      final url = Uri.parse(_playerBaseUrl);
      final response = await _httpClient.put(
        url,
        headers: headers,
        body: jsonEncode({
          'device_ids': [deviceId],
        }),
      );

      if (response.statusCode >= 400) {
        throw PlatformException(
          message: 'Switch to local device failed: ${response.body}',
          code: 'Connect Error',
        );
      }
    } on Exception catch (e) {
      if (e is PlatformException) rethrow;
      throw PlatformException(
        message: 'Switch to local device failed: $e',
        code: 'Connect Error',
      );
    }
  }

  /// Adds the given [spotifyUri] to the user's library.
  Future<void> addToLibrary({required String spotifyUri}) async {
    final id = _extractId(spotifyUri);
    if (id == null) return;
    try {
      final headers = await _getAuthHeaders();
      final url = Uri.parse('https://api.spotify.com/v1/me/tracks?ids=$id');
      await _httpClient.put(url, headers: headers);
    } on Object catch (e) {
      log('addToLibrary error: $e');
    }
  }

  /// Removes the given [spotifyUri] from the user's library.
  Future<void> removeFromLibrary({required String spotifyUri}) async {
    final id = _extractId(spotifyUri);
    if (id == null) return;
    try {
      final headers = await _getAuthHeaders();
      final url = Uri.parse('https://api.spotify.com/v1/me/tracks?ids=$id');
      await _httpClient.delete(url, headers: headers);
    } on Object catch (e) {
      log('removeFromLibrary error: $e');
    }
  }

  /// Gets the [LibraryState] for the given [spotifyUri].
  Future<LibraryState?> getLibraryState({required String spotifyUri}) async {
    final id = _extractId(spotifyUri);
    if (id == null) {
      return LibraryState(spotifyUri, isSaved: false, canSave: true);
    }
    try {
      final headers = await _getAuthHeaders();
      final url = Uri.parse(
        'https://api.spotify.com/v1/me/tracks/contains?ids=$id',
      );
      final response = await _httpClient.get(url, headers: headers);
      if (response.statusCode == 200) {
        final dynamic parsed = jsonDecode(response.body);
        final isSaved =
            parsed is List && parsed.isNotEmpty && parsed[0] == true;
        return LibraryState(spotifyUri, isSaved: isSaved, canSave: true);
      }
      return LibraryState(spotifyUri, isSaved: false, canSave: true);
    } on Object catch (e) {
      log('getLibraryState error: $e');
      return LibraryState(spotifyUri, isSaved: false, canSave: true);
    }
  }

  /// Gets raw image byte buffer for the specified [imageUri].
  Future<Uint8List?> getImage({
    required ImageUri imageUri,
    ImageDimension dimension = ImageDimension.medium,
  }) async {
    final rawUri = imageUri.raw;
    if (rawUri.isEmpty) {
      return null;
    }

    final String imageUrl;
    if (rawUri.startsWith('http://') || rawUri.startsWith('https://')) {
      imageUrl = rawUri;
    } else if (rawUri.startsWith('spotify:image:')) {
      final imageHash = rawUri.split(':').last;
      imageUrl = 'https://i.scdn.co/image/$imageHash';
    } else {
      imageUrl = 'https://i.scdn.co/image/$rawUri';
    }

    try {
      final response = await _httpClient.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
      return null;
    } on Object catch (e) {
      log('Failed to fetch image: $e');
      return null;
    }
  }

  String? _extractId(String uri) {
    if (uri.contains(':')) {
      final parts = uri.split(':');
      return parts.isNotEmpty ? parts.last : null;
    }
    return uri.isNotEmpty ? uri : null;
  }
}
