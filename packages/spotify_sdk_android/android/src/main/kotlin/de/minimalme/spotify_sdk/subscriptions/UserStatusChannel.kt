package de.minimalme.spotify_sdk.subscriptions

import com.google.gson.Gson
import com.spotify.android.appremote.api.PlayerApi
import com.spotify.android.appremote.api.UserApi
import io.flutter.plugin.common.EventChannel

class UserStatusChannel(private val userApi: UserApi) : EventChannel.StreamHandler {

    private val errorSubscribeUserStatus = "subscribeUserStatusError"
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        userApi.subscribeToUserStatus()
                .setEventCallback {
                    userStatus ->  events?.success(Gson().toJson(userStatus))
                }
                .setErrorCallback {
                    throwable -> events?.error(errorSubscribeUserStatus, "error when subscribing to the users status", throwable.toString())
                }
    }
    
    override fun onCancel(arguments: Any?) {
    }
}