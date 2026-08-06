import Flutter
import SpotifyiOS

public class ImageHandler: NSObject {
    private unowned let remoteManager: RemoteManager

    public init(remoteManager: RemoteManager) {
        self.remoteManager = remoteManager
        super.init()
    }

    private class ImageObject: NSObject, SPTAppRemoteImageRepresentable {
        var imageIdentifier: String = ""
    }

    public func getImage(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let appRemote = remoteManager.appRemote else {
            result(SpotifyErrorMapper.notConnectedError())
            return
        }
        guard let swiftArguments = call.arguments as? [String: Any],
              let paramImageUri = swiftArguments[SpotifySdkConstants.paramImageUri] as? String,
              let paramImageDimension = swiftArguments[SpotifySdkConstants.paramImageDimension] as? Int else {
            result(SpotifyErrorMapper.argumentError("One or more image arguments are missing"))
            return
        }

        let imageObject = ImageObject()
        imageObject.imageIdentifier = paramImageUri
        appRemote.imageAPI?.fetchImage(forItem: imageObject, with: CGSize(width: paramImageDimension, height: paramImageDimension), callback: { (image, error) in
            guard error == nil else {
                result(SpotifyErrorMapper.makeError(code: "ImageAPI Error", message: error?.localizedDescription ?? ""))
                return
            }
            guard let imageData = (image as? UIImage)?.pngData() else {
                result(SpotifyErrorMapper.makeError(code: "ImageAPI Error", message: "Image is empty"))
                return
            }
            result(imageData)
        })
    }
}
