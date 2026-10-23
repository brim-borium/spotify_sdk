package de.minimalme.spotify_sdk

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.StandardMethodCodec
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertTrue
import org.junit.Test
import java.nio.ByteBuffer

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
}
