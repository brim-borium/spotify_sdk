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
    try {
      final state = await SpotifySdk.getPlayerState();
      if (state != null) {
        _lastPlayerState = state;
        notifyListeners();
      }
      return state;
    } on PlatformException catch (e) {
      log(
        'Error getting player state',
        detail: '${e.code}: ${e.message}',
        severity: LogSeverity.error,
      );
      return null;
    } on MissingPluginException {
      log('GetPlayerState not implemented', severity: LogSeverity.error);
      return null;
    }
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
    try {
      await SpotifySdk.play(spotifyUri: spotifyUri, asRadio: asRadio);
      log('Started playing: $spotifyUri', severity: LogSeverity.success);
      await Future<void>.delayed(const Duration(milliseconds: 300));
      await getPlayerState();
      await Future<void>.delayed(const Duration(milliseconds: 700));
      await getPlayerState();
    } on PlatformException catch (e) {
      log(
        'Error playing URI',
        detail: '${e.code}: ${e.message}',
        severity: LogSeverity.error,
      );
    } on MissingPluginException {
      log('Play not implemented on platform', severity: LogSeverity.error);
    }
  }

  /// Pauses active playback.
  Future<void> pause() async {
    try {
      await SpotifySdk.pause();
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
      await Future<void>.delayed(const Duration(milliseconds: 250));
      unawaited(getPlayerState());
    } on PlatformException catch (e) {
      log(
        'Error pausing playback',
        detail: '${e.code}: ${e.message}',
        severity: LogSeverity.error,
      );
    } on MissingPluginException {
      log('Pause not implemented', severity: LogSeverity.error);
    }
  }

  /// Resumes paused playback.
  Future<void> resume() async {
    try {
      await SpotifySdk.resume();
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
      await Future<void>.delayed(const Duration(milliseconds: 250));
      unawaited(getPlayerState());
    } on PlatformException catch (e) {
      log(
        'Error resuming playback',
        detail: '${e.code}: ${e.message}',
        severity: LogSeverity.error,
      );
    } on MissingPluginException {
      log('Resume not implemented', severity: LogSeverity.error);
    }
  }

  /// Skips to next track.
  Future<void> skipNext() async {
    try {
      await SpotifySdk.skipNext();
      log('Skipped to next track');
      await Future<void>.delayed(const Duration(milliseconds: 300));
      await getPlayerState();
      await Future<void>.delayed(const Duration(milliseconds: 700));
      await getPlayerState();
    } on PlatformException catch (e) {
      log(
        'Error skipping next',
        detail: '${e.code}: ${e.message}',
        severity: LogSeverity.error,
      );
    } on MissingPluginException {
      log('SkipNext not implemented', severity: LogSeverity.error);
    }
  }

  /// Skips to previous track.
  Future<void> skipPrevious() async {
    try {
      await SpotifySdk.skipPrevious();
      log('Skipped to previous track');
      await Future<void>.delayed(const Duration(milliseconds: 300));
      await getPlayerState();
      await Future<void>.delayed(const Duration(milliseconds: 700));
      await getPlayerState();
    } on PlatformException catch (e) {
      log(
        'Error skipping previous',
        detail: '${e.code}: ${e.message}',
        severity: LogSeverity.error,
      );
    } on MissingPluginException {
      log('SkipPrevious not implemented', severity: LogSeverity.error);
    }
  }

  /// Skips to specific track index in context.
  Future<void> skipToIndex({
    required String spotifyUri,
    required int index,
  }) async {
    try {
      await SpotifySdk.skipToIndex(spotifyUri: spotifyUri, trackIndex: index);
      log('Skipped to index $index in $spotifyUri');
      await Future<void>.delayed(const Duration(milliseconds: 300));
      await getPlayerState();
      await Future<void>.delayed(const Duration(milliseconds: 700));
      await getPlayerState();
    } on PlatformException catch (e) {
      log(
        'Error skipping to index',
        detail: '${e.code}: ${e.message}',
        severity: LogSeverity.error,
      );
    } on MissingPluginException {
      log('SkipToIndex not implemented', severity: LogSeverity.error);
    }
  }

  /// Queues a Spotify track URI.
  Future<void> queue({required String spotifyUri}) async {
    try {
      await SpotifySdk.queue(spotifyUri: spotifyUri);
      log('Queued URI: $spotifyUri', severity: LogSeverity.success);
      await Future<void>.delayed(const Duration(milliseconds: 250));
      unawaited(getPlayerState());
    } on PlatformException catch (e) {
      log(
        'Error queueing track',
        detail: '${e.code}: ${e.message}',
        severity: LogSeverity.error,
      );
    } on MissingPluginException {
      log('Queue not implemented', severity: LogSeverity.error);
    }
  }

  /// Seeks to absolute milliseconds.
  Future<void> seekTo(int ms) async {
    try {
      await SpotifySdk.seekTo(positionedMilliseconds: ms);
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
      await Future<void>.delayed(const Duration(milliseconds: 250));
      unawaited(getPlayerState());
    } on PlatformException catch (e) {
      log(
        'Error seeking',
        detail: '${e.code}: ${e.message}',
        severity: LogSeverity.error,
      );
    } on MissingPluginException {
      log('SeekTo not implemented', severity: LogSeverity.error);
    }
  }

  /// Seeks relative milliseconds.
  Future<void> seekToRelative(int relativeMs) async {
    try {
      await SpotifySdk.seekToRelativePosition(
        relativeMilliseconds: relativeMs,
      );
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
      await Future<void>.delayed(const Duration(milliseconds: 250));
      unawaited(getPlayerState());
    } on PlatformException catch (e) {
      log(
        'Error relative seek',
        detail: '${e.code}: ${e.message}',
        severity: LogSeverity.error,
      );
    } on MissingPluginException {
      log('SeekRelative not implemented', severity: LogSeverity.error);
    }
  }

  /// Toggles shuffle mode.
  Future<void> toggleShuffle() async {
    try {
      await SpotifySdk.toggleShuffle();
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
      await Future<void>.delayed(const Duration(milliseconds: 250));
      unawaited(getPlayerState());
    } on PlatformException catch (e) {
      log(
        'Error toggling shuffle',
        detail: '${e.code}: ${e.message}',
        severity: LogSeverity.error,
      );
    } on MissingPluginException {
      log('ToggleShuffle not implemented', severity: LogSeverity.error);
    }
  }

  /// Explicitly sets shuffle status.
  Future<void> setShuffle({required bool shuffle}) async {
    try {
      await SpotifySdk.setShuffle(shuffle: shuffle);
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
      await Future<void>.delayed(const Duration(milliseconds: 250));
      unawaited(getPlayerState());
    } on PlatformException catch (e) {
      log(
        'Error setting shuffle',
        detail: '${e.code}: ${e.message}',
        severity: LogSeverity.error,
      );
    } on MissingPluginException {
      log('SetShuffle not implemented', severity: LogSeverity.error);
    }
  }

  /// Toggles repeat mode.
  Future<void> toggleRepeat() async {
    try {
      await SpotifySdk.toggleRepeat();
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
      await Future<void>.delayed(const Duration(milliseconds: 250));
      unawaited(getPlayerState());
    } on PlatformException catch (e) {
      log(
        'Error toggling repeat',
        detail: '${e.code}: ${e.message}',
        severity: LogSeverity.error,
      );
    } on MissingPluginException {
      log('ToggleRepeat not implemented', severity: LogSeverity.error);
    }
  }

  /// Sets explicit repeat mode.
  Future<void> setRepeatMode(SpotifyRepeatMode mode) async {
    try {
      await SpotifySdk.setRepeatMode(repeatMode: mode);
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
      await Future<void>.delayed(const Duration(milliseconds: 250));
      unawaited(getPlayerState());
    } on PlatformException catch (e) {
      log(
        'Error setting repeat mode',
        detail: '${e.code}: ${e.message}',
        severity: LogSeverity.error,
      );
    } on MissingPluginException {
      log('SetRepeatMode not implemented', severity: LogSeverity.error);
    }
  }

  /// Sets podcast playback speed.
  Future<void> setPodcastPlaybackSpeed(PodcastPlaybackSpeed speed) async {
    try {
      await SpotifySdk.setPodcastPlaybackSpeed(podcastPlaybackSpeed: speed);
      log('Set podcast speed to ${speed.name}');
      await Future<void>.delayed(const Duration(milliseconds: 250));
      unawaited(getPlayerState());
    } on PlatformException catch (e) {
      log(
        'Error setting podcast speed',
        detail: '${e.code}: ${e.message}',
        severity: LogSeverity.error,
      );
    } on MissingPluginException {
      log(
        'SetPodcastPlaybackSpeed not implemented',
        severity: LogSeverity.error,
      );
    }
  }

  /// Adds item to user library.
  Future<void> addToLibrary({required String spotifyUri}) async {
    try {
      await SpotifySdk.addToLibrary(spotifyUri: spotifyUri);
      log('Added $spotifyUri to library', severity: LogSeverity.success);
    } on PlatformException catch (e) {
      log(
        'Error adding to library',
        detail: '${e.code}: ${e.message}',
        severity: LogSeverity.error,
      );
    } on MissingPluginException {
      log('AddToLibrary not implemented', severity: LogSeverity.error);
    }
  }

  /// Removes item from user library.
  Future<void> removeFromLibrary({required String spotifyUri}) async {
    try {
      await SpotifySdk.removeFromLibrary(spotifyUri: spotifyUri);
      log('Removed $spotifyUri from library');
    } on PlatformException catch (e) {
      log(
        'Error removing from library',
        detail: '${e.code}: ${e.message}',
        severity: LogSeverity.error,
      );
    } on MissingPluginException {
      log('RemoveFromLibrary not implemented', severity: LogSeverity.error);
    }
  }

  /// Gets library state of item.
  Future<LibraryState?> getLibraryState({required String spotifyUri}) async {
    try {
      final state = await SpotifySdk.getLibraryState(spotifyUri: spotifyUri);
      _lastLibraryState = state;
      log('Fetched library state for $spotifyUri');
      notifyListeners();
      return state;
    } on PlatformException catch (e) {
      log(
        'Error getting library state',
        detail: '${e.code}: ${e.message}',
        severity: LogSeverity.error,
      );
      return null;
    } on MissingPluginException {
      log('GetLibraryState not implemented', severity: LogSeverity.error);
      return null;
    }
  }

  /// Gets user capabilities for URI.
  Future<Capabilities?> getCapabilities({required String spotifyUri}) async {
    try {
      final capabilities = await SpotifySdk.getCapabilities(
        spotifyUri: spotifyUri,
      );
      _userCapabilities = capabilities;
      log('Fetched capabilities for $spotifyUri');
      notifyListeners();
      return capabilities;
    } on PlatformException catch (e) {
      log(
        'Error getting capabilities',
        detail: '${e.code}: ${e.message}',
        severity: LogSeverity.error,
      );
      return null;
    } on MissingPluginException {
      log('GetCapabilities not implemented', severity: LogSeverity.error);
      return null;
    }
  }

  /// Fetches current crossfade state.
  Future<CrossfadeState?> getCrossfadeState() async {
    try {
      final state = await SpotifySdk.getCrossFadeState();
      _crossfadeState = state;
      log('Fetched crossfade state: enabled=${state?.isEnabled}');
      notifyListeners();
      return state;
    } on PlatformException catch (e) {
      log(
        'Error getting crossfade state',
        detail: '${e.code}: ${e.message}',
        severity: LogSeverity.error,
      );
      return null;
    } on MissingPluginException {
      log('GetCrossfadeState not implemented', severity: LogSeverity.error);
      return null;
    }
  }

  /// Switches playback to local device.
  Future<void> switchToLocalDevice() async {
    try {
      await SpotifySdk.switchToLocalDevice();
      log('Switched playback to local device', severity: LogSeverity.success);
    } on PlatformException catch (e) {
      log(
        'Error switching to local device',
        detail: '${e.code}: ${e.message}',
        severity: LogSeverity.error,
      );
    } on MissingPluginException {
      log('SwitchToLocalDevice not implemented', severity: LogSeverity.error);
    }
  }

  @override
  void dispose() {
    unawaited(_connectionSubscription?.cancel());
    unawaited(_playerStateSubscription?.cancel());
    super.dispose();
  }
}
