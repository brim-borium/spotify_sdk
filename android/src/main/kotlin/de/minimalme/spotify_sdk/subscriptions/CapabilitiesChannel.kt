package de.minimalme.spotify_sdk.subscriptions

import com.google.gson.Gson
import com.spotify.android.appremote.api.PlayerApi
import com.spotify.android.appremote.api.UserApi
import io.flutter.plugin.common.EventChannel

class CapabilitiesChannel(private val userApi: UserApi) : EventChannel.StreamHandler {

    private val errorSubscribeCapabilities = "subscribeCapabilitiesError"
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        userApi.subscribeToCapabilities()
                .setEventCallback {
                    capabilities ->  events?.success(Gson().toJson(capabilities))
                }
                .setErrorCallback {
                    throwable -> events?.error(errorSubscribeCapabilities, "error when subscribing to the users capabilities", throwable.toString())
                }
    }

    override fun onCancel(arguments: Any?) {
    }
}