package de.minimalme.spotify_sdk.subscriptions

import com.spotify.android.appremote.api.UserApi
import com.spotify.protocol.client.Subscription
import com.spotify.protocol.types.UserStatus

class UserStatusChannel(userApi: UserApi? = null) : BaseSubscriptionChannel<UserApi, UserStatus>(
    api = userApi,
    errorCode = "subscribeUserStatusError",
    errorMessage = "error when subscribing to the users status",
) {
    override fun createSubscription(api: UserApi): Subscription<UserStatus> =
        api.subscribeToUserStatus()
}
