package de.minimalme.spotify_sdk.subscriptions

import com.google.gson.Gson
import com.spotify.android.appremote.api.PlayerApi
import com.spotify.protocol.client.Subscription
import com.spotify.protocol.types.PlayerState
import io.flutter.plugin.common.EventChannel

class PlayerStateChannel(private var playerApi: PlayerApi? = null) : EventChannel.StreamHandler {

    private val errorSubscribePlayerState = "subscribePlayerStateError"
    private var eventSink: EventChannel.EventSink? = null
    private var subscription: Subscription<PlayerState>? = null

    fun attachPlayerApi(api: PlayerApi?) {
        playerApi = api
        if (api == null) {
            cancelSubscription()
        } else {
            val sink = eventSink
            if (sink != null) {
                subscribe(api, sink)
            }
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
        val api = playerApi
        if (api != null && events != null) {
            subscribe(api, events)
        }
    }

    override fun onCancel(arguments: Any?) {
        cancelSubscription()
        eventSink = null
    }

    private fun subscribe(api: PlayerApi, events: EventChannel.EventSink) {
        cancelSubscription()
        val sub = api.subscribeToPlayerState()
        sub.setEventCallback { playerState ->
            events.success(Gson().toJson(playerState))
        }
        sub.setErrorCallback { throwable ->
            events.error(
                errorSubscribePlayerState,
                "error when subscribing to the player state",
                throwable.toString()
            )
        }
        subscription = sub
    }

    private fun cancelSubscription() {
        subscription?.cancel()
        subscription = null
    }
}
