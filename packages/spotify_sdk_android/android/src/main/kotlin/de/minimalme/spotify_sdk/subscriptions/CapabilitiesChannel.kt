package de.minimalme.spotify_sdk.subscriptions

import com.spotify.android.appremote.api.UserApi
import com.spotify.protocol.client.Subscription
import com.spotify.protocol.types.Capabilities

class CapabilitiesChannel(userApi: UserApi? = null) : BaseSubscriptionChannel<UserApi, Capabilities>(
    api = userApi,
    errorCode = "subscribeCapabilitiesError",
    errorMessage = "error when subscribing to the users capabilities",
) {
    override fun createSubscription(api: UserApi): Subscription<Capabilities> =
        api.subscribeToCapabilities()
}
