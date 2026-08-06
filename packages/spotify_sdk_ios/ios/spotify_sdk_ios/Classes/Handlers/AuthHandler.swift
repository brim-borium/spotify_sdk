import Flutter
import SpotifyiOS

public class AuthHandler: NSObject {
    private unowned let remoteManager: RemoteManager

    public init(remoteManager: RemoteManager) {
        self.remoteManager = remoteManager
        super.init()
    }

    public func connectToSpotify(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let swiftArguments = call.arguments as? [String: Any],
              let clientID = swiftArguments[SpotifySdkConstants.paramClientId] as? String,
              !clientID.isEmpty else {
            result(SpotifyErrorMapper.argumentError("Client ID is not set"))
            return
        }

        guard let url = swiftArguments[SpotifySdkConstants.paramRedirectUrl] as? String,
              !url.isEmpty else {
            result(SpotifyErrorMapper.argumentError("Redirect URL is not set"))
            return
        }

        remoteManager.connectionStatusHandler?.connectionResult = result
        let accessToken: String? = swiftArguments[SpotifySdkConstants.paramAccessToken] as? String
        let spotifyUri: String = swiftArguments[SpotifySdkConstants.paramSpotifyUri] as? String ?? ""

        do {
            try connectToSpotifyInternal(clientId: clientID, redirectURL: url, accessToken: accessToken, spotifyUri: spotifyUri, asRadio: swiftArguments[SpotifySdkConstants.paramAsRadio] as? Bool, additionalScopes: swiftArguments[SpotifySdkConstants.scope] as? String)
        }
        catch SpotifyError.redirectURLInvalid {
            result(SpotifyErrorMapper.makeError(code: "errorConnecting", message: "Redirect URL is not set or has invalid format"))
        }
        catch {
            result(SpotifyErrorMapper.makeError(code: "CouldNotFindSpotifyApp", message: "The Spotify app is not installed on the device"))
        }
    }

    public func getAccessTokenOrSwapToken(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let swiftArguments = call.arguments as? [String: Any],
              let clientID = swiftArguments[SpotifySdkConstants.paramClientId] as? String,
              let url = swiftArguments[SpotifySdkConstants.paramRedirectUrl] as? String else {
            result(SpotifyErrorMapper.argumentError("One or more arguments are missing"))
            return
        }
        remoteManager.connectionStatusHandler?.tokenResult = result
        let spotifyUri: String = swiftArguments[SpotifySdkConstants.paramSpotifyUri] as? String ?? ""

        do {
            try connectToSpotifyInternal(clientId: clientID, redirectURL: url, spotifyUri: spotifyUri, asRadio: swiftArguments[SpotifySdkConstants.paramAsRadio] as? Bool, additionalScopes: swiftArguments[SpotifySdkConstants.scope] as? String)
        }
        catch SpotifyError.redirectURLInvalid {
            result(SpotifyErrorMapper.makeError(code: "errorConnecting", message: "Redirect URL is not set or has invalid format"))
        }
        catch {
            result(SpotifyErrorMapper.makeError(code: "CouldNotFindSpotifyApp", message: "The Spotify app is not installed on the device"))
        }
    }

    public func isSpotifyInstalled(result: @escaping FlutterResult) {
        result(UIApplication.shared.canOpenURL(URL(string: "spotify:")!))
    }

    public func disconnect(result: @escaping FlutterResult) {
        remoteManager.appRemote?.disconnect()
        result(true)
    }

    private func connectToSpotifyInternal(clientId: String, redirectURL: String, accessToken: String? = nil, spotifyUri: String = "", asRadio: Bool? = false, additionalScopes: String? = nil) throws {
        guard let redirectURL = URL(string: redirectURL) else {
            throw SpotifyError.redirectURLInvalid
        }

        let configuration = SPTConfiguration(clientID: clientId, redirectURL: redirectURL)
        let appRemote = SPTAppRemote(configuration: configuration, logLevel: .debug)
        remoteManager.appRemote = appRemote

        if remoteManager.playerStateHandler == nil {
            remoteManager.playerStateHandler = PlayerStateHandler()
        }
        if remoteManager.playerContextHandler == nil {
            remoteManager.playerContextHandler = PlayerContextHandler()
        }

        appRemote.delegate = remoteManager.connectionStatusHandler
        appRemote.connectionParameters.accessToken = accessToken

        if !SPTAppRemote.checkIfSpotifyAppIsInstalled() {
            throw SpotifyError.spotifyAppNotInstalled
        }

        let playURI = (spotifyUri.isEmpty) ? nil : spotifyUri
        appRemote.authorizeAndPlayURI(playURI, asRadio: asRadio ?? false, additionalScopes: additionalScopes)
    }
}
