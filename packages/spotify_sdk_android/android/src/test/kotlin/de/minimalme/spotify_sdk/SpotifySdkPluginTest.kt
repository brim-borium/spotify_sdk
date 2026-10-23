package de.minimalme.spotify_sdk

import com.spotify.protocol.client.ErrorCallback
import com.spotify.protocol.client.PendingResult
import com.spotify.protocol.client.Result
import com.spotify.protocol.client.Subscription
import de.minimalme.spotify_sdk.subscriptions.BaseSubscriptionChannel
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.StandardMethodCodec
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertTrue
import org.junit.Test
import java.nio.ByteBuffer
import java.util.concurrent.TimeUnit

class SpotifySdkPluginTest {

    private class FakeBinaryMessenger : BinaryMessenger {
        val handlers = mutableMapOf<String, BinaryMessenger.BinaryMessageHandler>()

        override fun send(channel: String, message: ByteBuffer?) {
            send(channel, message, null)
        }

        override fun send(
            channel: String,
            message: ByteBuffer?,
            callback: BinaryMessenger.BinaryReply?
        ) {
            val handler = handlers[channel]
            if (handler == null) {
                callback?.reply(null)
            } else {
                handler.onMessage(message) { reply ->
                    callback?.reply(reply)
                }
            }
        }

        override fun setMessageHandler(
            channel: String,
            handler: BinaryMessenger.BinaryMessageHandler?
        ) {
            if (handler == null) {
                handlers.remove(channel)
            } else {
                handlers[channel] = handler
            }
        }
    }

    @Test
    fun eventChannelsAcceptListenBeforeSpotifyConnected() {
        val messenger = FakeBinaryMessenger()
        val plugin = SpotifySdkPlugin()

        plugin.registerChannels(messenger, null)

        val channels = listOf(
            SpotifySdkConstants.CHANNEL_CONNECTION_STATUS,
            SpotifySdkConstants.CHANNEL_PLAYER_STATE,
            SpotifySdkConstants.CHANNEL_PLAYER_CONTEXT,
            SpotifySdkConstants.CHANNEL_CAPABILITIES,
            SpotifySdkConstants.CHANNEL_USER_STATUS,
        )

        val listenCall = StandardMethodCodec.INSTANCE.encodeMethodCall(MethodCall("listen", null))

        for (channel in channels) {
            var replyBytes: ByteBuffer? = null
            var replied = false
            listenCall.rewind()
            messenger.send(channel, listenCall) { reply ->
                replied = true
                replyBytes = reply
            }
            assertTrue("Expected reply on channel $channel", replied)
            // When no StreamHandler is registered on EventChannel, BinaryMessenger replies with null,
            // which Flutter's MethodChannel decodes as MissingPluginException!
            assertNotNull(
                "MissingPluginException: No implementation found for method listen on channel $channel",
                replyBytes
            )
        }
    }

    private class FakeSubscription : Subscription<Map<String, String>>(null, null) {
        var cancelled = false
        var eventCallback: EventCallback<Map<String, String>>? = null

        override fun cancel() {
            cancelled = true
        }

        override fun setEventCallback(callback: EventCallback<Map<String, String>>?): Subscription<Map<String, String>> {
            eventCallback = callback
            return this
        }

        override fun setErrorCallback(callback: ErrorCallback?): PendingResult<Map<String, String>> = this
    }

    @Test
    fun baseSubscriptionChannelSubscribesOnAttachAndCancelsOnDetach() {
        var latestSub: FakeSubscription? = null
        val handler = object : BaseSubscriptionChannel<String, Map<String, String>>(
            errorCode = "testError",
            errorMessage = "test message",
        ) {
            override fun createSubscription(api: String): Subscription<Map<String, String>> {
                return FakeSubscription().also { latestSub = it }
            }
        }

        val emittedEvents = mutableListOf<Any?>()
        val sink = object : EventChannel.EventSink {
            override fun success(event: Any?) {
                emittedEvents.add(event)
            }
            override fun error(errorCode: String?, errorMessage: String?, errorDetails: Any?) {}
            override fun endOfStream() {}
        }

        // Listen before API is attached
        handler.onListen(null, sink)
        assertEquals(null, latestSub)

        // Attach API -> triggers subscription and forwards events
        handler.attachApi("connected_api")
        val sub = latestSub
        assertNotNull(sub)
        assertFalse(sub!!.cancelled)

        sub.eventCallback?.onEvent(mapOf("state" to "playing"))
        assertEquals(listOf("{\"state\":\"playing\"}"), emittedEvents)

        // Detach API -> cancels active subscription
        handler.attachApi(null)
        assertTrue(sub.cancelled)
    }
}
