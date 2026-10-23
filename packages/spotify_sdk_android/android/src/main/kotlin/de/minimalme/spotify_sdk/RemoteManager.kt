package de.minimalme.spotify_sdk

import android.app.Activity
import android.content.Context
import com.spotify.android.appremote.api.SpotifyAppRemote
import de.minimalme.spotify_sdk.subscriptions.CapabilitiesChannel
import de.minimalme.spotify_sdk.subscriptions.ConnectionStatusChannel
import de.minimalme.spotify_sdk.subscriptions.PlayerContextChannel
import de.minimalme.spotify_sdk.subscriptions.PlayerStateChannel
import de.minimalme.spotify_sdk.subscriptions.UserStatusChannel
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.event.SetEvent
import kotlinx.event.event

class RemoteManager {

    var applicationContext: Context? = null
    var applicationActivity: Activity? = null
    var spotifyAppRemote: SpotifyAppRemote? = null

    var playerContextChannel: EventChannel? = null
    var playerStateChannel: EventChannel? = null
    var capabilitiesChannel: EventChannel? = null
    var userStatusChannel: EventChannel? = null
    var connectionStatusChannel: EventChannel? = null

    var connStatusEventChannel: SetEvent<ConnectionStatusChannel.ConnectionEvent> = event()
    val connectionStatusStreamHandler = ConnectionStatusChannel(connStatusEventChannel)
    val playerContextStreamHandler = PlayerContextChannel()
    val playerStateStreamHandler = PlayerStateChannel()
    val capabilitiesStreamHandler = CapabilitiesChannel()
    val userStatusStreamHandler = UserStatusChannel()

    var pendingOperation: PendingOperation? = null

    fun attachAppRemote(appRemote: SpotifyAppRemote) {
        spotifyAppRemote = appRemote
        playerContextStreamHandler.attachPlayerApi(appRemote.playerApi)
        playerStateStreamHandler.attachPlayerApi(appRemote.playerApi)
        capabilitiesStreamHandler.attachUserApi(appRemote.userApi)
        userStatusStreamHandler.attachUserApi(appRemote.userApi)
    }

    fun detachAppRemote() {
        playerContextStreamHandler.attachPlayerApi(null)
        playerStateStreamHandler.attachPlayerApi(null)
        capabilitiesStreamHandler.attachUserApi(null)
        userStatusStreamHandler.attachUserApi(null)
        spotifyAppRemote = null
    }

    inline fun withAppRemote(result: Result, block: (SpotifyAppRemote) -> Unit) {
        val remote = spotifyAppRemote
        if (remote != null && remote.isConnected) {
            block(remote)
        } else {
            result.error(SpotifySdkConstants.ERROR_SPOTIFY_APP_REMOTE_NULL, "spotifyAppRemote is null or disconnected", "")
        }
    }

    fun String.checkAndSetPendingOperation(result: Result) {
        if (pendingOperation == null) {
            pendingOperation = PendingOperation(this, result)
        } else {
            result.error(SpotifySdkConstants.ERROR_PENDING_OPERATION, "Operation $this cannot be started because another operation is pending: ${pendingOperation?.methodName}", "")
        }
    }
}
