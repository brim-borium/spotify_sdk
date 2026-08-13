import Foundation

public class SpotifySdkConstants
{
    // channels
    public static let channelSpotifySdk = "spotify_sdk"
    public static let channelPlayerContext = "player_context_subscription"
    public static let channelPlayerState = "player_state_subscription"
    public static let channelCapabilities = "capabilities_subscription"
    public static let channelUserStatus = "user_status_subscription"
    public static let channelConnectionStatus = "connection_status_subscription"

    // connecting
    public static let methodConnectToSpotify = "connectToSpotify"
    public static let methodGetAccessToken = "getAccessToken"
    public static let methodGetSwapToken = "getSwapToken"
    public static let methodIsSpotifyInstalled = "isSpotifyInstalled"
    public static let methodDisconnectFromSpotify = "disconnectFromSpotify"

    // player api
    public static let methodQueueTrack = "queueTrack"
    public static let methodPlay = "play"
    public static let methodPause = "pause"
    public static let methodResume = "resume"
    public static let methodSkipNext = "skipNext"
    public static let methodSkipPrevious = "skipPrevious"
    public static let methodSkipToIndex = "skipToIndex"
    public static let methodSeekTo = "seekTo"
    public static let methodSeekToRelativePosition = "seekToRelativePosition"
    public static let methodGetPlayerState = "getPlayerState"
    public static let methodGetCrossfadeState = "getCrossfadeState"
    public static let methodSetShuffle = "setShuffle"
    public static let methodToggleShuffle = "toggleShuffle"
    public static let methodSetRepeatMode = "setRepeatMode"
    public static let methodToggleRepeat = "toggleRepeat"
    public static let methodSwitchToLocalDevice = "switchToLocalDevice"

    // user api
    public static let methodAddToLibrary = "addToLibrary"
    public static let methodRemoveFromLibrary = "removeFromLibrary"
    public static let methodGetCapabilities = "getCapabilities"
    public static let methodGetLibraryState = "getLibraryState"

    // images api
    public static let methodGetImage = "getImage"

    // parameters
    public static let paramClientId = "clientId"
    public static let paramRedirectUrl = "redirectUrl"
    public static let paramSpotifyUri = "spotifyUri"
    public static let paramAsRadio = "asRadio"
    public static let paramImageUri = "imageUri"
    public static let paramImageDimension = "imageDimension"
    public static let paramPositionedMilliseconds = "positionedMilliseconds"
    public static let paramRelativeMilliseconds = "relativeMilliseconds"
    public static let paramAccessToken = "accessToken"
    public static let paramShuffle = "shuffle"
    public static let paramRepeatMode = "repeatMode"
    public static let paramTrackIndex = "trackIndex"
    public static let scope = "scope"
    public static let paramScope = "scope"
    public static let getLibraryState = "getLibraryState"
}
