package de.minimalme.spotify_sdk

import com.spotify.android.appremote.api.SpotifyAppRemote
import com.spotify.protocol.types.Image.Dimension
import com.spotify.protocol.types.ImageUri
import io.flutter.plugin.common.MethodChannel

class SpotifyImagesApi(spotifyAppRemote: SpotifyAppRemote?, result: MethodChannel.Result) : BaseSpotifyApi(spotifyAppRemote, result) {

    private val errorGetImage = "errorGetImage"
    private val errorImageUri = "errorImageUri"
    private val errorImageDimension = "errorImageDimensionUri"

    private val imagesApi = spotifyAppRemote?.imagesApi

    internal fun getImage(imageUri: ImageUri?, dimension: Int?) {
        if (imagesApi != null && imageUri != null && dimension != null) {
            var imageSize = Dimension.values()[dimension]
            imagesApi.getImage(imageUri, imageSize)
                    .setResultCallback { bitmap -> result.success(bitmap) }
                    .setErrorCallback { throwable -> result.error(errorGetImage, "error when getting the image", throwable.message) }
        } else if (imageUri == null) {
            result.error(errorImageUri, "imageUri has invalid format or is not set", "")
        } else if (dimension == null) {
            result.error(errorImageDimension, "imageDimension has invalid format or is not set", "")
        } else {
            spotifyRemoteAppNotSetError()
        }
    }
}