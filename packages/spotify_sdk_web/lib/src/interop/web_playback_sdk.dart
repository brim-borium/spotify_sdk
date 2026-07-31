// Known issue with JS interop analyzer in Dart - these functions are
// available at runtime
// but the analyzer cannot resolve them. This is a known limitation.
// See: https://github.com/dart-lang/sdk/issues/49651
// The Spotify Web Playback SDK JS library uses snake_case and features
// methods that cannot be statically resolved by the Dart JS analyzer.
// ignore_for_file: non_constant_identifier_names

import 'dart:js_interop';

/// Allows assigning the function onSpotifyWebPlaybackSDKReady
/// to be callable from `window.onSpotifyWebPlaybackSDKReady()`
@JS('onSpotifyWebPlaybackSDKReady')
external set onSpotifyWebPlaybackSDKReady(JSFunction? f);

/// Allows retrieving the function onSpotifyWebPlaybackSDKReady
@JS('onSpotifyWebPlaybackSDKReady')
external JSFunction? get onSpotifyWebPlaybackSDKReady;

/// Spotify Player Object
@JS('Spotify.Player')
extension type Player._(JSObject _) implements JSObject {
  /// The main constructor for initializing the Web Playback SDK.
  /// It should contain an object with the player name, volume and access token.
  external Player(PlayerOptions options);

  /// Device id of the player.
  external String? get deviceID;
  external set deviceID(String? value);

  /// Connects Web Playback SDK instance to Spotify
  /// with the credentials provided during initialization.
  external JSPromise connect();

  /// Closes the current session that Web Playback SDK has with Spotify.
  external void disconnect();

  /// Create a new event listener in the Web Playback SDK.
  external void addListener(String type, JSFunction callback);

  /// Remove an event listener in the Web Playback SDK.
  external void removeListener(String eventName);

  /// Collect metadata on local playback.
  external JSPromise getCurrentState();

  /// Rename the Spotify Player device.
  /// This is visible across all Spotify Connect devices.
  external JSPromise setName(String name);

  /// Set the local volume for the Web Playback SDK.
  external JSPromise setVolume(double volume);

  /// Pause the local playback.
  external JSPromise pause();

  /// Resume the local playback.
  external JSPromise resume();

  /// Resume/pause the local playback.
  external JSPromise togglePlay();

  /// Seek to a position in the current track in local playback.
  external JSPromise seek(int positionMs);

  /// Switch to the previous track in local playback.
  external JSPromise previousTrack();

  /// Skip to the next track in local playback.
  external JSPromise nextTrack();
}

/// Spotify player options object
@JS()
extension type PlayerOptions._(JSObject _) implements JSObject {
  /// constructor
  external factory PlayerOptions({
    String? name,
    JSFunction? getOAuthToken,
    double? volume,
  });

  /// name
  external String? get name;

  /// getOAuthToken
  external JSFunction? get getOAuthToken;

  /// volume
  external double? get volume;
}

/// Spotify playback object
@JS()
extension type WebPlaybackPlayer._(JSObject _) implements JSObject {
  /// constructor
  external factory WebPlaybackPlayer({String? device_id});

  /// device id
  external String? get device_id;
}

/// Spotify playback state object
@JS()
extension type WebPlaybackState._(JSObject _) implements JSObject {
  /// constructor
  external factory WebPlaybackState({
    WebPlayerContext? context,
    WebPlayerDisallows? disallows,
    bool? paused,
    int? position,
    int? repeat_mode,
    bool? shuffle,
    WebPlayerTrackWindow? track_window,
  });

  /// context
  external WebPlayerContext? get context;

  /// disallows
  external WebPlayerDisallows? get disallows;

  /// paused
  external bool? get paused;

  /// position
  external int? get position;

  /// repeat mode
  external int? get repeat_mode;

  /// shuffle
  external bool? get shuffle;

  /// track window
  external WebPlayerTrackWindow? get track_window;
}

/// Spotify player context object
@JS()
extension type WebPlayerContext._(JSObject _) implements JSObject {
  /// constructor
  external factory WebPlayerContext({
    String? uri,
    WebPlayerContextMetadata? metadata,
  });

  /// uri
  external String? get uri;

  /// metadata
  external WebPlayerContextMetadata? get metadata;
}

/// Spotify player context metadata object
@JS()
extension type WebPlayerContextMetadata._(JSObject _) implements JSObject {
  /// constructor
  external factory WebPlayerContextMetadata({
    String? title,
    String? subtitle,
    String? type,
  });

  /// title
  external String? get title;

  /// subtitle
  external String? get subtitle;

  /// type
  external String? get type;
}

/// Spotify player disallows object
@JS()
extension type WebPlayerDisallows._(JSObject _) implements JSObject {
  /// constructor
  external factory WebPlayerDisallows({
    bool? pausing,
    bool? peeking_next,
    bool? peeking_prev,
    bool? resuming,
    bool? seeking,
    bool? skipping_next,
    bool? skipping_prev,
  });

  /// pausing
  external bool? get pausing;

  /// peeking next
  external bool? get peeking_next;

  /// peeking prev
  external bool? get peeking_prev;

  /// resuming
  external bool? get resuming;

  /// seeking
  external bool? get seeking;

  /// skipping next
  external bool? get skipping_next;

  /// skipping prev
  external bool? get skipping_prev;
}

/// Spotify player track window object
@JS()
extension type WebPlayerTrackWindow._(JSObject _) implements JSObject {
  /// constructor
  external factory WebPlayerTrackWindow({
    WebPlaybackTrack? current_track,
    JSArray<WebPlaybackTrack>? previous_tracks,
    JSArray<WebPlaybackTrack>? next_tracks,
  });

  /// current track
  external WebPlaybackTrack? get current_track;

  /// previous tracks
  external JSArray<WebPlaybackTrack>? get previous_tracks;

  /// next tracks
  external JSArray<WebPlaybackTrack>? get next_tracks;
}

/// Spotify playback track object
@JS()
extension type WebPlaybackTrack._(JSObject _) implements JSObject {
  /// constructor
  external factory WebPlaybackTrack({
    String? uri,
    String? id,
    String? type,
    String? media_type,
    String? name,
    bool? is_playable,
    WebPlaybackAlbum? album,
    JSArray<WebPlaybackArtist>? artists,
    WebLinkedFrom? linked_from,
  });

  /// uri
  external String? get uri;

  /// id
  external String? get id;

  /// type
  external String? get type;

  /// media type
  external String? get media_type;

  /// name
  external String? get name;

  /// is playable
  external bool? get is_playable;

  /// album
  external WebPlaybackAlbum? get album;

  /// artists
  external JSArray<WebPlaybackArtist>? get artists;

  /// linked from
  external WebLinkedFrom? get linked_from;
}

/// Spotify playback album object
@JS()
extension type WebPlaybackAlbum._(JSObject _) implements JSObject {
  /// constructor
  external factory WebPlaybackAlbum({
    String? uri,
    String? name,
    JSArray<WebPlaybackAlbumImage>? images,
  });

  /// uri
  external String? get uri;

  /// name
  external String? get name;

  /// images
  external JSArray<WebPlaybackAlbumImage>? get images;
}

/// Spotify playback album object
@JS()
extension type WebLinkedFrom._(JSObject _) implements JSObject {
  /// constructor
  external factory WebLinkedFrom({String? uri, String? id});

  /// uri
  external String? get uri;

  /// id
  external String? get id;
}

/// Spotify artist object
@JS()
extension type WebPlaybackArtist._(JSObject _) implements JSObject {
  /// constructor
  external factory WebPlaybackArtist({String? uri, String? name});

  /// uri
  external String? get uri;

  /// name
  external String? get name;
}

/// Spotify album image object
@JS()
extension type WebPlaybackAlbumImage._(JSObject _) implements JSObject {
  /// constructor
  external factory WebPlaybackAlbumImage({String? url});

  /// url
  external String? get url;
}

/// Spotify playback error object
@JS()
extension type WebPlaybackError._(JSObject _) implements JSObject {
  /// constructor
  external factory WebPlaybackError({String? message});

  /// message
  external String? get message;
}
