package de.minimalme.spotify_sdk.subscriptions

import com.google.gson.Gson
import com.google.gson.annotations.SerializedName
import io.flutter.plugin.common.EventChannel
import kotlinx.event.SetEvent

class ConnectionStatusChannel(connStatusStream: SetEvent<ConnectionEvent>) : EventChannel.StreamHandler {

    data class ConnectionEvent(
        @SerializedName("connected") val connected: Boolean,
        @SerializedName("message") val message: String,
        @SerializedName("errorCode") val errorCode: String?,
        @SerializedName("errorDetails") val errorDetails: Any?
    )

    private var eventSink: EventChannel.EventSink? = null

    init {
        connStatusStream += { event ->
            eventSink?.success(Gson().toJson(event))
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }
}
