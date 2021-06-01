/// Holds the names for all event channels that are used in the package
class EventChannels {
  /// event channel name for [playerContext]
  static const String playerContext = 'player_context_subscription';

  /// event channel name for [playerState]
  static const String playerState = 'player_state_subscription';

  /// event channel name for [userStatus]
  static const String userStatus = 'user_status_subscription';

  /// event channel name for [capabilities]
  static const String capabilities = 'capabilities_subscription';

  /// event channel name for [connectionStatus]
  static const String connectionStatus = 'connection_status_subscription';
}

/// Holds the names for all the method channels that are used in the package
class MethodChannels {
  /// method channel name for [spotifySdk]
  static const String spotifySdk = 'spotify_sdk';
}

/// Holds the names for all methods that are used in the package
class MethodNames {
  /// method name for [connectToSpotify]
  static const String connectToSpotify = 'connectToSpotify';

  /// method name for [getAuthenticationToken]
  static const String getAuthenticationToken = 'getAuthenticationToken';

  /// method name for [disconnectFromSpotify]
  static const String disconnectFromSpotify = 'disconnectFromSpotify';

  /// method name for [isSpotifyAppActive]
  static const String isSpotifyAppActive = 'isSpotifyAppActive';

  /// method name for [getCrossfadeState]
  static const String getCrossfadeState = 'getCrossfadeState';

  /// method name for [getPlayerState]
  static const String getPlayerState = 'getPlayerState';

  /// method name for [play]
  static const String play = 'play';

  /// method name for [pause]
  static const String pause = 'pause';

  /// method name for [queueTrack]
  static const String queueTrack = 'queueTrack';

  /// method name for [resume]
  static const String resume = 'resume';

  /// method name for [skipToIndex]
  static const String skipToIndex = 'skipToIndex';

  /// method name for [skipNext]
  static const String skipNext = 'skipNext';

  /// method name for [skipPrevious]
  static const String skipPrevious = 'skipPrevious';

  /// method name for [seekTo]
  static const String seekTo = 'seekTo';

  /// method name for [seekToRelativePosition]
  static const String seekToRelativePosition = 'seekToRelativePosition';

  /// method name for [subscribePlayerContext]
  static const String subscribePlayerContext = 'subscribePlayerContext';

  /// method name for [subscribePlayerState]
  static const String subscribePlayerState = 'subscribePlayerState';

  /// method name for [subscribeConnectionStatus]
  static const String subscribeConnectionStatus = 'subscribeConnectionStatus';

  /// method name for [toggleRepeat]
  static const String toggleRepeat = 'toggleRepeat';

  /// method name for [toggleShuffle]
  static const String toggleShuffle = 'toggleShuffle';

  /// method name for [addToLibrary]
  static const String addToLibrary = 'addToLibrary';

  /// method name for [removeFromLibrary]
  static const String removeFromLibrary = 'removeFromLibrary';

  /// method name for [getCapabilities]
  static const String getCapabilities = 'getCapabilities';

  /// method name for [getLibraryState]
  static const String getLibraryState = 'getLibraryState';

  /// method name for [getImage]
  static const String getImage = 'getImage';

  /// method name for [setShuffle]
  static const String setShuffle = 'setShuffle';

  /// method name for [setRepeatMode]
  static const String setRepeatMode = 'setRepeatMode';
}

/// Holds the names for all parameters that are used in the package
class ParamNames {
  /// param name for [clientId]
  static const String clientId = 'clientId';

  /// param name for [redirectUrl]
  static const String redirectUrl = 'redirectUrl';

  /// param name for [scope]
  static const String scope = 'scope';

  /// param name for [playerName]
  static const String playerName = 'playerName';

  /// param name for [spotifyUri]
  static const String spotifyUri = 'spotifyUri';

  /// param name for [imageUri]
  static const String imageUri = 'imageUri';

  /// param name for [imageDimension]
  static const String imageDimension = 'imageDimension';

  /// param name for [positionedMilliseconds]
  static const String positionedMilliseconds = 'positionedMilliseconds';

  /// param name for [relativeMilliseconds]
  static const String relativeMilliseconds = 'relativeMilliseconds';

  /// param name for [accessToken]
  static const String accessToken = 'accessToken';

  /// param name for [asRadio]
  static const String asRadio = 'asRadio';

  /// param name for [shuffle]
  static const String shuffle = 'shuffle';

  /// param name for [repeatMode]
  static const String repeatMode = 'repeatMode';

  /// param name for [uri]
  static const String uri = 'uri';

  /// param name for [trackIndex]
  static const String trackIndex = 'trackIndex';
}
