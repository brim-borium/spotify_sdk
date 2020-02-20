@JS()
library spotify_sdk;

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:js';
import 'dart:html';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'package:js/js.dart';
import 'package:js/js_util.dart';
import 'package:spotify_sdk/models/album.dart';
import 'package:spotify_sdk/models/artist.dart';
import 'package:spotify_sdk/models/image_uri.dart';
import 'package:spotify_sdk/models/player_context.dart';
import 'package:spotify_sdk/models/player_options.dart' as options;
import 'package:spotify_sdk/models/player_restrictions.dart';
import 'package:spotify_sdk/models/player_state.dart';
import 'package:spotify_sdk/models/track.dart';

class SpotifySdkPlugin {
  // event channels
  static const String CHANNEL_NAME = "spotify_sdk";
  static const String PLAYER_CONTEXT_SUBSCRIPTION = "player_context_subscription";
  static const String PLAYER_STATE_SUBSCRIPTION = "player_state_subscription";
  static const String PLAYER_CAPABILITIES_SUBSCRIPTION = "capabilities_subscription";
  static const String USER_STATUS_SUBSCRIPTION = "user_status_subscription";

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
  static const String PARAM_PLAYER_NAME = "playerName";
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

  // auth
  static const List<String> AUTHENTICATION_SCOPES = [
    "app-remote-control",
    "user-modify-playback-state",
    "playlist-read-private",
    "playlist-modify-public",
    "user-read-currently-playing"
  ];

  /// Whether the Spotify SDK was already loaded.
  bool _sdkLoaded = false;
  /// Current Spotify SDK player instance.
  Player _currentPlayer;
  /// Current Spotify auth token.
  SpotifyToken _spotifyToken;
  /// Cached client id used when connecting to Spotify.
  String cachedClientId;
  /// Cached redirect url used when connecting to Spotify.
  String cachedRedirectUrl;

  // Event stream controllers
  final StreamController playerContextEventController;
  final StreamController playerStateEventController;
  final StreamController playerCapabilitiesEventController;
  final StreamController userStateEventController;
  
  /// Dio http client
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.spotify.com/v1/me/player',
    )
  );

  SpotifySdkPlugin(this.playerContextEventController, this.playerStateEventController, this.playerCapabilitiesEventController, this.userStateEventController) {
    _initializeSpotify();
  }

  static void registerWith(Registrar registrar) {
    // method channel
    final MethodChannel channel = MethodChannel(CHANNEL_NAME, const StandardMethodCodec(), registrar.messenger);
    // event channels
    final PluginEventChannel playerContextEventChannel = PluginEventChannel(PLAYER_CONTEXT_SUBSCRIPTION);
    final StreamController playerContextEventController = StreamController.broadcast();
    playerContextEventChannel.controller = playerContextEventController;
    final PluginEventChannel playerStateEventChannel = PluginEventChannel(PLAYER_STATE_SUBSCRIPTION);
    final StreamController playerStateEventController = StreamController.broadcast();
    playerStateEventChannel.controller = playerStateEventController;
    final PluginEventChannel playerCapabilitiesEventChannel = PluginEventChannel(PLAYER_CAPABILITIES_SUBSCRIPTION);
    final StreamController playerCapabilitiesEventController = StreamController.broadcast();
    playerCapabilitiesEventChannel.controller = playerCapabilitiesEventController;
    final PluginEventChannel userStatusEventChannel = PluginEventChannel(USER_STATUS_SUBSCRIPTION);
    final StreamController userStatusEventController = StreamController.broadcast();
    userStatusEventChannel.controller = userStatusEventController;

    final SpotifySdkPlugin instance = SpotifySdkPlugin(playerContextEventController, playerStateEventController, playerCapabilitiesEventController, userStatusEventController);

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
        // update the client id and redirect url
        String clientId = call.arguments[PARAM_CLIENT_ID];
        String redirectUrl = call.arguments[PARAM_REDIRECT_URL];
        String playerName = call.arguments[PARAM_PLAYER_NAME];
        if (!(clientId?.isNotEmpty == true && redirectUrl?.isNotEmpty == true)) {
          throw PlatformException(message: "Client id or redirectUrl are not set or have invalid format", code: "Authentication Error");
        }
        cachedClientId = clientId;
        cachedRedirectUrl = redirectUrl;

        // get initial token
        await _getSpotifyAuthToken();

        // create player
        _currentPlayer = Player(
          PlayerOptions(
            name: playerName,
            getOAuthToken: allowInterop((Function callback, t) {
              _getSpotifyAuthToken().then((value) {
                callback(value);
              });
            })
          )
        );
        
        _registerPlayerEvents(_currentPlayer);
        return await promiseToFuture(_currentPlayer.connect());
      break;
      case METHOD_GET_AUTHENTICATION_TOKEN:
        return await _getSpotifyAuthToken(clientId: call.arguments[PARAM_CLIENT_ID], redirectUrl: call.arguments[PARAM_REDIRECT_URL]);
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
      case METHOD_PLAY:
        await promiseToFuture(_play(call.arguments[PARAM_SPOTIFY_URI]));
      break;
      case METHOD_RESUME:
        await promiseToFuture(_currentPlayer?.resume());
      break;
      case METHOD_PAUSE:
        await promiseToFuture(_currentPlayer?.pause());
      break;
      case METHOD_SKIP_NEXT:
        await promiseToFuture(_currentPlayer?.nextTrack());
      break;
      case METHOD_SKIP_PREVIOUS:
        await promiseToFuture(_currentPlayer?.previousTrack());
      break;
      /*case METHOD_TOGGLE_SHUFFLE:
        //TODO: Needs a state parameter (true/false)
        //await _currentPlayer?.toggleShuffle(state, await _getSpotifyAuthToken());
      break;*/
      /*case METHOD_TOGGLE_REPEAT:
        //TODO: Needs a state parameter (true/false)
        //await _currentPlayer?.toggleRepeat(state, await _getSpotifyAuthToken());
      break;*/
      case METHOD_GET_PLAYER_STATE:
        WebPlaybackState stateRaw = await promiseToFuture(_currentPlayer?.getCurrentState());
        if(stateRaw == null) return null;
        return jsonEncode(toPlayerState(stateRaw).toJson());
      break;
      default:
        throw PlatformException(
          code: 'Unimplemented',
          details: "The spotify_sdk plugin for web doesn't implement the method '${call.method}'");
    }
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
          if(state == null) return;
          playerStateEventController.add(jsonEncode(toPlayerState(state).toJson()));
          playerContextEventController.add(jsonEncode(toPlayerContext(state).toJson()));
        }
      )
    );

    // ready/not ready
    player.addListener(
      'ready',
      allowInterop(
        (WebPlaybackPlayer player) {
          log('Device ready! ${player?.device_id}');
          _currentPlayer.deviceID = player.device_id;
        }
      )
    );
    player.addListener(
      'not_ready',
      allowInterop(
        (event) {
          log('Device not ready!');
          _currentPlayer.deviceID = null;
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
  /// Gets the current Spotify token or reauthenticates the user if the token expired.
  Future<String> _getSpotifyAuthToken({String clientId, String redirectUrl}) async {
    if(_spotifyToken != null && _spotifyToken.expiry > DateTime.now().millisecondsSinceEpoch) {
      return _spotifyToken.token;
    }

    if(clientId == null) {
      clientId = cachedClientId;
    }
    if(redirectUrl == null) {
      redirectUrl = cachedRedirectUrl;
    }
    String newToken = await _authenticateSpotify(clientId, redirectUrl);
    _spotifyToken = SpotifyToken(newToken, DateTime.now().millisecondsSinceEpoch + 3600000);
    return _spotifyToken.token;
  }
  /// Authenticates the user and returns the access token on success.
  Future<String> _authenticateSpotify(String clientId, String redirectUrl) async {
    if (clientId?.isNotEmpty == true && redirectUrl?.isNotEmpty == true) {
        String scopes = AUTHENTICATION_SCOPES.join(' ');
        String authUrl = 'https://accounts.spotify.com/authorize?client_id=$clientId&response_type=token&scope=$scopes&redirect_uri=$redirectUrl';
        
        WindowBase authPopup = window.open(authUrl, "Spotify Authorization");
        String hash;
        String error;
        var sub = window.onMessage.listen(allowInterop((event) {
          String message = event.data.toString();
          if(message.startsWith('#')) {
            log('Hash received: ${event.data}');
            hash = message;
          } else if (message.startsWith('?')) {
            log('Authorization error: ${event.data}');
            error = message;
          }
        }));
        
        // loop and wait for auth
        while(authPopup.closed == false && hash == null && error == null) {
          // await response from the window
          await Future.delayed(Duration(milliseconds: 250));
        }

        // cleanup
        if(authPopup.closed == false) {
          authPopup.close();
        }
        await sub.cancel();

        // check output
        if(error != null || hash == null) {
          throw PlatformException(message: "$error", code: "Authentication Error");
        }
        return hash.split('&')[0].split('=')[1];
      } else {
        throw PlatformException(message: "Client id or redirectUrl are not set or have invalid format", code: "Authentication Error");
      }
  }
  /// Starts track playback on the device.
  _play(String uri) async {
    if(_currentPlayer?.deviceID == null) {
      throw PlatformException(message: "Spotify player not connected!", code: "Playback Error");
    }

    await _dio.put('/play',
      data: { 'uris': [uri] },
      queryParameters: {
        'device_id': _currentPlayer.deviceID
      },
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getSpotifyAuthToken()}'
        },
      ),
    );
  }
  /// Toggles shuffle on the current player.
  toggleShuffle(bool state) async {
    if(_currentPlayer?.deviceID == null) {
      throw PlatformException(message: "Spotify player not connected!", code: "Playback Error");
    }

    await _dio.put('https://api.spotify.com/v1/me/player/shuffle',
      queryParameters: {
        'state': state,
        'device_id': _currentPlayer.deviceID
      },
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getSpotifyAuthToken()}'
        },
      ),
    );
  }
  /// Toggles repeat on the current player.
  toggleRepeat(bool state) async {
    if(_currentPlayer?.deviceID == null) {
      throw PlatformException(message: "Spotify player not connected!", code: "Playback Error");
    }

    await _dio.put('https://api.spotify.com/v1/me/player/repeat',
      queryParameters: {
        'state': state,
        'device_id': _currentPlayer.deviceID
      },
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getSpotifyAuthToken()}'
        },
      ),
    );
  }
  /// Converts a native WebPlaybackState to the library PlayerState
  PlayerState toPlayerState(WebPlaybackState state) {
    if(state == null) return null;
    WebPlaybackTrack trackRaw = state.track_window?.current_track;
    WebPlaybackAlbum albumRaw = trackRaw?.album;
    WebPlayerDisallows restrictionsRaw = state.disallows;
    List<Artist> artists = [];
    for(var artist in trackRaw.artists) {
      artists.add(Artist(artist.name, artist.uri));
    }

    // getting repeat mode
    options.RepeatMode repeatMode;
    switch (state.repeat_mode) {
      case 1:
        repeatMode = options.RepeatMode.Context;
        break;
      case 2:
        repeatMode = options.RepeatMode.Track;
        break;
      default:
        repeatMode = options.RepeatMode.Off;
        break;
    }

    return PlayerState(
      trackRaw != null 
      ? Track (
        Album(
          albumRaw.name,
          albumRaw.uri
        ),
        artists[0],
        artists,
        null,
        ImageUri(albumRaw.images[0].url),
        false,
        false,
        trackRaw.name,
        trackRaw.uri
      )
      : null,
      state.paused,
      1.0,
      state.position,
      options.PlayerOptions(state.shuffle, repeatMode),
      PlayerRestrictions(
        restrictionsRaw.skipping_next,
        restrictionsRaw.skipping_prev,
        false,
        false, 
        false,
        restrictionsRaw.seeking
      )
    );
  }
  /// Converts a native WebPlaybackState to the library PlayerContext
  PlayerContext toPlayerContext(WebPlaybackState state) {
    if(state == null) return null;
    return PlayerContext(
     state.context.metadata.title,
     state.context.metadata.subtitle,
     state.context.metadata.type,
     state.context.uri
    );
  }
}

/// Spotify Player Object
@JS('Spotify.Player')
class Player {
  /// Device id of the player.
  String deviceID;

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
  external WebPlayerContextMetadata get metadata;

  external factory WebPlayerContext({String uri, WebPlayerContextMetadata metadata});
}
@JS()
@anonymous
class WebPlayerContextMetadata {
  external String get title;
  external String get subtitle;
  external String get type;

  external factory WebPlayerContextMetadata({String title, String subtitle, String type});
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
@JS()
@anonymous
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
@JS()
@anonymous
class WebPlaybackError {
  external String get message;

  external factory WebPlaybackError({String message});
}
class SpotifyToken {
  final String token;
  final int expiry;

  SpotifyToken(this.token, this.expiry);
}