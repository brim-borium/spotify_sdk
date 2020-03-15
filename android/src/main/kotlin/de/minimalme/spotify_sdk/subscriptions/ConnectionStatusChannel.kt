package de.minimalme.spotify_sdk.subscriptions

import com.google.gson.Gson
import io.flutter.plugin.common.EventChannel
import kotlinx.event.SetEvent

class ConnectionStatusChannel(private val connStatusStream: SetEvent<ConnectionEvent>) : EventChannel.StreamHandler {

    data class ConnectionEvent(val connected: Boolean, val message: String, val errorCode: String?, val errorDetails: Any?)

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        connStatusStream += { event ->
            // not error
            events?.success(Gson().toJson(event))
        }
    }

    override fun onCancel(arguments: Any?) {
    }
}