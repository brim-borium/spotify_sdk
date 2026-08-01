package de.minimalme.spotify_sdk

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.util.Log
import com.google.gson.Gson
import com.spotify.android.appremote.api.ConnectionParams
import com.spotify.android.appremote.api.Connector.ConnectionListener
import com.spotify.android.appremote.api.SpotifyAppRemote
import com.spotify.android.appremote.api.error.*
import com.spotify.protocol.types.Image.Dimension
import com.spotify.protocol.types.ImageUri
import com.spotify.protocol.types.PlaybackSpeed
import com.spotify.sdk.android.auth.AuthorizationClient
import com.spotify.sdk.android.auth.AuthorizationRequest
import com.spotify.sdk.android.auth.AuthorizationResponse
import de.minimalme.spotify_sdk.subscriptions.*
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import kotlinx.event.SetEvent
import kotlinx.event.event
import java.io.ByteArrayOutputStream

class SpotifyRemoteController : PluginRegistry.ActivityResultListener {

    private val loggingTag = "spotify_sdk"
    private val requestCodeAuthentication = 1337

    var applicationContext: Context? = null
    var applicationActivity: Activity? = null

    // event channels & controllers
    var playerContextChannel: EventChannel? = null
    var playerStateChannel: EventChannel? = null
    var capabilitiesChannel: EventChannel? = null
    var userStatusChannel: EventChannel? = null
    var connectionStatusChannel: EventChannel? = null

    var connStatusEventChannel: SetEvent<ConnectionStatusChannel.ConnectionEvent> = event()

    private var pendingOperation: PendingOperation? = null
    var spotifyAppRemote: SpotifyAppRemote? = null

    fun handleMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "connectToSpotify" -> connectToSpotify(
                call.argument("clientId"),
                call.argument("redirectUrl"),
                result
            )
            "getAccessToken" -> getAccessToken(
                call.argument("clientId"),
                call.argument("redirectUrl"),
                call.argument("scope"),
                result
            )
            "disconnectFromSpotify" -> disconnectFromSpotify(result)
            "switchToLocalDevice" -> switchToLocalDevice(result)
            "getCrossfadeState" -> getCrossfadeState(result)
            "getPlayerState" -> getPlayerState(result)
            "play" -> play(call.argument("spotifyUri"), result)
            "pause" -> pause(result)
            "queueTrack" -> queue(call.argument("spotifyUri"), result)
            "resume" -> resume(result)
            "seekTo" -> seekTo(call.argument("positionedMilliseconds"), result)
            "seekToRelativePosition" -> seekToRelativePosition(call.argument("relativeMilliseconds"), result)
            "setPodcastPlaybackSpeed" -> setPodcastPlaybackSpeed(call.argument("podcastPlaybackSpeed"), result)
            "skipNext" -> skipNext(result)
            "skipPrevious" -> skipPrevious(result)
            "skipToIndex" -> skipToIndex(call.argument("spotifyUri"), call.argument("trackIndex"), result)
            "toggleShuffle" -> toggleShuffle(result)
            "setShuffle" -> setShuffle(call.argument("shuffle"), result)
            "toggleRepeat" -> toggleRepeat(result)
            "setRepeatMode" -> setRepeatMode(call.argument("repeatMode"), result)
            "addToLibrary" -> addToUserLibrary(call.argument("spotifyUri"), result)
            "removeFromLibrary" -> removeFromUserLibrary(call.argument("spotifyUri"), result)
            "getCapabilities" -> getCapabilities(result)
            "getLibraryState" -> getLibraryState(call.argument("spotifyUri"), result)
            "getImage" -> getImage(call.argument("imageUri"), call.argument("imageDimension"), result)
            else -> result.notImplemented()
        }
    }

    private inline fun withAppRemote(result: Result, block: (SpotifyAppRemote) -> Unit) {
        val remote = spotifyAppRemote
        if (remote != null && remote.isConnected) {
            block(remote)
        } else {
            result.error("spotifyAppRemoteNull", "spotifyAppRemote is null or disconnected", "")
        }
    }

    private fun connectToSpotify(clientId: String?, redirectUrl: String?, result: Result) {
        if (clientId.isNullOrBlank() || redirectUrl.isNullOrBlank()) {
            result.error("errorConnecting", "client id or redirectUrl are not set or have invalid format", "")
            return
        }
        val connectionParams = ConnectionParams.Builder(clientId)
            .setRedirectUri(redirectUrl)
            .showAuthView(true)
            .build()
        SpotifyAppRemote.disconnect(spotifyAppRemote)
        var initiallyConnected = false
        SpotifyAppRemote.connect(
            applicationContext,
            connectionParams,
            object : ConnectionListener {
                override fun onConnected(appRemote: SpotifyAppRemote) {
                    spotifyAppRemote = appRemote

                    playerContextChannel?.setStreamHandler(PlayerContextChannel(appRemote.playerApi))
                    playerStateChannel?.setStreamHandler(PlayerStateChannel(appRemote.playerApi))
                    capabilitiesChannel?.setStreamHandler(CapabilitiesChannel(appRemote.userApi))
                    userStatusChannel?.setStreamHandler(UserStatusChannel(appRemote.userApi))
                    initiallyConnected = true

                    Log.i(loggingTag, "App Remote successfully connected")
                    connStatusEventChannel(ConnectionStatusChannel.ConnectionEvent(true, "Successfully connected to Spotify.", null, null))
                    result.success(true)
                }

                override fun onFailure(throwable: Throwable) {
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
                    Log.e(loggingTag, errorMessage)
                    if (initiallyConnected) {
                        connStatusEventChannel(ConnectionStatusChannel.ConnectionEvent(connected, errorMessage, errorCode, errorDetails))
                    } else {
                        result.error(errorCode, errorMessage, errorDetails)
                    }
                }
            }
        )
    }

    private fun getAccessToken(clientId: String?, redirectUrl: String?, scope: String?, result: Result) {
        val activity = applicationActivity
        if (activity == null) {
            result.error("errorConnecting", "getAccessToken needs a foreground activity", "")
            return
        }
        if (clientId.isNullOrBlank() || redirectUrl.isNullOrBlank()) {
            result.error("errorConnecting", "client id or redirectUrl are not set or have invalid format", "")
            return
        }
        val scopeArray = scope?.split(",")?.toTypedArray()
        "connectToSpotify".checkAndSetPendingOperation(result)

        val builder = AuthorizationRequest.Builder(clientId, AuthorizationResponse.Type.TOKEN, redirectUrl)
        builder.setScopes(scopeArray)
        val request = builder.build()
        AuthorizationClient.openLoginActivity(activity, requestCodeAuthentication, request)
    }

    private fun disconnectFromSpotify(result: Result) {
        val remote = spotifyAppRemote
        if (remote != null && remote.isConnected) {
            SpotifyAppRemote.disconnect(remote)
            connStatusEventChannel(ConnectionStatusChannel.ConnectionEvent(false, "Successfully disconnected from Spotify.", null, null))
            result.success(true)
        } else if (remote != null && !remote.isConnected) {
            result.error("errorDisconnecting", "could not disconnect spotify remote", "you are not connected, no need to disconnect")
        } else {
            result.error("errorDisconnecting", "could not disconnect spotify remote", "spotifyAppRemote is not set")
        }
    }

    private fun switchToLocalDevice(result: Result) {
        withAppRemote(result) { remote ->
            remote.connectApi.connectSwitchToLocalDevice()
                .setResultCallback { result.success(true) }
                .setErrorCallback { throwable -> result.error("errorConnectSwitchToLocalDevice", "error when switching to local device", throwable.toString()) }
        }
    }

    private fun getCrossfadeState(result: Result) {
        withAppRemote(result) { remote ->
            remote.playerApi.crossfadeState
                .setResultCallback { state -> result.success(Gson().toJson(state)) }
                .setErrorCallback { throwable -> result.error("crossfadeStateError", "error when getting current crossfade setting", throwable.toString()) }
        }
    }

    private fun getPlayerState(result: Result) {
        withAppRemote(result) { remote ->
            remote.playerApi.playerState
                .setResultCallback { state -> result.success(Gson().toJson(state)) }
                .setErrorCallback { throwable -> result.error("PlayerStateError", "error when getting current player state", throwable.toString()) }
        }
    }

    private fun play(spotifyUri: String?, result: Result) {
        if (spotifyUri.isNullOrBlank()) {
            result.error("playError", "spotifyUri has invalid format or is not set", "")
            return
        }
        withAppRemote(result) { remote ->
            remote.playerApi.play(spotifyUri)
                .setResultCallback { result.success(true) }
                .setErrorCallback { throwable -> result.error("playError", "error when playing uri: $spotifyUri", throwable.toString()) }
        }
    }

    private fun pause(result: Result) {
        withAppRemote(result) { remote ->
            remote.playerApi.pause()
                .setResultCallback { result.success(true) }
                .setErrorCallback { throwable -> result.error("pauseError", "error when pausing", throwable.toString()) }
        }
    }

    private fun queue(spotifyUri: String?, result: Result) {
        if (spotifyUri.isNullOrBlank()) {
            result.error("queueError", "spotifyUri has invalid format or is not set", "")
            return
        }
        withAppRemote(result) { remote ->
            remote.playerApi.queue(spotifyUri)
                .setResultCallback { result.success(true) }
                .setErrorCallback { throwable -> result.error("queueError", "error when adding uri to queue", throwable.toString()) }
        }
    }

    private fun resume(result: Result) {
        withAppRemote(result) { remote ->
            remote.playerApi.resume()
                .setResultCallback { result.success(true) }
                .setErrorCallback { throwable -> result.error("resumeError", "error when resuming", throwable.toString()) }
        }
    }

    private fun seekTo(milliseconds: Int?, result: Result) {
        val castedMilliseconds = milliseconds?.toLong()
        if (castedMilliseconds == null) {
            result.error("seekToError", "positionedMilliseconds has invalid format or is not set", "")
            return
        }
        withAppRemote(result) { remote ->
            remote.playerApi.seekTo(castedMilliseconds)
                .setResultCallback { result.success(true) }
                .setErrorCallback { throwable -> result.error("seekToError", "error when seeking", throwable.toString()) }
        }
    }

    private fun seekToRelativePosition(milliseconds: Int?, result: Result) {
        val castedMilliseconds = milliseconds?.toLong()
        if (castedMilliseconds == null) {
            result.error("seekToError", "relativeMilliseconds has invalid format or is not set", "")
            return
        }
        withAppRemote(result) { remote ->
            remote.playerApi.seekToRelativePosition(castedMilliseconds)
                .setResultCallback { result.success(true) }
                .setErrorCallback { throwable -> result.error("seekToError", "error when seeking relative position", throwable.toString()) }
        }
    }

    private fun setPodcastPlaybackSpeed(speed: Int?, result: Result) {
        if (speed == null) {
            result.error("podcastPlaybackSpeedError", "podcastPlaybackSpeed has invalid format or is not set", "")
            return
        }
        val podcastPlaybackSpeed = PlaybackSpeed.PodcastPlaybackSpeed.values().firstOrNull { it.value == speed }
        withAppRemote(result) { remote ->
            remote.playerApi.setPodcastPlaybackSpeed(podcastPlaybackSpeed)
                .setResultCallback { result.success(true) }
                .setErrorCallback { throwable -> result.error("podcastPlaybackSpeedError", "error setting podcast playback speed", throwable.toString()) }
        }
    }

    private fun skipNext(result: Result) {
        withAppRemote(result) { remote ->
            remote.playerApi.skipNext()
                .setResultCallback { result.success(true) }
                .setErrorCallback { throwable -> result.error("skipNextError", "error skipping to next track", throwable.toString()) }
        }
    }

    private fun skipPrevious(result: Result) {
        withAppRemote(result) { remote ->
            remote.playerApi.skipPrevious()
                .setResultCallback { result.success(true) }
                .setErrorCallback { throwable -> result.error("skipPreviousError", "error skipping to previous track", throwable.toString()) }
        }
    }

    private fun skipToIndex(spotifyUri: String?, trackIndex: Int?, result: Result) {
        if (spotifyUri.isNullOrBlank() || trackIndex == null) {
            result.error("skipToIndexError", "spotifyUri or trackIndex is invalid", "")
            return
        }
        withAppRemote(result) { remote ->
            remote.playerApi.skipToIndex(spotifyUri, trackIndex)
                .setResultCallback { result.success(true) }
                .setErrorCallback { throwable -> result.error("skipToIndexError", "error skipping to index", throwable.toString()) }
        }
    }

    private fun toggleShuffle(result: Result) {
        withAppRemote(result) { remote ->
            remote.playerApi.toggleShuffle()
                .setResultCallback { result.success(true) }
                .setErrorCallback { throwable -> result.error("toggleShuffleError", "error toggling shuffle", throwable.toString()) }
        }
    }

    private fun setShuffle(shuffle: Boolean?, result: Result) {
        if (shuffle == null) {
            result.error("setShuffleError", "shuffle is null", "")
            return
        }
        withAppRemote(result) { remote ->
            remote.playerApi.setShuffle(shuffle)
                .setResultCallback { result.success(true) }
                .setErrorCallback { throwable -> result.error("setShuffleError", "error setting shuffle", throwable.toString()) }
        }
    }

    private fun toggleRepeat(result: Result) {
        withAppRemote(result) { remote ->
            remote.playerApi.toggleRepeat()
                .setResultCallback { result.success(true) }
                .setErrorCallback { throwable -> result.error("toggleRepeatError", "error toggling repeat", throwable.toString()) }
        }
    }

    private fun setRepeatMode(repeatMode: Int?, result: Result) {
        if (repeatMode == null) {
            result.error("setRepeatModeError", "repeatMode is null", "")
            return
        }
        withAppRemote(result) { remote ->
            remote.playerApi.setRepeat(repeatMode)
                .setResultCallback { result.success(true) }
                .setErrorCallback { throwable -> result.error("setRepeatModeError", "error setting repeat mode", throwable.toString()) }
        }
    }

    private fun addToUserLibrary(spotifyUri: String?, result: Result) {
        if (spotifyUri.isNullOrBlank()) {
            result.error("addToLibraryError", "spotifyUri has invalid format", "")
            return
        }
        withAppRemote(result) { remote ->
            remote.userApi.addToLibrary(spotifyUri)
                .setResultCallback { result.success(true) }
                .setErrorCallback { throwable -> result.error("addToLibraryError", "error adding to user library", throwable.toString()) }
        }
    }

    private fun removeFromUserLibrary(spotifyUri: String?, result: Result) {
        if (spotifyUri.isNullOrBlank()) {
            result.error("removeFromLibraryError", "spotifyUri has invalid format", "")
            return
        }
        withAppRemote(result) { remote ->
            remote.userApi.removeFromLibrary(spotifyUri)
                .setResultCallback { result.success(true) }
                .setErrorCallback { throwable -> result.error("removeFromLibraryError", "error removing from user library", throwable.toString()) }
        }
    }

    private fun getCapabilities(result: Result) {
        withAppRemote(result) { remote ->
            remote.userApi.capabilities
                .setResultCallback { capabilities -> result.success(Gson().toJson(capabilities)) }
                .setErrorCallback { throwable -> result.error("getCapabilitiesError", "error getting capabilities", throwable.toString()) }
        }
    }

    private fun getLibraryState(spotifyUri: String?, result: Result) {
        if (spotifyUri.isNullOrBlank()) {
            result.error("getLibraryStateError", "spotifyUri is invalid", "")
            return
        }
        withAppRemote(result) { remote ->
            remote.userApi.getLibraryState(spotifyUri)
                .setResultCallback { state -> result.success(Gson().toJson(state)) }
                .setErrorCallback { throwable -> result.error("getLibraryStateError", "error getting library state", throwable.toString()) }
        }
    }

    private fun getImage(imageUri: String?, dimension: Int?, result: Result) {
        if (imageUri == null || dimension == null) {
            result.error("errorImageUri", "imageUri or imageDimension is null", "")
            return
        }
        val targetDimension = Dimension.values().firstOrNull { it.value == dimension }
        if (targetDimension == null) {
            result.error("errorImageDimensionUri", "imageDimension is invalid", "")
            return
        }
        withAppRemote(result) { remote ->
            remote.imagesApi.getImage(ImageUri(imageUri), targetDimension)
                .setResultCallback { bitmap ->
                    val stream = ByteArrayOutputStream()
                    bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
                    result.success(stream.toByteArray())
                }
                .setErrorCallback { throwable -> result.error("errorGetImage", "error getting image", throwable.toString()) }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (pendingOperation == null) {
            return false
        }
        return when (requestCode) {
            requestCodeAuthentication -> {
                authFlow(resultCode, data)
                true
            }
            else -> false
        }
    }

    private fun authFlow(resultCode: Int, data: Intent?) {
        val response: AuthorizationResponse = AuthorizationClient.getResponse(resultCode, data)
        val op = pendingOperation ?: return
        pendingOperation = null

        when (response.type) {
            AuthorizationResponse.Type.TOKEN -> op.result.success(response.accessToken)
            AuthorizationResponse.Type.ERROR -> op.result.error("authenticationTokenError", "Authentication went wrong", response.error)
            else -> op.result.notImplemented()
        }
    }

    private fun String.checkAndSetPendingOperation(result: Result) {
        check(pendingOperation == null) {
            "Concurrent operations detected: " + pendingOperation?.method.toString() + ", " + this
        }
        pendingOperation = PendingOperation(this, result)
    }
}

private class PendingOperation internal constructor(val method: String, val result: Result)
