package de.minimalme.spotify_sdk.subscriptions

import com.spotify.android.appremote.api.PlayerApi
import com.spotify.protocol.client.Subscription
import com.spotify.protocol.types.PlayerState

class PlayerStateChannel(playerApi: PlayerApi? = null) : BaseSubscriptionChannel<PlayerApi, PlayerState>(
    api = playerApi,
    errorCode = "subscribePlayerStateError",
    errorMessage = "error when subscribing to the player state",
) {
    override fun createSubscription(api: PlayerApi): Subscription<PlayerState> =
        api.subscribeToPlayerState()
}
