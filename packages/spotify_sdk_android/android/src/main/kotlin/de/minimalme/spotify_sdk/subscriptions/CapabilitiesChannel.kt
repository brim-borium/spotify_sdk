package de.minimalme.spotify_sdk.subscriptions

import com.google.gson.Gson
import com.spotify.android.appremote.api.UserApi
import com.spotify.protocol.client.Subscription
import com.spotify.protocol.types.Capabilities
import io.flutter.plugin.common.EventChannel

class CapabilitiesChannel(private var userApi: UserApi? = null) : EventChannel.StreamHandler {

    private val errorSubscribeCapabilities = "subscribeCapabilitiesError"
    private var eventSink: EventChannel.EventSink? = null
    private var subscription: Subscription<Capabilities>? = null

    fun attachUserApi(api: UserApi?) {
        userApi = api
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
        val api = userApi
        if (api != null && events != null) {
            subscribe(api, events)
        }
    }

    override fun onCancel(arguments: Any?) {
        cancelSubscription()
        eventSink = null
    }

    private fun subscribe(api: UserApi, events: EventChannel.EventSink) {
        cancelSubscription()
        val sub = api.subscribeToCapabilities()
        sub.setEventCallback { capabilities ->
            events.success(Gson().toJson(capabilities))
        }
        sub.setErrorCallback { throwable ->
            events.error(
                errorSubscribeCapabilities,
                "error when subscribing to the users capabilities",
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
