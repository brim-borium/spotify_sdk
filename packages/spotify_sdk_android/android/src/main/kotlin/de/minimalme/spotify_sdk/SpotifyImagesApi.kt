package de.minimalme.spotify_sdk

import com.spotify.android.appremote.api.SpotifyAppRemote
import com.spotify.protocol.types.Image.Dimension
import com.spotify.protocol.types.ImageUri
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import android.graphics.Bitmap

class SpotifyImagesApi(spotifyAppRemote: SpotifyAppRemote?, result: MethodChannel.Result) : BaseSpotifyApi(spotifyAppRemote, result) {

    private val errorGetImage = "errorGetImage"
    private val errorImageUri = "errorImageUri"
    private val errorImageDimension = "errorImageDimensionUri"

    private val imagesApi = spotifyAppRemote?.imagesApi

    fun getImage(imageUri: String?, dimension: Int?) {
        if (imagesApi != null && imageUri != null && dimension != null) {
            imagesApi.getImage(ImageUri(imageUri), Dimension.values().first{it.value == dimension})
                    .setResultCallback { bitmap ->
                        val stream = ByteArrayOutputStream()
                        bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
                        result.success(stream.toByteArray())
                    }
                    .setErrorCallback { throwable -> result.error(errorGetImage, "error when getting the image", throwable.toString()) }
        } else if (imageUri == null) {
            result.error(errorImageUri, "imageUri has invalid format or is not set", "")
        } else if (dimension == null) {
            result.error(errorImageDimension, "imageDimension has invalid format or is not set", "")
        } else {
            spotifyRemoteAppNotSetError()
        }
    }
}