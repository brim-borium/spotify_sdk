package de.minimalme.spotify_sdk

object SpotifySdkConstants {
    // Channels
    const val CHANNEL_SPOTIFY_SDK = "spotify_sdk"
    const val CHANNEL_PLAYER_CONTEXT = "player_context_subscription"
    const val CHANNEL_PLAYER_STATE = "player_state_subscription"
    const val CHANNEL_CAPABILITIES = "capabilities_subscription"
    const val CHANNEL_USER_STATUS = "user_status_subscription"
    const val CHANNEL_CONNECTION_STATUS = "connection_status_subscription"

    // Methods - Auth & Session
    const val METHOD_CONNECT_TO_SPOTIFY = "connectToSpotify"
    const val METHOD_GET_ACCESS_TOKEN = "getAccessToken"
    const val METHOD_GET_SWAP_TOKEN = "getSwapToken"
    const val METHOD_IS_SPOTIFY_INSTALLED = "isSpotifyInstalled"
    const val METHOD_DISCONNECT_FROM_SPOTIFY = "disconnectFromSpotify"

    // Methods - Playback & Controls
    const val METHOD_SWITCH_TO_LOCAL_DEVICE = "switchToLocalDevice"
    const val METHOD_GET_CROSSFADE_STATE = "getCrossfadeState"
    const val METHOD_GET_PLAYER_STATE = "getPlayerState"
    const val METHOD_PLAY = "play"
    const val METHOD_PAUSE = "pause"
    const val METHOD_QUEUE_TRACK = "queueTrack"
    const val METHOD_RESUME = "resume"
    const val METHOD_SEEK_TO = "seekTo"
    const val METHOD_SEEK_TO_RELATIVE_POSITION = "seekToRelativePosition"
    const val METHOD_SET_PODCAST_PLAYBACK_SPEED = "setPodcastPlaybackSpeed"
    const val METHOD_SKIP_NEXT = "skipNext"
    const val METHOD_SKIP_PREVIOUS = "skipPrevious"
    const val METHOD_SKIP_TO_INDEX = "skipToIndex"
    const val METHOD_TOGGLE_SHUFFLE = "toggleShuffle"
    const val METHOD_SET_SHUFFLE = "setShuffle"
    const val METHOD_TOGGLE_REPEAT = "toggleRepeat"
    const val METHOD_SET_REPEAT_MODE = "setRepeatMode"

    // Methods - User Library & Capabilities
    const val METHOD_ADD_TO_LIBRARY = "addToLibrary"
    const val METHOD_REMOVE_FROM_LIBRARY = "removeFromLibrary"
    const val METHOD_GET_CAPABILITIES = "getCapabilities"
    const val METHOD_GET_LIBRARY_STATE = "getLibraryState"

    // Methods - Images
    const val METHOD_GET_IMAGE = "getImage"

    // Parameters
    const val PARAM_CLIENT_ID = "clientId"
    const val PARAM_REDIRECT_URL = "redirectUrl"
    const val PARAM_SCOPE = "scope"
    const val PARAM_SPOTIFY_URI = "spotifyUri"
    const val PARAM_AS_RADIO = "asRadio"
    const val PARAM_IMAGE_URI = "imageUri"
    const val PARAM_IMAGE_DIMENSION = "imageDimension"
    const val PARAM_POSITIONED_MILLISECONDS = "positionedMilliseconds"
    const val PARAM_RELATIVE_MILLISECONDS = "relativeMilliseconds"
    const val PARAM_PODCAST_PLAYBACK_SPEED = "podcastPlaybackSpeed"
    const val PARAM_TRACK_INDEX = "trackIndex"
    const val PARAM_SHUFFLE = "shuffle"
    const val PARAM_REPEAT_MODE = "repeatMode"

    // Errors
    const val ERROR_CONNECTING = "errorConnecting"
    const val ERROR_PENDING_OPERATION = "errorPendingOperation"
    const val ERROR_SPOTIFY_APP_REMOTE_NULL = "spotifyAppRemoteNull"
    const val ERROR_CONNECT_SWITCH_TO_LOCAL_DEVICE = "errorConnectSwitchToLocalDevice"
    const val ERROR_CROSSFADE_STATE = "crossfadeStateError"
    const val ERROR_PLAYER_STATE = "PlayerStateError"
    const val ERROR_PLAY = "playError"
    const val ERROR_PAUSE = "pauseError"
    const val ERROR_QUEUE = "queueError"
    const val ERROR_RESUME = "resumeError"
    const val ERROR_SEEK_TO = "seekToError"
    const val ERROR_SEEK_TO_RELATIVE_POSITION = "seekToRelativePositionError"
    const val ERROR_SET_PODCAST_PLAYBACK_SPEED = "setPodcastPlaybackSpeedError"
    const val ERROR_SKIP_NEXT = "skipNextError"
    const val ERROR_SKIP_PREVIOUS = "skipPreviousError"
    const val ERROR_SKIP_TO_INDEX = "skipToIndexError"
    const val ERROR_TOGGLE_SHUFFLE = "toggleShuffleError"
    const val ERROR_SET_SHUFFLE = "setShuffleError"
    const val ERROR_TOGGLE_REPEAT = "toggleRepeatError"
    const val ERROR_SET_REPEAT_MODE = "setRepeatModeError"
    const val ERROR_ADD_TO_LIBRARY = "addToLibraryError"
    const val ERROR_REMOVE_FROM_LIBRARY = "removeFromLibraryError"
    const val ERROR_GET_CAPABILITIES = "getCapabilitiesError"
    const val ERROR_GET_LIBRARY_STATE = "getLibraryStateError"
    const val ERROR_GET_IMAGE = "getImageError"
}
