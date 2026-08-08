import 'dart:async';
import 'dart:developer';
import 'dart:js_interop';

import 'package:spotify_sdk_web/src/auth/spotify_auth_session.dart';
import 'package:spotify_sdk_web/src/interop/web_playback_sdk.dart';
import 'package:spotify_sdk_web/src/player/web_player_dispatcher.dart';

/// Manages Spotify Web Playback SDK Player instance lifecycle and device ID.
class WebPlayerManager {
  /// Constructor
  WebPlayerManager({
    required this.authSession,
    required this.playerDispatcher,
  });

  /// Authentication session manager.
  final SpotifyAuthSession authSession;

  /// Player event dispatcher.
  final WebPlayerDispatcher playerDispatcher;

  Player? _currentPlayer;
  Completer<String>? _deviceIdCompleter;
  String? _connectedDeviceId;

  /// Active Player instance.
  Player? get currentPlayer => _currentPlayer;

  /// Device ID of active player.
  String? get deviceId => _currentPlayer?.deviceID ?? _connectedDeviceId;

  /// Connects to Spotify Web Playback SDK and resolves device ID via Completer.
  Future<bool> connectPlayer({
    String playerName = 'Spotify SDK',
    Duration timeout = const Duration(seconds: 10),
  }) async {
    if (_currentPlayer != null && _currentPlayer!.deviceID != null) {
      return true;
    }

    _deviceIdCompleter = Completer<String>();

    _currentPlayer = Player(
      PlayerOptions(
        name: playerName,
        getOAuthToken: ((JSFunction callback, JSAny? t) {
          unawaited(
            authSession.getValidToken().then((value) {
              callback.callAsFunction(null, value.toJS);
            }),
          );
        }).toJS,
      ),
    );

    playerDispatcher.registerPlayerEvents(_currentPlayer!);

    final result = await _currentPlayer!.connect().toDart;
    if (result != null && (result as JSBoolean).toDart) {
      try {
        final resolvedDeviceId = await _deviceIdCompleter!.future.timeout(
          timeout,
        );
        _currentPlayer!.deviceID = resolvedDeviceId;
        _connectedDeviceId = resolvedDeviceId;
        return true;
      } on Exception catch (e) {
        log('Timed out waiting for Web Player device ID resolution: $e');
        return false;
      }
    } else {
      return false;
    }
  }

  /// Resolves device ID completer when WebPlayerDispatcher fires connected.
  void handleConnected(String deviceId) {
    _connectedDeviceId = deviceId;
    if (_currentPlayer != null) {
      _currentPlayer!.deviceID = deviceId;
    }
    if (_deviceIdCompleter != null && !_deviceIdCompleter!.isCompleted) {
      _deviceIdCompleter!.complete(deviceId);
    }
  }

  /// Disconnects active player and cleans up event listeners.
  void disconnect() {
    _connectedDeviceId = null;
    if (_currentPlayer != null) {
      playerDispatcher.unregisterPlayerEvents(_currentPlayer!);
      _currentPlayer!.disconnect();
      _currentPlayer = null;
    }
    if (_deviceIdCompleter != null && !_deviceIdCompleter!.isCompleted) {
      _deviceIdCompleter!.completeError(StateError('Player disconnected'));
    }
    _deviceIdCompleter = null;
  }
}
