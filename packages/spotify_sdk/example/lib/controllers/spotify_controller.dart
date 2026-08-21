import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:spotify_sdk_example/models/status_log_entry.dart';

/// State Controller that wraps [SpotifySdk] calls and stream providers.
class SpotifyController extends ChangeNotifier {
  /// Creates a [SpotifyController].
  SpotifyController() {
    _initConnectionLogging();
    _initPlayerStateListening();
  }

  final Logger _logger = Logger(printer: PrettyPrinter());

  // State Properties
  bool _isLoading = false;
  bool _isConnected = false;
  CrossfadeState? _crossfadeState;
  LibraryState? _lastLibraryState;
  Capabilities? _userCapabilities;
  String? _accessToken;
  ConnectionStatus? _lastConnectionStatus;
  PlayerState? _lastPlayerState;
  final List<StatusLogEntry> _logs = [];

  StreamSubscription<ConnectionStatus>? _connectionSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;

  // Cached Stream Singletons
  /// Stream of connection status updates.
  late final Stream<ConnectionStatus> connectionStatusStream =
      SpotifySdk.subscribeConnectionStatus().asBroadcastStream();

  /// Stream of player state updates.
  late final Stream<PlayerState> playerStateStream =
      SpotifySdk.subscribePlayerState().asBroadcastStream();

  /// Stream of player context updates.
  late final Stream<PlayerContext> playerContextStream =
      SpotifySdk.subscribePlayerContext().asBroadcastStream();

  /// Stream of user status updates.
  late final Stream<UserStatus> userStatusStream =
      SpotifySdk.subscribeUserStatus().asBroadcastStream();

  /// Stream of capabilities updates.
  late final Stream<Capabilities> capabilitiesStream =
      SpotifySdk.subscribeCapabilities().asBroadcastStream();

  // Getters
  /// Whether an async operation is currently executing.
  bool get isLoading => _isLoading;

  /// Whether Spotify Remote is connected.
  bool get isConnected => _isConnected;

  /// Cached access token.
  String? get accessToken => _accessToken;

  /// Current crossfade state.
  CrossfadeState? get crossfadeState => _crossfadeState;

  /// Last queried library state.
  LibraryState? get lastLibraryState => _lastLibraryState;

  /// User capabilities state.
  Capabilities? get userCapabilities => _userCapabilities;

  /// Last received connection status.
  ConnectionStatus? get lastConnectionStatus => _lastConnectionStatus;

  /// Last received player state.
  PlayerState? get lastPlayerState => _lastPlayerState;

  /// Unmodifiable view of active log entries.
  List<StatusLogEntry> get logs => List.unmodifiable(_logs);

  void _initConnectionLogging() {
    try {
      _connectionSubscription = connectionStatusStream.listen(
        (status) {
          _lastConnectionStatus = status;
          _isConnected = status.connected;

          final details = <String>[];
          if (status.message != null && status.message!.isNotEmpty) {
            details.add(status.message!);
          }
          if (status.errorCode != null && status.errorCode!.isNotEmpty) {
            details.add('[Code: ${status.errorCode}]');
          }
          if (status.errorDetails != null) {
            details.add('${status.errorDetails}');
          }

          log(
            'Connection status: '
            '${status.connected ? "Connected" : "Disconnected"}',
            detail: details.isNotEmpty ? details.join(' ') : null,
            severity: status.connected
                ? LogSeverity.success
                : (status.hasError() ? LogSeverity.error : LogSeverity.warning),
          );
          notifyListeners();
        },
        onError: (Object error) {
          log(
            'Connection status stream error: $error',
            severity: LogSeverity.error,
          );
        },
      );
    } on Object catch (e) {
      log(
        'Could not initialize connection stream: $e',
        severity: LogSeverity.error,
      );
    }
  }

  void _initPlayerStateListening() {
    try {
      _playerStateSubscription = playerStateStream.listen(
        (state) {
          _lastPlayerState = state;
          notifyListeners();
        },
        onError: (Object error) {
          log(
            'Player state stream error: $error',
            severity: LogSeverity.error,
          );
        },
      );
    } on Object catch (e) {
      log(
        'Could not initialize player state stream: $e',
        severity: LogSeverity.error,
      );
    }
  }

  /// Appends a log entry to the in-memory history.
  void log(
    String message, {
    String? detail,
    LogSeverity severity = LogSeverity.info,
  }) {
    final entry = StatusLogEntry(
      message: message,
      detail: detail,
      severity: severity,
    );
    _logs.insert(0, entry);
    if (_logs.length > 100) {
      _logs.removeLast();
    }
    _logger.i('$message ${detail ?? ""}');
    notifyListeners();
  }

  /// Clears log history.
  void clearLogs() {
    _logs.clear();
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<T?> _runSdkCall<T>(
    String actionName,
    Future<T?> Function() call, {
    void Function(T? result)? onSuccess,
  }) async {
    try {
      final result = await call();
      onSuccess?.call(result);
      return result;
    } on PlatformException catch (e) {
      log(
        'Error $actionName',
        detail: '${e.code}: ${e.message}',
        severity: LogSeverity.error,
      );
      return null;
    } on MissingPluginException {
      log('$actionName not implemented', severity: LogSeverity.error);
      return null;
    } on Exception catch (e) {
      log(
        'Unexpected error $actionName',
        detail: '$e',
        severity: LogSeverity.error,
      );
      return null;
    }
  }

  /// Connects to Spotify Remote using `.env` credentials.
  Future<bool> connectToSpotifyRemote() async {
    _setLoading(true);
    try {
      final clientId = dotenv.env['CLIENT_ID'] ?? '';
      final redirectUrl = dotenv.env['REDIRECT_URL'] ?? '';

      final success = await SpotifySdk.connectToSpotifyRemote(
        clientId: clientId,
        redirectUrl: redirectUrl,
      );

      _isConnected = success;
      log(
        success ? 'Connected to Spotify Remote' : 'Connection attempt failed',
        severity: success ? LogSeverity.success : LogSeverity.error,
      );
      if (success) {
        unawaited(getPlayerState());
      }
      notifyListeners();
      return success;
    } on PlatformException catch (e) {
      log(
        'PlatformException during connect',
        detail: '${e.code}: ${e.message}',
        severity: LogSeverity.error,
      );
      return false;
    } on MissingPluginException {
      log(
        'MissingPluginException: Spotify SDK not implemented on platform',
        severity: LogSeverity.error,
      );
      return false;
    } on Exception catch (e) {
      log(
        'Unexpected error connecting to Spotify',
        detail: '$e',
        severity: LogSeverity.error,
      );
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Retrieves current PlayerState on demand.
  Future<PlayerState?> getPlayerState() async {
    return _runSdkCall(
      'getting player state',
      SpotifySdk.getPlayerState,
      onSuccess: (state) {
        if (state != null) {
          _lastPlayerState = state;
          notifyListeners();
        }
      },
    );
  }

  /// Retrieves Spotify OAuth access token.
  Future<String?> getAccessToken() async {
    _setLoading(true);
    try {
      final clientId = dotenv.env['CLIENT_ID'] ?? '';
      final redirectUrl = dotenv.env['REDIRECT_URL'] ?? '';

      const scope =
          'app-remote-control, '
          'user-modify-playback-state, '
          'playlist-read-private, '
          'playlist-modify-public,user-read-currently-playing';

      final token = await SpotifySdk.getAccessToken(
        clientId: clientId,
        redirectUrl: redirectUrl,
        scope: scope,
      );

      _accessToken = token;
      log(
        'Successfully acquired Spotify Access Token',
        severity: LogSeverity.success,
      );
      notifyListeners();
      return token;
    } on PlatformException catch (e) {
      log(
        'PlatformException getting access token',
        detail: '${e.code}: ${e.message}',
        severity: LogSeverity.error,
      );
      return null;
    } on MissingPluginException {
      log(
        'MissingPluginException: Access token not implemented on platform',
        severity: LogSeverity.error,
      );
      return null;
    } on Exception catch (e) {
      log(
        'Error getting access token',
        detail: '$e',
        severity: LogSeverity.error,
      );
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Checks whether Spotify app is installed on the device.
  Future<bool> checkIsSpotifyInstalled() async {
    _setLoading(true);
    try {
      final installed = await SpotifySdk.isSpotifyInstalled();
      log(
        installed ? 'Spotify app is installed' : 'Spotify app is NOT installed',
        severity: installed ? LogSeverity.success : LogSeverity.info,
      );
      return installed;
    } on Exception catch (e) {
      log(
        'Error checking if Spotify is installed',
        detail: '$e',
        severity: LogSeverity.error,
      );
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Retrieves Spotify OAuth swap token for custom token-swap backend
  /// architectures.
  Future<String?> getSwapToken() async {
    _setLoading(true);
    try {
      final clientId = dotenv.env['CLIENT_ID'] ?? '';
      final redirectUrl = dotenv.env['REDIRECT_URL'] ?? '';

      const scope =
          'app-remote-control, '
          'user-modify-playback-state, '
          'playlist-read-private, '
          'playlist-modify-public,user-read-currently-playing';

      final token = await SpotifySdk.getSwapToken(
        clientId: clientId,
        redirectUrl: redirectUrl,
        scope: scope,
      );

      log(
        'Acquired Swap Token / Authorization Code',
        detail: token,
        severity: LogSeverity.success,
      );
      return token;
    } on PlatformException catch (e) {
      log(
        'PlatformException getting swap token',
        detail: '${e.code}: ${e.message}',
        severity: LogSeverity.error,
      );
      return null;
    } on Exception catch (e) {
      log(
        'Error getting swap token',
        detail: '$e',
        severity: LogSeverity.error,
      );
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Disconnects from Spotify Remote.
  Future<bool> disconnect() async {
    _setLoading(true);
    try {
      final success = await SpotifySdk.disconnect();
      if (success) {
        _isConnected = false;
        _lastPlayerState = null;
      }
      log(
        success ? 'Disconnected from Spotify' : 'Disconnect call failed',
        severity: success ? LogSeverity.info : LogSeverity.warning,
      );
      notifyListeners();
      return success;
    } on PlatformException catch (e) {
      log(
        'PlatformException during disconnect',
        detail: '${e.code}: ${e.message}',
        severity: LogSeverity.error,
      );
      return false;
    } on MissingPluginException {
      log('MissingPluginException', severity: LogSeverity.error);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Plays track or context URI.
  Future<void> play({required String spotifyUri, bool asRadio = false}) async {
    await _runSdkCall(
      'playing URI',
      () => SpotifySdk.play(spotifyUri: spotifyUri, asRadio: asRadio),
      onSuccess: (_) async {
        log('Started playing: $spotifyUri', severity: LogSeverity.success);
        await Future<void>.delayed(const Duration(milliseconds: 300));
        await getPlayerState();
        await Future<void>.delayed(const Duration(milliseconds: 700));
        await getPlayerState();
      },
    );
  }

  /// Pauses active playback.
  Future<void> pause() async {
    await _runSdkCall(
      'pausing playback',
      SpotifySdk.pause,
      onSuccess: (_) {
        log('Playback paused');
        if (_lastPlayerState != null) {
          _lastPlayerState = PlayerState(
            _lastPlayerState!.track,
            _lastPlayerState!.playbackSpeed,
            _lastPlayerState!.playbackPosition,
            _lastPlayerState!.playbackOptions,
            _lastPlayerState!.playbackRestrictions,
            isPaused: true,
          );
          notifyListeners();
        }
        unawaited(
          Future<void>.delayed(
            const Duration(milliseconds: 250),
          ).then((_) => getPlayerState()),
        );
      },
    );
  }

  /// Resumes paused playback.
  Future<void> resume() async {
    await _runSdkCall(
      'resuming playback',
      SpotifySdk.resume,
      onSuccess: (_) {
        log('Playback resumed');
        if (_lastPlayerState != null) {
          _lastPlayerState = PlayerState(
            _lastPlayerState!.track,
            _lastPlayerState!.playbackSpeed,
            _lastPlayerState!.playbackPosition,
            _lastPlayerState!.playbackOptions,
            _lastPlayerState!.playbackRestrictions,
            isPaused: false,
          );
          notifyListeners();
        }
        unawaited(
          Future<void>.delayed(
            const Duration(milliseconds: 250),
          ).then((_) => getPlayerState()),
        );
      },
    );
  }

  /// Skips to next track.
  Future<void> skipNext() async {
    await _runSdkCall(
      'skipping next',
      SpotifySdk.skipNext,
      onSuccess: (_) async {
        log('Skipped to next track');
        await Future<void>.delayed(const Duration(milliseconds: 300));
        await getPlayerState();
        await Future<void>.delayed(const Duration(milliseconds: 700));
        await getPlayerState();
      },
    );
  }

  /// Skips to previous track.
  Future<void> skipPrevious() async {
    await _runSdkCall(
      'skipping previous',
      SpotifySdk.skipPrevious,
      onSuccess: (_) async {
        log('Skipped to previous track');
        await Future<void>.delayed(const Duration(milliseconds: 300));
        await getPlayerState();
        await Future<void>.delayed(const Duration(milliseconds: 700));
        await getPlayerState();
      },
    );
  }

  /// Skips to specific track index in context.
  Future<void> skipToIndex({
    required String spotifyUri,
    required int index,
  }) async {
    await _runSdkCall(
      'skipping to index',
      () => SpotifySdk.skipToIndex(spotifyUri: spotifyUri, trackIndex: index),
      onSuccess: (_) async {
        log('Skipped to index $index in $spotifyUri');
        await Future<void>.delayed(const Duration(milliseconds: 300));
        await getPlayerState();
        await Future<void>.delayed(const Duration(milliseconds: 700));
        await getPlayerState();
      },
    );
  }

  /// Queues a Spotify track URI.
  Future<void> queue({required String spotifyUri}) async {
    await _runSdkCall(
      'queueing track',
      () => SpotifySdk.queue(spotifyUri: spotifyUri),
      onSuccess: (_) {
        log('Queued URI: $spotifyUri', severity: LogSeverity.success);
        unawaited(
          Future<void>.delayed(
            const Duration(milliseconds: 250),
          ).then((_) => getPlayerState()),
        );
      },
    );
  }

  /// Seeks to absolute milliseconds.
  Future<void> seekTo(int ms) async {
    await _runSdkCall(
      'seeking',
      () => SpotifySdk.seekTo(positionedMilliseconds: ms),
      onSuccess: (_) {
        log('Sought to ${ms}ms');
        if (_lastPlayerState != null) {
          _lastPlayerState = PlayerState(
            _lastPlayerState!.track,
            _lastPlayerState!.playbackSpeed,
            ms,
            _lastPlayerState!.playbackOptions,
            _lastPlayerState!.playbackRestrictions,
            isPaused: _lastPlayerState!.isPaused,
          );
          notifyListeners();
        }
        unawaited(
          Future<void>.delayed(
            const Duration(milliseconds: 250),
          ).then((_) => getPlayerState()),
        );
      },
    );
  }

  /// Seeks relative milliseconds.
  Future<void> seekToRelative(int relativeMs) async {
    await _runSdkCall(
      'relative seek',
      () => SpotifySdk.seekToRelativePosition(
        relativeMilliseconds: relativeMs,
      ),
      onSuccess: (_) {
        log('Sought relative ${relativeMs}ms');
        if (_lastPlayerState != null) {
          final currentMs = _lastPlayerState!.playbackPosition;
          final duration = _lastPlayerState!.track?.duration ?? 0;
          final newMs = (currentMs + relativeMs).clamp(0, duration);
          _lastPlayerState = PlayerState(
            _lastPlayerState!.track,
            _lastPlayerState!.playbackSpeed,
            newMs,
            _lastPlayerState!.playbackOptions,
            _lastPlayerState!.playbackRestrictions,
            isPaused: _lastPlayerState!.isPaused,
          );
          notifyListeners();
        }
        unawaited(
          Future<void>.delayed(
            const Duration(milliseconds: 250),
          ).then((_) => getPlayerState()),
        );
      },
    );
  }

  /// Toggles shuffle mode.
  Future<void> toggleShuffle() async {
    await _runSdkCall(
      'toggling shuffle',
      SpotifySdk.toggleShuffle,
      onSuccess: (_) {
        log('Toggled shuffle mode');
        if (_lastPlayerState != null) {
          final currentShuffle = _lastPlayerState!.playbackOptions.isShuffling;
          final newOptions = PlayerOptions(
            _lastPlayerState!.playbackOptions.repeatMode,
            isShuffling: !currentShuffle,
          );
          _lastPlayerState = PlayerState(
            _lastPlayerState!.track,
            _lastPlayerState!.playbackSpeed,
            _lastPlayerState!.playbackPosition,
            newOptions,
            _lastPlayerState!.playbackRestrictions,
            isPaused: _lastPlayerState!.isPaused,
          );
          notifyListeners();
        }
        unawaited(
          Future<void>.delayed(
            const Duration(milliseconds: 250),
          ).then((_) => getPlayerState()),
        );
      },
    );
  }

  /// Explicitly sets shuffle status.
  Future<void> setShuffle({required bool shuffle}) async {
    await _runSdkCall(
      'setting shuffle',
      () => SpotifySdk.setShuffle(shuffle: shuffle),
      onSuccess: (_) {
        log('Set shuffle to $shuffle');
        if (_lastPlayerState != null) {
          final newOptions = PlayerOptions(
            _lastPlayerState!.playbackOptions.repeatMode,
            isShuffling: shuffle,
          );
          _lastPlayerState = PlayerState(
            _lastPlayerState!.track,
            _lastPlayerState!.playbackSpeed,
            _lastPlayerState!.playbackPosition,
            newOptions,
            _lastPlayerState!.playbackRestrictions,
            isPaused: _lastPlayerState!.isPaused,
          );
          notifyListeners();
        }
        unawaited(
          Future<void>.delayed(
            const Duration(milliseconds: 250),
          ).then((_) => getPlayerState()),
        );
      },
    );
  }

  /// Toggles repeat mode.
  Future<void> toggleRepeat() async {
    await _runSdkCall(
      'toggling repeat',
      SpotifySdk.toggleRepeat,
      onSuccess: (_) {
        log('Toggled repeat mode');
        if (_lastPlayerState != null) {
          final currentMode = _lastPlayerState!.playbackOptions.repeatMode;
          final nextMode = currentMode == SpotifyRepeatMode.off
              ? SpotifyRepeatMode.context
              : (currentMode == SpotifyRepeatMode.context
                    ? SpotifyRepeatMode.track
                    : SpotifyRepeatMode.off);
          final newOptions = PlayerOptions(
            nextMode,
            isShuffling: _lastPlayerState!.playbackOptions.isShuffling,
          );
          _lastPlayerState = PlayerState(
            _lastPlayerState!.track,
            _lastPlayerState!.playbackSpeed,
            _lastPlayerState!.playbackPosition,
            newOptions,
            _lastPlayerState!.playbackRestrictions,
            isPaused: _lastPlayerState!.isPaused,
          );
          notifyListeners();
        }
        unawaited(
          Future<void>.delayed(
            const Duration(milliseconds: 250),
          ).then((_) => getPlayerState()),
        );
      },
    );
  }

  /// Sets explicit repeat mode.
  Future<void> setRepeatMode(SpotifyRepeatMode mode) async {
    await _runSdkCall(
      'setting repeat mode',
      () => SpotifySdk.setRepeatMode(repeatMode: mode),
      onSuccess: (_) {
        log('Set repeat mode to ${mode.name}');
        if (_lastPlayerState != null) {
          final newOptions = PlayerOptions(
            mode,
            isShuffling: _lastPlayerState!.playbackOptions.isShuffling,
          );
          _lastPlayerState = PlayerState(
            _lastPlayerState!.track,
            _lastPlayerState!.playbackSpeed,
            _lastPlayerState!.playbackPosition,
            newOptions,
            _lastPlayerState!.playbackRestrictions,
            isPaused: _lastPlayerState!.isPaused,
          );
          notifyListeners();
        }
        unawaited(
          Future<void>.delayed(
            const Duration(milliseconds: 250),
          ).then((_) => getPlayerState()),
        );
      },
    );
  }

  /// Sets podcast playback speed.
  Future<void> setPodcastPlaybackSpeed(PodcastPlaybackSpeed speed) async {
    await _runSdkCall(
      'setting podcast speed',
      () => SpotifySdk.setPodcastPlaybackSpeed(podcastPlaybackSpeed: speed),
      onSuccess: (_) {
        log('Set podcast speed to ${speed.name}');
        unawaited(
          Future<void>.delayed(
            const Duration(milliseconds: 250),
          ).then((_) => getPlayerState()),
        );
      },
    );
  }

  /// Adds item to user library.
  Future<void> addToLibrary({required String spotifyUri}) async {
    await _runSdkCall(
      'adding to library',
      () => SpotifySdk.addToLibrary(spotifyUri: spotifyUri),
      onSuccess: (_) {
        log('Added $spotifyUri to library', severity: LogSeverity.success);
      },
    );
  }

  /// Removes item from user library.
  Future<void> removeFromLibrary({required String spotifyUri}) async {
    await _runSdkCall(
      'removing from library',
      () => SpotifySdk.removeFromLibrary(spotifyUri: spotifyUri),
      onSuccess: (_) {
        log('Removed $spotifyUri from library');
      },
    );
  }

  /// Gets library state of item.
  Future<LibraryState?> getLibraryState({required String spotifyUri}) async {
    return _runSdkCall(
      'getting library state',
      () => SpotifySdk.getLibraryState(spotifyUri: spotifyUri),
      onSuccess: (state) {
        _lastLibraryState = state;
        log('Fetched library state for $spotifyUri');
        notifyListeners();
      },
    );
  }

  /// Gets user capabilities for URI.
  Future<Capabilities?> getCapabilities({required String spotifyUri}) async {
    return _runSdkCall(
      'getting capabilities',
      () => SpotifySdk.getCapabilities(spotifyUri: spotifyUri),
      onSuccess: (capabilities) {
        _userCapabilities = capabilities;
        log('Fetched capabilities for $spotifyUri');
        notifyListeners();
      },
    );
  }

  /// Fetches current crossfade state.
  Future<CrossfadeState?> getCrossfadeState() async {
    return _runSdkCall(
      'getting crossfade state',
      SpotifySdk.getCrossFadeState,
      onSuccess: (state) {
        _crossfadeState = state;
        log('Fetched crossfade state: enabled=${state?.isEnabled}');
        notifyListeners();
      },
    );
  }

  /// Switches playback to local device.
  Future<void> switchToLocalDevice() async {
    await _runSdkCall(
      'switching to local device',
      SpotifySdk.switchToLocalDevice,
      onSuccess: (_) {
        log(
          'Switched playback to local device',
          severity: LogSeverity.success,
        );
      },
    );
  }

  @override
  void dispose() {
    unawaited(_connectionSubscription?.cancel());
    unawaited(_playerStateSubscription?.cancel());
    super.dispose();
  }
}
