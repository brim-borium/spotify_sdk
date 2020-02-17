@JS()
library spotify_sdk;

import 'dart:developer';
import 'dart:js';
import 'dart:html';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'package:js/js.dart';
import 'package:js/js_util.dart';

class SpotifySdkPlugin {
  // event channels
  static const String CHANNEL_NAME = "spotify_sdk";
  static const String PLAYER_CONTEXT_SUBSCRIPTION = "player_context_subscription";
  static const String PLAYER_STATE_SUBSCRIPTION = "player_state_subscription";
  static const String CAPABILITIES__SUBSCRIPTION = "capabilities_subscription";
  static const String USER_STATUS_SUBSCRIPTION = "user_status_subscription";

  static const EventChannel EVENT_CHANNEL_PLAYER_CONTEXT = EventChannel(PLAYER_CONTEXT_SUBSCRIPTION);
  static const EventChannel EVENT_CHANNEL_PLAYER_STATE = EventChannel(PLAYER_STATE_SUBSCRIPTION);
  static const EventChannel EVENT_CHANNEL_CAPABILITIES = EventChannel(CAPABILITIES__SUBSCRIPTION);
  static const EventChannel EVENT_CHANNEL_USER_STATUS = EventChannel(USER_STATUS_SUBSCRIPTION);

  // connecting
  static const String METHOD_CONNECT_TO_SPOTIFY = "connectToSpotify";
  static const String METHOD_GET_AUTHENTICATION_TOKEN = "getAuthenticationToken";
  static const String METHOD_LOGOUT_FROM_SPOTIFY = "logoutFromSpotify";

  // player api
  static const String METHOD_GET_CROSSFADE_STATE = "getCrossfadeState";
  static const String METHOD_GET_PLAYER_STATE = "getPlayerState";
  static const String METHOD_PLAY = "play";
  static const String METHOD_PAUSE = "pause";
  static const String METHOD_QUEUE_TRACK = "queueTrack";
  static const String METHOD_RESUME = "resume";
  static const String METHOD_SEEK_TO_RELATIVE_POSITION = "seekToRelativePosition";
  static const String METHOD_SET_PODCAST_PLAYBACK_SPEED = "setPodcastPlaybackSpeed";
  static const String METHOD_SKIP_NEXT = "skipNext";
  static const String METHOD_SKIP_PREVIOUS = "skipPrevious";
  static const String METHOD_SKIP_TO_INDEX = "skipToIndex";
  static const String METHOD_SEEK_TO = "seekTo";
  static const String METHOD_TOGGLE_REPEAT = "toggleRepeat";
  static const String METHOD_TOGGLE_SHUFFLE = "toggleShuffle";

  // user api
  static const METHOD_ADD_TO_LIBRARY = "addToLibrary";
  static const METHOD_REMOVE_FROM_LIBRARY = "removeFromLibrary";
  static const METHOD_GET_CAPABILITIES = "getCapabilities";
  static const METHOD_GET_LIBRARY_STATE = "getLibraryState";

  //images api
  static const METHOD_GET_IMAGE = "getImage";

  static const String PARAM_CLIENT_ID = "clientId";
  static const String PARAM_REDIRECT_URL = "redirectUrl";
  static const String PARAM_SPOTIFY_URI = "spotifyUri";
  static const String PARAM_IMAGE_URI = "imageUri";
  static const String PARAM_IMAGE_DIMENSION = "imageDimension";
  static const String PARAM_POSITIONED_MILLISECONDS = "positionedMilliseconds";
  static const String PARAM_RELATIVE_MILISECONDS = "relativeMilliseconds";
  static const String PARAM_PODCAST_PLAYBACK_SPEED = "podcastPlaybackSpeed";
  static const String PARAM_TRACK_INDEX = "trackIndex";

  static const String ERROR_CONNECTING = "errorConnecting";
  static const String ERROR_DISCONNECTING = "errorDisconnecting";
  static const String ERROR_AUTHENTICATION_TOKEN_ERROR = "authenticationTokenError";

  // spotify sdk url
  static const String SPOTIFY_SDK_URL = 'https://sdk.scdn.co/spotify-player.js';

  /*private val requestCodeAuthentication = 1337
  private val scope = arrayOf(
          "app-remote-control",
          "user-modify-playback-state",
          "playlist-read-private",
          "playlist-modify-public",
          "user-read-currently-playing")

  private var pendingOperation: PendingOperation? = null
  private var spotifyAppRemote: SpotifyAppRemote? = null
  private var spotifyPlayerApi: SpotifyPlayerApi? = null
  private var spotifyUserApi: SpotifyUserApi? = null
  private var spotifyImagesApi: SpotifyImagesApi? = null*/

  /// Dio http client
  final Dio _dio = Dio();

  /// Whether the Spotify SDK was already loaded.
  bool _sdkLoaded = false;
  /// Current Spotify SDK player instance;
  Player _currentPlayer;
  /// Current WebPlaybackPlayer instance
  WebPlaybackPlayer _currentPlayerConnection;

  static const String ACCESS_TOKEN = 'BQCphbBlirQlququgGwllsUGqX4IJ5lOSAHw86M2xSRmuQAesZvu3TDr4l2y6fH2dYP7yYLLVbFvvrHoXNOgbYWWcPRZbTqZq_6ohbATCrmfytjzy5sYPTHRgyCi5IcesTxAVTb70MFTCUiUfbGPqVdNON0hQOTWO1L1SM2S6yVEMw';

  SpotifySdkPlugin() {
    _initializeSpotify();
  }

  static void registerWith(Registrar registrar) {
    final MethodChannel channel = MethodChannel(CHANNEL_NAME, const StandardMethodCodec(), registrar.messenger);
    final SpotifySdkPlugin instance = SpotifySdkPlugin();
    channel.setMethodCallHandler(instance.handleMethodCall);
  }

  Future<dynamic> handleMethodCall(MethodCall call) async {
    // check if spotify is loaded
    if(_sdkLoaded == false) {
      throw PlatformException(
        code: 'Uninitialized',
        details: "The Spotify SDK wasn't initialized yet"
      );
    }

    switch (call.method) {
      case METHOD_CONNECT_TO_SPOTIFY:
        log('Connecting to Spotify...');
        if(_currentPlayer != null) {
          return true;
        }

        _currentPlayer = Player(
          PlayerOptions(
            name: "Test",
            getOAuthToken: allowInterop((Function callback, t) {
              callback(ACCESS_TOKEN);
            })
          )
        );
        
        _registerPlayerEvents(_currentPlayer);
        var result = await promiseToFuture(_currentPlayer.connect());
        log('Connection result: $result');
        return result;
      break;
      case METHOD_LOGOUT_FROM_SPOTIFY:
        log('Disconnecting from Spotify...');
        if(_currentPlayer == null) {
          return false;
        } else {
          _unregisterPlayerEvents(_currentPlayer);
          _currentPlayer.disconnect();
          return true;
        }
      break;
      case METHOD_RESUME:
        if(_currentPlayer == null) {
          return false;
        } else {
          await _playTrack('spotify:track:1DMEzmAoQIikcL52psptQL');
          return true;
        }
      break;
      case METHOD_PAUSE:
        if(_currentPlayer == null) {
          return false;
        } else {
          await promiseToFuture(_currentPlayer.pause());
          return true;
        }
      break;
      default:
        throw PlatformException(
          code: 'Unimplemented',
          details: "The spotify_sdk plugin for web doesn't implement the method '${call.method}'");
    }
  }

  /// Starts track playback in Spotify
  _playTrack(String uri) async {
    if(_currentPlayerConnection == null) {
      log('Spotify player not connected!');
      return;
    }

    await _dio.put('https://api.spotify.com/v1/me/player/play',
      data: { 'uris': [uri] },
      queryParameters: {
        'device_id': _currentPlayerConnection.device_id
      },
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${ACCESS_TOKEN}'
        },
      ),
    );
  }

  /// Loads the Spotify SDK library.
  _initializeSpotify() {
    context['onSpotifyWebPlaybackSDKReady'] = allowInterop(_onSpotifyInitialized);
    querySelector('body').children.add(ScriptElement()..src=SPOTIFY_SDK_URL);
  }
  /// Called when the Spotify library is loaded.
  _onSpotifyInitialized() {
    log('Spotify Initialized!');
    _sdkLoaded = true;
  }
  /// Registers Spotify event handlers.
  _registerPlayerEvents(Player player) {
    // player state
    player.addListener(
      'player_state_changed',
      allowInterop(
        (WebPlaybackState state) {
          log('Player state: ${state.track_window.current_track.name}');
        }
      )
    );

    // ready/not ready
    player.addListener(
      'ready',
      allowInterop(
        (WebPlaybackPlayer player) {
          log('Device ready! ${player?.device_id}');
          _currentPlayerConnection = player;
        }
      )
    );
    player.addListener(
      'not_ready',
      allowInterop(
        (event) {
          log('Device not ready!');
          _currentPlayerConnection = null;
        }
      )
    );

    // errors
    player.addListener(
      'initialization_error',
      allowInterop(
        (WebPlaybackError error) {
          log('initialization_error: ${error.message}');
        }
      )
    );
    player.addListener(
      'authentication_error',
      allowInterop(
        (WebPlaybackError error) {
          log('authentication_error: ${error.message}');
        }
      )
    );
    player.addListener(
      'account_error',
      allowInterop(
        (WebPlaybackError error) {
          log('account_error: ${error.message}');
        }
      )
    );
    player.addListener(
      'playback_error',
      allowInterop(
        (WebPlaybackError error) {
          log('playback_error: ${error.message}');
        }
      )
    );
  }
  _unregisterPlayerEvents(Player player) {
    player.removeListener(
      'player_state_changed'
    );
    player.removeListener(
      'ready'
    );
    player.removeListener(
      'not_ready'
    );
    player.removeListener(
      'initialization_error'
    );
    player.removeListener(
      'authentication_error'
    );
    player.removeListener(
      'account_error'
    );
    player.removeListener(
      'playback_error'
    );
  }
}

/// Spotify Player Object
@JS('Spotify.Player')
class Player {
  /// The main constructor for initializing the Web Playback SDK. It should contain an object with the player name, volume and access token.
  external Player(PlayerOptions options);
  /// Connects Web Playback SDK instance to Spotify with the credentials provided during initialization.
  external dynamic connect();
  /// Closes the current session that Web Playback SDK has with Spotify.
  external void disconnect(); 
  /// Create a new event listener in the Web Playback SDK.
  external void addListener(String type, Function callback);
  /// Remove an event listener in the Web Playback SDK.
  external void removeListener(String event_name);
  /// Collect metadata on local playback.
  external dynamic getCurrentState();
  /// Rename the Spotify Player device. This is visible across all Spotify Connect devices.
  external dynamic setName(String name);
  /// Set the local volume for the Web Playback SDK.
  external dynamic setVolume(double volume);
  /// Pause the local playback.
  external dynamic pause();
  /// Resume the local playback.
  external dynamic resume();
  /// Resume/pause the local playback.
  external dynamic togglePlay();
  /// Seek to a position in the current track in local playback.
  external dynamic seek(int position_ms);
  /// Switch to the previous track in local playback.
  external dynamic previousTrack();
  /// Skip to the next track in local playback.
  external dynamic nextTrack();
}
@JS()
@anonymous
class PlayerOptions {
  external String get name;
  external Function get getOAuthToken;
  external double get volume;

  external factory PlayerOptions({String name, Function getOAuthToken, double volume});
}
@JS()
@anonymous
class WebPlaybackPlayer {
  external String get device_id;

  external factory WebPlaybackPlayer({String device_id});
}
@JS()
@anonymous
class WebPlaybackState  {
  external WebPlayerContext get context;
  external WebPlayerDisallows get disallows;
  external bool get paused;
  external int get position;
  external int get repeat_mode;
  external bool get shuffle;
  external WebPlayerTrackWindow get track_window;

  external factory WebPlaybackState({WebPlayerContext context, WebPlayerDisallows disallows, bool paysed, int position, int repeat_mode, bool shuffle, WebPlayerTrackWindow track_window});
}
@JS()
@anonymous
class WebPlayerContext  {
  external String get uri;
  external Map get metadata;

  external factory WebPlayerContext({String uri, Map metadata});
}
@JS()
@anonymous
class WebPlayerDisallows  {
  external bool get pausing;
  external bool get peeking_next;
  external bool get peeking_prev;
  external bool get resuming;
  external bool get seeking;
  external bool get skipping_next;
  external bool get skipping_prev;

  external factory WebPlayerDisallows({bool pausing, bool peeking_next, bool peeking_prev, bool resuming, bool seeking, bool skipping_next, bool skipping_prev});
}
@JS()
@anonymous
class WebPlayerTrackWindow  {
  external WebPlaybackTrack get current_track;
  external List<WebPlaybackTrack> get previous_tracks;
  external List<WebPlaybackTrack> get next_tracks;

  external factory WebPlayerTrackWindow({WebPlaybackTrack current_track, List<WebPlaybackTrack> previous_tracks, List<WebPlaybackTrack> next_tracks});
}
@JS('WebPlaybackTrack')
class WebPlaybackTrack {
  external String get uri;
  external String get id;
  external String get type;
  external String get media_type;
  external String get name;
  external bool get is_playable;
  external WebPlaybackAlbum get album;
  external List<WebPlaybackArtist> get artists;

  external factory WebPlaybackTrack({String uri, String id, String type, String media_type, String name, bool is_playable, WebPlaybackAlbum album, List<WebPlaybackArtist> artists});
}
@JS()
@anonymous
class WebPlaybackAlbum {
  external String get uri;
  external String get name;
  external List<WebPlaybackAlbumImage> get images;

  external factory WebPlaybackAlbum({String uri, String name, List<WebPlaybackAlbumImage> images});
}
@JS()
@anonymous
class WebPlaybackArtist {
  external String get uri;
  external String get name;

  external factory WebPlaybackArtist({String uri, String name});
}
@JS()
@anonymous
class WebPlaybackAlbumImage {
  external String get url;

  external factory WebPlaybackAlbumImage({String url});
}
@JS('WebPlaybackError')
class WebPlaybackError {
  external String get message;

  external factory WebPlaybackError({String message});
}