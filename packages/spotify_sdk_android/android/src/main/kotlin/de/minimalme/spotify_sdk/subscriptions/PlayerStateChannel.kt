package de.minimalme.spotify_sdk.subscriptions

import com.google.gson.Gson
import com.spotify.android.appremote.api.PlayerApi
import io.flutter.plugin.common.EventChannel

class PlayerStateChannel(private val playerApi: PlayerApi) : EventChannel.StreamHandler {

    private val errorSubscribePlayerState = "subscribePlayerStateError"
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        playerApi.subscribeToPlayerState()
                .setEventCallback {
                    playerState ->  events?.success(Gson().toJson(playerState))
                }
                .setErrorCallback {
                    throwable -> events?.error(errorSubscribePlayerState, "error when subscribing to the player state", throwable.toString())
                }
    }

    override fun onCancel(arguments: Any?) {
    }
}