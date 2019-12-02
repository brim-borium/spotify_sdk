package de.minimalme.spotify_sdk

import android.content.Intent
import com.spotify.android.appremote.api.ConnectionParams
import com.spotify.android.appremote.api.Connector.ConnectionListener
import com.spotify.android.appremote.api.SpotifyAppRemote
import com.spotify.sdk.android.authentication.AuthenticationClient
import com.spotify.sdk.android.authentication.AuthenticationRequest
import com.spotify.sdk.android.authentication.AuthenticationResponse
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.common.PluginRegistry.Registrar


class SpotifySdkPlugin(private val registrar: Registrar) : MethodCallHandler, EventChannel.StreamHandler, PluginRegistry.ActivityResultListener {

    companion object {

        private const val CHANNEL_NAME = "spotify_sdk"
        private const val EVENT_CHANNEL_NAME = "events_spotify_sdk"

        @JvmStatic
        fun registerWith(registrar: Registrar) {

            val channel = MethodChannel(registrar.messenger(), CHANNEL_NAME)
            val eventChannel = EventChannel(registrar.messenger(), EVENT_CHANNEL_NAME)

            val spotifySdkPluginInstance = SpotifySdkPlugin(registrar)

            channel.setMethodCallHandler(spotifySdkPluginInstance)

            eventChannel.setStreamHandler(spotifySdkPluginInstance)

            registrar.addActivityResultListener(spotifySdkPluginInstance)

        }
    }

    //connecting
    private val methodConnectToSpotify = "connectToSpotify"
    private val methodGetAuthenticationToken = "getAuthenticationToken"
    private val methodLogoutFromSpotify = "logoutFromSpotify"

    //player api
    private val methodGetCrossfadeState = "getCrossfadeState"
    private val methodGetPlayerState = "getPlayerState"
    private val methodPlay = "play"
    private val methodPause = "pause"
    private val methodQueueTrack = "queueTrack"
    private val methodResume = "resume"
    private val methodSeekToRelativePosition = "seekToRelativePosition"
    private val methodSetPodcastPlaybackSpeed = "setPodcastPlaybackSpeed"
    private val methodSkipNext = "skipNext"
    private val methodSkipPrevious = "skipPrevious"
    private val methodSkipToIndex = "skipToIndex"
    private val methodSeekTo = "seekTo"
    private val methodToggleRepeat = "toggleRepeat"
    private val methodToggleShuffle = "toggleShuffle"

    //user api
    private val methodAddToLibrary = "addToLibrary"

    //images api
    private val methodGetImage = "getImage"

    private val paramClientId = "clientId"
    private val paramRedirectUrl = "redirectUrl"
    private val paramSpotifyUri = "spotifyUri"
    private val paramImageUri = "imageUri"
    private val paramImageDimension = "imageDimension"
    private val paramPositionedMilliseconds = "positionedMilliseconds"
    private val paramRelativeMilliseconds = "relativeMilliseconds"
    private val paramPodcastPlaybackSpeed = "podcastPlaybackSpeed"
    private val paramTrackIndex = "trackIndex"

    private val errorConnecting = "errorConnecting"

    private val requestCodeAuthentication = 1337
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
    private var spotifyImagesApi: SpotifyImagesApi? = null

    override fun onMethodCall(call: MethodCall, result: Result) {

        if (spotifyAppRemote != null) {
            spotifyPlayerApi = SpotifyPlayerApi(spotifyAppRemote, result)
            spotifyUserApi = SpotifyUserApi(spotifyAppRemote, result)
            spotifyImagesApi = SpotifyImagesApi(spotifyAppRemote, result)
        }

        when (call.method) {
            //connecting to spotify
            methodConnectToSpotify -> connectToSpotify(call.argument(paramClientId), call.argument(paramRedirectUrl), result)
            methodGetAuthenticationToken -> getAuthenticationToken(call.argument(paramClientId), call.argument(paramRedirectUrl), result)
            methodLogoutFromSpotify -> logoutFromSpotify(result)
            //player api calls
            methodGetCrossfadeState -> spotifyPlayerApi?.getCrossfadeState()
            methodGetPlayerState -> spotifyPlayerApi?.getPlayerState()
            methodPlay -> spotifyPlayerApi?.play(call.argument(paramSpotifyUri))
            methodPause -> spotifyPlayerApi?.pause()
            methodQueueTrack -> spotifyPlayerApi?.queue(call.argument(paramSpotifyUri))
            methodResume -> spotifyPlayerApi?.resume()
            methodSeekTo -> spotifyPlayerApi?.seekTo(call.argument(paramPositionedMilliseconds))
            methodSeekToRelativePosition -> spotifyPlayerApi?.seekToRelativePosition(call.argument(paramRelativeMilliseconds))
            methodSetPodcastPlaybackSpeed -> spotifyPlayerApi?.setPodcastPlaybackSpeed(call.argument(paramPodcastPlaybackSpeed))
            methodSkipNext -> spotifyPlayerApi?.skipNext()
            methodSkipPrevious -> spotifyPlayerApi?.skipPrevious()
            methodSkipToIndex -> spotifyPlayerApi?.skipToIndex(call.argument(paramSpotifyUri), call.argument(paramTrackIndex))
            methodToggleShuffle -> spotifyPlayerApi?.toggleShuffle()
            methodToggleRepeat -> spotifyPlayerApi?.toggleRepeat()
            //user api calls
            methodAddToLibrary -> spotifyUserApi?.addToUserLibrary(call.argument(paramSpotifyUri))
            //image api calls
            methodGetImage -> spotifyImagesApi?.getImage(call.argument(paramImageUri), call.argument(paramImageDimension))

            // method call is not implemented yet
            else -> result.notImplemented()
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        TODO("not implemented") //To change body of created functions use File | Settings | File Templates.
    }

    override fun onCancel(arguments: Any?) {
        TODO("not implemented") //To change body of created functions use File | Settings | File Templates.
    }

    //-- Method implementations
    private fun connectToSpotify(clientId: String?, redirectUrl: String?, result: Result) {
        var connectionParams = ConnectionParams.Builder(clientId)
                .setRedirectUri(redirectUrl)
                .showAuthView(true)
                .build()

        SpotifyAppRemote.connect(registrar.context(), connectionParams,
                object : ConnectionListener {
                    override fun onConnected(spotifyAppRemoteValue: SpotifyAppRemote) {
                        spotifyAppRemote = spotifyAppRemoteValue
                        result.success(true)
                    }

                    override fun onFailure(throwable: Throwable) {
                        result.error(throwable.cause.toString(), throwable.message, "")
                    }
                })
    }

    private fun getAuthenticationToken(clientId: String?, redirectUrl: String?, result: Result) {
        if (registrar.activity() == null) {
            throw IllegalStateException("connectToSpotify needs a foreground activity")
        }

        if (clientId.isNullOrBlank() || redirectUrl.isNullOrBlank()) {
            result.error(errorConnecting, "client id or redirectUrl are not set or have invalid format", "")
        } else {
            checkAndSetPendingOperation(methodConnectToSpotify, result)

            val builder = AuthenticationRequest.Builder(clientId, AuthenticationResponse.Type.TOKEN, redirectUrl)
            builder.setScopes(scope)
            val request = builder.build()

            AuthenticationClient.openLoginActivity(registrar.activity(), requestCodeAuthentication, request)
        }
    }

    private fun logoutFromSpotify(result: Result) {
        TODO("not implemented")
        result.notImplemented()
    }
    //--

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (pendingOperation == null) {
            return false
        }
        return when (requestCode) {
            requestCodeAuthentication -> {
                authFlow(resultCode, data)
                return true
            }
            else -> false
        }
    }

    private fun authFlow(resultCode: Int, data: Intent?) {

        val response: AuthenticationResponse = AuthenticationClient.getResponse(resultCode, data)
        val result = pendingOperation!!.result
        pendingOperation = null

        when (response.type) {
            AuthenticationResponse.Type.TOKEN -> {
                result.success(response.accessToken)
            }
            AuthenticationResponse.Type.ERROR -> result.error("authentication_error", "Authentication went wrong", response.error)
            else -> result.notImplemented()
        }
    }

    private fun checkAndSetPendingOperation(method: String, result: Result) {

        check(pendingOperation == null)
        {
            "Concurrent operations detected: " + pendingOperation?.method.toString() + ", " + method
        }
        pendingOperation = PendingOperation(method, result)
    }


}

private class PendingOperation internal constructor(val method: String, val result: Result)
