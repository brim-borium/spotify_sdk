class EventChannels {
  static const String playerContext = 'player_context_subscription';
  static const String playerState = 'player_state_subscription';
  static const String userStatus = 'user_status_subscription';
  static const String capabilities = 'capabilities_subscription';
  static const String connectionStatus = 'connection_status_subscription';
}

class MethodChannels {
  static const String spotifySdk = 'spotify_sdk';
}

class MethodNames {
  // connection and auth
  static const String connectToSpotify = 'connectToSpotify';
  static const String getAuthenticationToken = 'getAuthenticationToken';
  static const String logoutFromSpotify = 'logoutFromSpotify';
  // player api
  static const String getCrossfadeState = 'getCrossfadeState';
  static const String getPlayerState = 'getPlayerState';
  static const String play = 'play';
  static const String pause = 'pause';
  static const String queueTrack = 'queueTrack';
  static const String resume = 'resume';
  static const String skipNext = 'skipNext';
  static const String skipPrevious = 'skipPrevious';
  static const String seekTo = 'seekTo';
  static const String seekToRelativePosition = 'seekToRelativePosition';
  static const String subscribePlayerContext = 'subscribePlayerContext';
  static const String subscribePlayerState = 'subscribePlayerState';
  static const String subscribeConnectionStatus = 'subscribeConnectionStatus';
  static const String toggleRepeat = 'toggleRepeat';
  static const String toggleShuffle = 'toggleShuffle';
  // user api
  static const String addToLibrary = 'addToLibrary';
  static const String removeFromLibrary = 'removeFromLibrary';
  static const String getCapabilities = 'getCapabilities';
  static const String getLibraryState = 'getLibraryState';
  // images api
  static const String getImage = 'getImage';
}
