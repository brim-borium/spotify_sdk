package de.minimalme.spotify_sdk.subscriptions

import com.spotify.android.appremote.api.PlayerApi
import com.spotify.protocol.client.Subscription
import com.spotify.protocol.types.PlayerContext

class PlayerContextChannel(playerApi: PlayerApi? = null) : BaseSubscriptionChannel<PlayerApi, PlayerContext>(
    api = playerApi,
    errorCode = "subscribePlayerContextError",
    errorMessage = "error when subscribing to the player context",
) {
    override fun createSubscription(api: PlayerApi): Subscription<PlayerContext> =
        api.subscribeToPlayerContext()
}
