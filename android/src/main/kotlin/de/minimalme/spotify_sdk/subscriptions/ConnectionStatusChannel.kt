package de.minimalme.spotify_sdk.subscriptions

import android.util.Log
import com.google.gson.Gson
import com.google.gson.annotations.SerializedName
import io.flutter.plugin.common.EventChannel
import kotlinx.event.SetEvent

class ConnectionStatusChannel(private val connStatusStream: SetEvent<ConnectionEvent>) : EventChannel.StreamHandler {

    data class ConnectionEvent(
            @SerializedName("connected") val connected: Boolean,
            @SerializedName("message" )val message: String,
            @SerializedName("errorCode") val errorCode: String?,
            @SerializedName("errorDetails") val errorDetails: Any?
            )

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        connStatusStream += { event ->
            // not error
            events?.success(Gson().toJson(event))
        }
    }

    override fun onCancel(arguments: Any?) {
    }
}