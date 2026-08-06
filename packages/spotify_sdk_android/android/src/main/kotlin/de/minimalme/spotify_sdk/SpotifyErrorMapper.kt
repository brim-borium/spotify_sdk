package de.minimalme.spotify_sdk

import com.spotify.android.appremote.api.error.*

object SpotifyErrorMapper {

    data class ErrorInfo(
        val errorCode: String,
        val errorMessage: String,
        val errorDetails: String,
        val isConnected: Boolean = false
    )

    fun mapConnectionFailure(throwable: Throwable): ErrorInfo {
        val errorDetails = throwable.toString()
        val errorMessage: String
        val errorCode: String
        var connected = false

        when (throwable) {
            is SpotifyDisconnectedException, is SpotifyConnectionTerminatedException -> {
                errorMessage = "The Spotify app was/is disconnected by the Spotify app.Reconnect necessary"
                errorCode = "SpotifyDisconnectedException"
            }
            is CouldNotFindSpotifyApp -> {
                errorMessage = "The Spotify app is not installed on the device"
                errorCode = "CouldNotFindSpotifyApp"
            }
            is AuthenticationFailedException -> {
                errorMessage = "Partner app failed to authenticate with Spotify. Check client credentials and make sure your app is registered correctly at developer.spotify.com"
                errorCode = "AuthenticationFailedException"
            }
            is UserNotAuthorizedException -> {
                errorMessage = "Indicates the user did not authorize this client of App Remote to use Spotify on the users behalf."
                errorCode = "UserNotAuthorizedException"
            }
            is UnsupportedFeatureVersionException -> {
                errorMessage = "Spotify app can't support requested features. User should update Spotify app."
                errorCode = "UnsupportedFeatureVersionException"
                connected = true
            }
            is OfflineModeException -> {
                errorMessage = "Spotify user has set their Spotify app to be in offline mode"
                errorCode = "OfflineModeException"
                connected = true
            }
            is NotLoggedInException -> {
                errorMessage = "User has logged out from Spotify."
                errorCode = "NotLoggedInException"
            }
            is SpotifyRemoteServiceException -> {
                errorMessage = "Encapsulates possible SecurityException and IllegalStateException errors."
                errorCode = "SpotifyRemoteServiceException"
            }
            else -> {
                errorMessage = "Something went wrong connecting spotify remote"
                errorCode = "errorConnection"
            }
        }
        return ErrorInfo(errorCode, errorMessage, errorDetails, connected)
    }
}
