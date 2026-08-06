import Flutter
import SpotifyiOS

public class LibraryHandler: NSObject {
    private unowned let remoteManager: RemoteManager

    public init(remoteManager: RemoteManager) {
        self.remoteManager = remoteManager
        super.init()
    }

    private var defaultCallback: (_ result: @escaping FlutterResult) -> SPTAppRemoteCallback {
        return { result in
            return { _, error in
                if let error = error {
                    result(SpotifyErrorMapper.makeError(code: "UserAPI Error", message: error.localizedDescription))
                } else {
                    result(true)
                }
            }
        }
    }

    public func addToLibrary(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let appRemote = remoteManager.appRemote else {
            result(SpotifyErrorMapper.notConnectedError())
            return
        }
        guard let swiftArguments = call.arguments as? [String: Any],
              let uri = swiftArguments[SpotifySdkConstants.paramSpotifyUri] as? String else {
            result(SpotifyErrorMapper.argumentError("No URI was specified"))
            return
        }
        appRemote.userAPI?.addItemToLibrary(withURI: uri, callback: defaultCallback(result))
    }

    public func removeFromLibrary(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let appRemote = remoteManager.appRemote else {
            result(SpotifyErrorMapper.notConnectedError())
            return
        }
        guard let swiftArguments = call.arguments as? [String: Any],
              let uri = swiftArguments[SpotifySdkConstants.paramSpotifyUri] as? String else {
            result(SpotifyErrorMapper.argumentError("No URI was specified"))
            return
        }
        appRemote.userAPI?.removeItemFromLibrary(withURI: uri, callback: defaultCallback(result))
    }

    public func getCapabilities(result: @escaping FlutterResult) {
        guard let appRemote = remoteManager.appRemote else {
            result(SpotifyErrorMapper.notConnectedError())
            return
        }
        appRemote.userAPI?.fetchCapabilities(callback: { (capabilitiesResult, error) in
            guard error == nil else {
                result(SpotifyErrorMapper.makeError(code: "getCapabilitiesError", message: error?.localizedDescription ?? ""))
                return
            }
            guard let userCapabilities = capabilitiesResult as? SPTAppRemoteUserCapabilities else {
                result(SpotifyErrorMapper.makeError(code: "getCapabilitiesError", message: error?.localizedDescription ?? ""))
                return
            }
            result(State.userCapabilitiesDictionary(userCapabilities).json)
        })
    }

    public func getLibraryState(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let appRemote = remoteManager.appRemote else {
            result(SpotifyErrorMapper.notConnectedError())
            return
        }
        guard let swiftArguments = call.arguments as? [String: Any],
              let uri = swiftArguments[SpotifySdkConstants.paramSpotifyUri] as? String else {
            result(SpotifyErrorMapper.argumentError("No URI was specified"))
            return
        }
        appRemote.userAPI?.fetchLibraryState(forURI: uri, callback: { libraryStateResult, error in
            guard error == nil else {
                result(SpotifyErrorMapper.makeError(code: "fetchLibraryStateError", message: error?.localizedDescription ?? ""))
                return
            }
            guard let libraryState = libraryStateResult as? SPTAppRemoteLibraryState else {
                result(SpotifyErrorMapper.makeError(code: "fetchLibraryStateError", message: error?.localizedDescription ?? ""))
                return
            }
            result(State.libraryStateDictionary(libraryState).json)
        })
    }
}
