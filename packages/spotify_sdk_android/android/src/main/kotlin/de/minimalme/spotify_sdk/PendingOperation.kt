package de.minimalme.spotify_sdk

import io.flutter.plugin.common.MethodChannel.Result

data class PendingOperation(
    val methodName: String,
    val result: Result
)
