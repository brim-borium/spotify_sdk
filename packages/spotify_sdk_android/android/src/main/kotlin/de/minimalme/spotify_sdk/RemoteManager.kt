package de.minimalme.spotify_sdk

import android.app.Activity
import android.content.Context
import com.spotify.android.appremote.api.SpotifyAppRemote
import de.minimalme.spotify_sdk.subscriptions.ConnectionStatusChannel
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
    var pendingOperation: PendingOperation? = null

    inline fun withAppRemote(result: Result, block: (SpotifyAppRemote) -> Unit) {
        val remote = spotifyAppRemote
        if (remote != null && remote.isConnected) {
            block(remote)
        } else {
            result.error("spotifyAppRemoteNull", "spotifyAppRemote is null or disconnected", "")
        }
    }

    fun String.checkAndSetPendingOperation(result: Result) {
        if (pendingOperation == null) {
            pendingOperation = PendingOperation(this, result)
        } else {
            result.error("errorPendingOperation", "Operation $this cannot be started because another operation is pending: ${pendingOperation?.methodName}", "")
        }
    }
}
