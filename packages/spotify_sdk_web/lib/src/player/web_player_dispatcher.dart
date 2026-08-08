import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:js_interop';

import 'package:spotify_sdk_platform_interface/models/player_options.dart'
    as options;
import 'package:spotify_sdk_platform_interface/spotify_sdk_platform_interface.dart'
    hide PlayerOptions;
import 'package:spotify_sdk_web/src/interop/web_playback_sdk.dart';

/// Handles listener registration, domain model conversion, and stream event
/// dispatching for the Spotify Web Playback SDK player.
class WebPlayerDispatcher {
  /// Creates a [WebPlayerDispatcher].
  WebPlayerDispatcher({
    required this.playerContextEventController,
    required this.playerStateEventController,
    required this.connectionStatusEventController,
    required this.onSpotifyConnected,
    required this.onSpotifyDisconnected,
  });

  /// Event stream controller for player context changes.
  final StreamController<String> playerContextEventController;

  /// Event stream controller for player state changes.
  final StreamController<String> playerStateEventController;

  /// Event stream controller for connection status updates.
  final StreamController<String> connectionStatusEventController;

  /// Callback when player emits 'ready' event.
  final void Function(String deviceId) onSpotifyConnected;

  /// Callback when player emits disconnect or error event.
  final void Function({String? errorCode, String? errorDetails})
  onSpotifyDisconnected;

  /// Most recent player state.
  PlayerState? lastPlayerState;

  /// Registers Spotify player event handlers.
  void registerPlayerEvents(Player player) {
    player
      ..addListener(
        'player_state_changed',
        ((WebPlaybackState? state) {
          if (state == null) return;
          final pState = toPlayerState(state);
          if (pState != null) {
            lastPlayerState = pState;
            playerStateEventController.add(jsonEncode(pState.toJson()));
          }
          final pContext = toPlayerContext(state);
          if (pContext != null) {
            playerContextEventController.add(jsonEncode(pContext.toJson()));
          }
        }).toJS,
      )
      ..addListener(
        'ready',
        ((WebPlaybackPlayer player) {
          log('Spotify SDK ready!');
          onSpotifyConnected(player.device_id ?? '');
        }).toJS,
      )
      ..addListener(
        'not_ready',
        ((JSAny? event) {
          onSpotifyDisconnected(
            errorCode: 'Spotify SDK not ready',
            errorDetails: 'Spotify SDK is not ready to take requests',
          );
        }).toJS,
      )
      ..addListener(
        'initialization_error',
        ((WebPlaybackError error) {
          onSpotifyDisconnected(
            errorCode: 'Initialization Error',
            errorDetails: error.message ?? '',
          );
        }).toJS,
      )
      ..addListener(
        'authentication_error',
        ((WebPlaybackError error) {
          if (error.message != null &&
              error.message!.contains('Browser prevented autoplay')) {
            log('authentication_error: ${error.message}');
            return;
          }
          onSpotifyDisconnected(
            errorCode: 'Authentication Error',
            errorDetails: error.message ?? '',
          );
        }).toJS,
      )
      ..addListener(
        'account_error',
        ((WebPlaybackError error) {
          onSpotifyDisconnected(
            errorCode: 'Account Error',
            errorDetails: error.message ?? '',
          );
        }).toJS,
      )
      ..addListener(
        'playback_error',
        ((WebPlaybackError error) {
          log('playback_error: ${error.message}');
        }).toJS,
      );
  }

  /// Unregisters Spotify player event handlers.
  void unregisterPlayerEvents(Player player) {
    player
      ..removeListener('player_state_changed')
      ..removeListener('ready')
      ..removeListener('not_ready')
      ..removeListener('initialization_error')
      ..removeListener('authentication_error')
      ..removeListener('account_error')
      ..removeListener('playback_error');
  }

  /// Converts native [WebPlaybackState] to library [PlayerState].
  PlayerState? toPlayerState(WebPlaybackState? state) {
    if (state == null) return null;
    final trackRaw = state.track_window?.current_track;
    final albumRaw = trackRaw?.album;
    final artists = <Artist>[];

    if (trackRaw != null && trackRaw.artists != null) {
      for (final artist in trackRaw.artists!.toDart) {
        artists.add(Artist(artist.name ?? '', artist.uri ?? ''));
      }
    }

    if (artists.isEmpty) {
      artists.add(Artist('', ''));
    }

    SpotifyRepeatMode repeatMode;
    switch (state.repeat_mode) {
      case 1:
        repeatMode = SpotifyRepeatMode.context;
      case 2:
        repeatMode = SpotifyRepeatMode.track;
      default:
        repeatMode = SpotifyRepeatMode.off;
    }

    final imageUrl =
        (albumRaw?.images != null && albumRaw!.images!.toDart.isNotEmpty)
        ? albumRaw.images!.toDart[0].url ?? ''
        : '';

    final duration = state.duration ?? trackRaw?.duration_ms ?? 0;

    return PlayerState(
      trackRaw != null
          ? Track(
              Album(albumRaw?.name ?? '', albumRaw?.uri ?? ''),
              artists[0],
              artists,
              duration,
              ImageUri(imageUrl),
              trackRaw.name ?? '',
              trackRaw.uri ?? '',
              trackRaw.linked_from?.uri ?? '',
              isEpisode: trackRaw.type == 'episode',
              isPodcast: trackRaw.type == 'episode',
            )
          : null,
      1,
      state.position ?? 0,
      options.PlayerOptions(repeatMode, isShuffling: state.shuffle ?? false),
      PlayerRestrictions(
        canSkipNext: true,
        canSkipPrevious: true,
        canSeek: true,
        canRepeatTrack: true,
        canRepeatContext: true,
        canToggleShuffle: true,
      ),
      isPaused: state.paused ?? true,
    );
  }

  /// Converts native [WebPlaybackState] to library [PlayerContext].
  PlayerContext? toPlayerContext(WebPlaybackState? state) {
    if (state == null) return null;
    final context = state.context;
    final metadata = context?.metadata;
    return PlayerContext(
      metadata?.title ?? '',
      metadata?.subtitle ?? '',
      metadata?.type ?? '',
      context?.uri ?? '',
    );
  }
}
