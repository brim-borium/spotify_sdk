package de.minimalme.spotify_sdk.handlers

import android.graphics.Bitmap
import com.spotify.protocol.types.Image.Dimension
import com.spotify.protocol.types.ImageUri
import de.minimalme.spotify_sdk.RemoteManager
import io.flutter.plugin.common.MethodChannel.Result
import java.io.ByteArrayOutputStream

class ImageHandler(private val remoteManager: RemoteManager) {

    fun getImage(imageUri: String?, imageDimension: Int?, result: Result) {
        if (imageUri.isNullOrBlank()) {
            result.error(SpotifySdkConstants.ERROR_GET_IMAGE, "imageUri is not set", "")
            return
        }
        val dimension = when (imageDimension) {
            1 -> Dimension.LARGE
            2 -> Dimension.MEDIUM
            3 -> Dimension.SMALL
            4 -> Dimension.THUMBNAIL
            else -> Dimension.LARGE
        }
        remoteManager.withAppRemote(result) { remote ->
            remote.imagesApi.getImage(ImageUri(imageUri), dimension)
                .setResultCallback { bitmap ->
                    val stream = ByteArrayOutputStream()
                    bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
                    result.success(stream.toByteArray())
                }
                .setErrorCallback { throwable -> result.error(SpotifySdkConstants.ERROR_GET_IMAGE, "error when getting image: $imageUri", throwable.toString()) }
        }
    }
}
