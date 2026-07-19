package de.minimalme.spotify_sdk.subscriptions

import com.google.gson.Gson
import com.spotify.android.appremote.api.PlayerApi
import io.flutter.plugin.common.EventChannel

class PlayerContextChannel(private val playerApi: PlayerApi) : EventChannel.StreamHandler {

    private val errorSubscribePlayerContext = "subscribePlayerContextError"
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        playerApi.subscribeToPlayerContext()
                .setEventCallback {
                    playerContext ->  events?.success(Gson().toJson(playerContext))
                }
                .setErrorCallback {
                    throwable -> events?.error(errorSubscribePlayerContext, "error when subscribing to the player context", throwable.toString())
                }
    }

    override fun onCancel(arguments: Any?) {
    }
}