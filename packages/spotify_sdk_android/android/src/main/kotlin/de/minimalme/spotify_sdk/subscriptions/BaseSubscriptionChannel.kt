package de.minimalme.spotify_sdk.subscriptions

import com.google.gson.Gson
import com.spotify.protocol.client.Subscription
import io.flutter.plugin.common.EventChannel

abstract class BaseSubscriptionChannel<Api : Any, T : Any>(
    private var api: Api? = null,
    private val errorCode: String,
    private val errorMessage: String,
) : EventChannel.StreamHandler {

    private val gson = Gson()
    private var eventSink: EventChannel.EventSink? = null
    private var subscription: Subscription<T>? = null

    protected abstract fun createSubscription(api: Api): Subscription<T>

    fun attachApi(newApi: Api?) {
        api = newApi
        if (newApi == null) {
            cancelSubscription()
        } else {
            val sink = eventSink
            if (sink != null) {
                subscribe(newApi, sink)
            }
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
        val currentApi = api
        if (currentApi != null && events != null) {
            subscribe(currentApi, events)
        }
    }

    override fun onCancel(arguments: Any?) {
        cancelSubscription()
        eventSink = null
    }

    private fun subscribe(currentApi: Api, events: EventChannel.EventSink) {
        cancelSubscription()
        val sub = createSubscription(currentApi)
        sub.setEventCallback { event ->
            events.success(gson.toJson(event))
        }
        sub.setErrorCallback { throwable ->
            events.error(errorCode, errorMessage, throwable.toString())
        }
        subscription = sub
    }

    private fun cancelSubscription() {
        subscription?.cancel()
        subscription = null
    }
}
