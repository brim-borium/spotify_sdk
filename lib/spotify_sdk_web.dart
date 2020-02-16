@JS()
library spotify_sdk;

import 'dart:developer';
import 'dart:js';
import 'dart:html';

import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'package:js/js.dart';

class SpotifySdkPlugin {
  // event streams
  static const String CHANNEL_NAME = "spotify_sdk";
  static const String PLAYER_CONTEXT_SUBSCRIPTION = "player_context_subscription";
  static const String PLAYER_STATE_SUBSCRIPTION = "player_state_subscription";
  static const String CAPABILITIES__SUBSCRIPTION = "capabilities_subscription";
  static const String USER_STATUS_SUBSCRIPTION = "user_status_subscription";

  //static const String playerContextChannel = EventChannel(registrar.messenger(), PLAYER_CONTEXT_SUBSCRIPTION)
  //static const String playerStateChannel = EventChannel(registrar.messenger(), PLAYER_STATE_SUBSCRIPTION)
  //static const String capabilitiesChannel = EventChannel(registrar.messenger(), CAPABILITIES__SUBSCRIPTION)
  //static const String userStatusChannel = EventChannel(registrar.messenger(), USER_STATUS_SUBSCRIPTION)

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

  SpotifySdkPlugin() {
    _initializeSpotify();
  }

  static void registerWith(Registrar registrar) {
    final MethodChannel channel = MethodChannel(CHANNEL_NAME, const StandardMethodCodec(), registrar.messenger);
    final SpotifySdkPlugin instance = SpotifySdkPlugin();
    channel.setMethodCallHandler(instance.handleMethodCall);
  }

  Future<dynamic> handleMethodCall(MethodCall call) async {
    log('Method: ${call.method}');
    switch (call.method) {
      case METHOD_PAUSE:
        log('Starting Spotify playback...');
      break;
      default:
        throw PlatformException(
            code: 'Unimplemented',
            details: "The spotify_sdk plugin for web doesn't implement "
                "the method '${call.method}'");
    }
  }

  /// Loads the Spotify SDK library.
  _initializeSpotify() {
    context['onSpotifyWebPlaybackSDKReady'] = _onSpotifyInitialized();
    querySelector('body').children.add(ScriptElement()..src=SPOTIFY_SDK_URL);
  }
  /// Called when the Spotify library is loaded.
  _onSpotifyInitialized() {
    log('Spotify Initialized!');
  }
}