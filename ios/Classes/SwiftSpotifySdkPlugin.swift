import Flutter
import SpotifyiOS

public class SwiftSpotifySdkPlugin: NSObject, FlutterPlugin {
    private static var instance = SwiftSpotifySdkPlugin()
    public static var shared: SwiftSpotifySdkPlugin { return instance }
    private var appRemote: SPTAppRemote?
    private var connectionStatusHandler: ConnectionStatusHandler?
    private var playerStateHandler: PlayerStateHandler?
    private var playerContextHandler: PlayerContextHandler?
    private static var playerStateChannel: FlutterEventChannel?
    private static var playerContextChannel: FlutterEventChannel?

    public var sessionManager: SPTSessionManager?
    private var authCallback: FlutterResult?

    public static func register(with registrar: FlutterPluginRegistrar) {
        guard playerStateChannel == nil else {
            // Avoid multiple plugin registations
            return
        }
        let spotifySDKChannel = FlutterMethodChannel(
            name: "spotify_sdk", binaryMessenger: registrar.messenger())
        let connectionStatusChannel = FlutterEventChannel(
            name: "connection_status_subscription", binaryMessenger: registrar.messenger())
        playerStateChannel = FlutterEventChannel(
            name: "player_state_subscription", binaryMessenger: registrar.messenger())
        playerContextChannel = FlutterEventChannel(
            name: "player_context_subscription", binaryMessenger: registrar.messenger())
        registrar.addApplicationDelegate(instance)
        registrar.addMethodCallDelegate(instance, channel: spotifySDKChannel)
        instance.connectionStatusHandler = ConnectionStatusHandler()
        connectionStatusChannel.setStreamHandler(instance.connectionStatusHandler)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        var defaultPlayAPICallback: SPTAppRemoteCallback {
            return { _, error in
                if let error = error {
                    result(
                        FlutterError(
                            code: "PlayerAPI Error", message: error.localizedDescription,
                            details: nil))
                } else {
                    result(true)
                }
            }
        }

        switch call.method {
        case SpotifySdkConstants.methodConnectToSpotify:
            guard let swiftArguments = call.arguments as? [String: Any],
                let clientID = swiftArguments[SpotifySdkConstants.paramClientId] as? String,
                !clientID.isEmpty
            else {
                result(
                    FlutterError(
                        code: "Argument Error", message: "Client ID is not set", details: nil))
                return
            }

            guard let url = swiftArguments[SpotifySdkConstants.paramRedirectUrl] as? String,
                !url.isEmpty
            else {
                result(
                    FlutterError(
                        code: "Argument Error", message: "Redirect URL is not set", details: nil))
                return
            }

            connectionStatusHandler?.connectionResult = result

            let accessToken: String? =
                swiftArguments[SpotifySdkConstants.paramAccessToken] as? String
            let spotifyUri: String =
                swiftArguments[SpotifySdkConstants.paramSpotifyUri] as? String ?? ""

            do {
                try connectToSpotify(
                    clientId: clientID, redirectURL: url, accessToken: accessToken,
                    spotifyUri: spotifyUri,
                    asRadio: swiftArguments[SpotifySdkConstants.paramAsRadio] as? Bool,
                    additionalScopes: swiftArguments[SpotifySdkConstants.scope] as? String)
            } catch SpotifyError.redirectURLInvalid {
                result(
                    FlutterError(
                        code: "errorConnecting",
                        message: "Redirect URL is not set or has invalid format", details: nil))
            } catch {
                result(
                    FlutterError(
                        code: "CouldNotFindSpotifyApp",
                        message: "The Spotify app is not installed on the device", details: nil))
                return
            }

        case SpotifySdkConstants.methodGetSwapToken:
            guard let args = call.arguments as? [String: Any] else {
                result(
                    FlutterError(
                    code: "INVALID_ARGUMENTS",
                    message: "Arguments are not a dictionary: \(String(describing: call.arguments))",
                    details: nil))
                return
            }

            guard let clientId = args["clientId"] as? String,
                let redirectUrl = args["redirectUrl"] as? String,
                let scopesString = args["scopes"] as? String,
                let tokenSwapUrl = args["tokenSwapUrl"] as? String
                else {
                result(
                    FlutterError(
                        code: "INVALID_ARGUMENTS",
                        message: "Missing required arguments. Received arguments: \(args)",
                        details: nil))
                return
            }

            // Check if Spotify is installed
            if !isSpotifyInstalled() {
                result(
                    FlutterError(
                        code: "SPOTIFY_NOT_INSTALLED",
                        message: "Spotify app is not installed",
                        details: nil))
                return
            }

            authenticateTokenSwap(
                clientId: clientId,
                redirectUri: redirectUrl,
                scopes: scopesString.components(separatedBy: ","),
                tokenSwapUrl: tokenSwapUrl,
                tokenRefreshUrl: nil,
                result: result
            )

        case SpotifySdkConstants.methodIsSpotifyInstalled:
            result(isSpotifyInstalled())
            return

        case SpotifySdkConstants.methodGetAccessToken:
            guard let swiftArguments = call.arguments as? [String: Any],
                let clientID = swiftArguments[SpotifySdkConstants.paramClientId] as? String,
                let url = swiftArguments[SpotifySdkConstants.paramRedirectUrl] as? String
            else {
                result(
                    FlutterError(
                        code: "Arguments Error", message: "One or more arguments are missing",
                        details: nil))
                return
            }
            connectionStatusHandler?.tokenResult = result
            let spotifyUri: String =
                swiftArguments[SpotifySdkConstants.paramSpotifyUri] as? String ?? ""

            do {
                try connectToSpotify(
                    clientId: clientID, redirectURL: url, spotifyUri: spotifyUri,
                    asRadio: swiftArguments[SpotifySdkConstants.paramAsRadio] as? Bool,
                    additionalScopes: swiftArguments[SpotifySdkConstants.scope] as? String)
            } catch SpotifyError.redirectURLInvalid {
                result(
                    FlutterError(
                        code: "errorConnecting",
                        message: "Redirect URL is not set or has invalid format", details: nil))
            } catch {
                result(
                    FlutterError(
                        code: "CouldNotFindSpotifyApp",
                        message: "The Spotify app is not installed on the device", details: nil))
                return
            }
        case SpotifySdkConstants.methodGetImage:
            guard let appRemote = appRemote else {
                result(
                    FlutterError(
                        code: "Connection Error", message: "AppRemote is null", details: nil))
                return
            }
            guard let swiftArguments = call.arguments as? [String: Any],
                let paramImageUri = swiftArguments[SpotifySdkConstants.paramImageUri] as? String,
                let paramImageDimension = swiftArguments[SpotifySdkConstants.paramImageDimension]
                    as? Int
            else {
                result(
                    FlutterError(
                        code: "Arguments Error", message: "One or more arguments are missing",
                        details: nil))
                return
            }

            class ImageObject: NSObject, SPTAppRemoteImageRepresentable {
                var imageIdentifier: String = ""
            }

            let imageObject = ImageObject()
            imageObject.imageIdentifier = paramImageUri
            appRemote.imageAPI?.fetchImage(
                forItem: imageObject,
                with: CGSize(width: paramImageDimension, height: paramImageDimension),
                callback: { (image, error) in
                    guard error == nil else {
                        result(
                            FlutterError(
                                code: "ImageAPI Error", message: error?.localizedDescription,
                                details: nil))
                        return
                    }
                    guard let imageData = (image as? UIImage)?.pngData() else {
                        result(
                            FlutterError(
                                code: "ImageAPI Error", message: "Image is empty", details: nil))
                        return
                    }
                    result(imageData)
                })
        case SpotifySdkConstants.methodGetPlayerState:
            guard let appRemote = appRemote else {
                result(
                    FlutterError(
                        code: "Connection Error", message: "AppRemote is null", details: nil))
                return
            }

            appRemote.playerAPI?.getPlayerState({ (playerState, error) in
                guard error == nil else {
                    result(
                        FlutterError(
                            code: "PlayerAPI Error", message: error?.localizedDescription,
                            details: nil))
                    return
                }
                guard let playerState = playerState as? SPTAppRemotePlayerState else {
                    result(
                        FlutterError(
                            code: "PlayerAPI Error", message: "PlayerState is empty", details: nil))
                    return
                }
                result(State.playerStateDictionary(playerState).json)
            })
        case SpotifySdkConstants.methodDisconnectFromSpotify:
            appRemote?.disconnect()
            //            appRemote?.connectionParameters.accessToken = nil
            result(true)
        case SpotifySdkConstants.methodPlay:
            guard let appRemote = appRemote else {
                result(
                    FlutterError(
                        code: "Connection Error", message: "AppRemote is null", details: nil))
                return
            }
            guard let swiftArguments = call.arguments as? [String: Any],
                let uri = swiftArguments[SpotifySdkConstants.paramSpotifyUri] as? String
            else {
                result(
                    FlutterError(code: "URI Error", message: "No URI was specified", details: nil))
                return
            }
            let asRadio: Bool = (swiftArguments[SpotifySdkConstants.paramAsRadio] as? Bool) ?? false
            appRemote.playerAPI?.play(uri, asRadio: asRadio, callback: defaultPlayAPICallback)
        case SpotifySdkConstants.methodPause:
            guard let appRemote = appRemote else {
                result(
                    FlutterError(
                        code: "Connection Error", message: "AppRemote is null", details: nil))
                return
            }
            appRemote.playerAPI?.pause(defaultPlayAPICallback)
        case SpotifySdkConstants.methodResume:
            guard let appRemote = appRemote else {
                result(
                    FlutterError(
                        code: "Connection Error", message: "AppRemote is null", details: nil))
                return
            }
            appRemote.playerAPI?.resume(defaultPlayAPICallback)
        case SpotifySdkConstants.methodSkipNext:
            guard let appRemote = appRemote else {
                result(
                    FlutterError(
                        code: "Connection Error", message: "AppRemote is null", details: nil))
                return
            }
            appRemote.playerAPI?.skip(toNext: defaultPlayAPICallback)
        case SpotifySdkConstants.methodSkipPrevious:
            guard let appRemote = appRemote else {
                result(
                    FlutterError(
                        code: "Connection Error", message: "AppRemote is null", details: nil))
                return
            }
            appRemote.playerAPI?.skip(toPrevious: { (spotifyResult, error) in
                if let error = error {
                    result(
                        FlutterError(
                            code: "PlayerAPI Error", message: error.localizedDescription,
                            details: nil))
                    return
                }
                result(true)
            })
        case SpotifySdkConstants.methodSkipToIndex:
            guard let appRemote = appRemote else {
                result(
                    FlutterError(
                        code: "Connection Error", message: "AppRemote is null", details: nil))
                return
            }
            guard let swiftArguments = call.arguments as? [String: Any],
                let uri = swiftArguments[SpotifySdkConstants.paramSpotifyUri] as? String
            else {
                result(
                    FlutterError(code: "URI Error", message: "No URI was specified", details: nil))
                return
            }
            let index = (swiftArguments[SpotifySdkConstants.paramTrackIndex] as? Int) ?? 0

            appRemote.contentAPI?.fetchContentItem(
                forURI: uri,
                callback: { (contentItemResult, error) in
                    guard error == nil else {
                        result(
                            FlutterError(
                                code: "PlayerAPI Error", message: error?.localizedDescription,
                                details: nil))
                        return
                    }
                    guard let contentItem = contentItemResult as? SPTAppRemoteContentItem else {
                        result(
                            FlutterError(
                                code: "URI Error", message: "No URI was specified", details: nil))
                        return
                    }
                    appRemote.playerAPI?.play(
                        contentItem, skipToTrackIndex: index, callback: defaultPlayAPICallback)
                })

        case SpotifySdkConstants.methodAddToLibrary:
            guard let appRemote = appRemote else {
                result(
                    FlutterError(
                        code: "Connection Error", message: "AppRemote is null", details: nil))
                return
            }
            guard let swiftArguments = call.arguments as? [String: Any],
                let uri = swiftArguments[SpotifySdkConstants.paramSpotifyUri] as? String
            else {
                result(
                    FlutterError(code: "URI Error", message: "No URI was specified", details: nil))
                return
            }
            appRemote.userAPI?.addItemToLibrary(withURI: uri, callback: defaultPlayAPICallback)
        case SpotifySdkConstants.methodRemoveFromLibrary:
            guard let appRemote = appRemote else {
                result(
                    FlutterError(
                        code: "Connection Error", message: "AppRemote is null", details: nil))
                return
            }
            guard let swiftArguments = call.arguments as? [String: Any],
                let uri = swiftArguments[SpotifySdkConstants.paramSpotifyUri] as? String
            else {
                result(
                    FlutterError(code: "URI Error", message: "No URI was specified", details: nil))
                return
            }
            appRemote.userAPI?.removeItemFromLibrary(withURI: uri, callback: defaultPlayAPICallback)
        case SpotifySdkConstants.methodGetCapabilities:
            guard let appRemote = appRemote else {
                result(
                    FlutterError(
                        code: "Connection Error", message: "AppRemote is null", details: nil))
                return
            }
            appRemote.userAPI?.fetchCapabilities(callback: { (capabilitiesResult, error) in
                guard error == nil else {
                    result(
                        FlutterError(
                            code: "getCapabilitiesError", message: error?.localizedDescription,
                            details: nil))
                    return
                }
                guard let userCapabilities = capabilitiesResult as? SPTAppRemoteUserCapabilities
                else {
                    result(
                        FlutterError(
                            code: "getCapabilitiesError", message: error?.localizedDescription,
                            details: nil))
                    return
                }

                result(State.userCapabilitiesDictionary(userCapabilities).json)
            })
        case SpotifySdkConstants.methodQueueTrack:
            guard let appRemote = appRemote else {
                result(
                    FlutterError(
                        code: "Connection Error", message: "AppRemote is null", details: nil))
                return
            }
            guard let swiftArguments = call.arguments as? [String: Any],
                let uri = swiftArguments[SpotifySdkConstants.paramSpotifyUri] as? String
            else {
                result(
                    FlutterError(code: "URI Error", message: "No URI was specified", details: nil))
                return
            }
            appRemote.playerAPI?.enqueueTrackUri(uri, callback: defaultPlayAPICallback)
        case SpotifySdkConstants.methodSeekTo:
            guard let appRemote = appRemote else {
                result(
                    FlutterError(
                        code: "Connection Error", message: "AppRemote is null", details: nil))
                return
            }
            guard let swiftArguments = call.arguments as? [String: Any],
                let position = swiftArguments[SpotifySdkConstants.paramPositionedMilliseconds]
                    as? Int
            else {
                result(
                    FlutterError(
                        code: "Position error", message: "No position was specified", details: nil))
                return
            }
            appRemote.playerAPI?.seek(toPosition: position, callback: defaultPlayAPICallback)
        case SpotifySdkConstants.methodGetCrossfadeState:
            guard let appRemote = appRemote else {
                result(
                    FlutterError(
                        code: "Connection Error", message: "AppRemote is null", details: nil))
                return
            }
            appRemote.playerAPI?.getCrossfadeState({ (crossfadeState, error) in
                guard error == nil else {
                    result(
                        FlutterError(
                            code: "PlayerAPI Error", message: error?.localizedDescription,
                            details: nil))
                    return
                }
                guard let crossfadeState = crossfadeState as? SPTAppRemoteCrossfadeState else {
                    result(
                        FlutterError(
                            code: "PlayerAPI Error", message: "PlayerState is empty", details: nil))
                    return
                }
                result(State.crossfadeStateDictionary(crossfadeState).json)
            })
        case SpotifySdkConstants.methodSetShuffle:
            guard let appRemote = appRemote else {
                result(
                    FlutterError(
                        code: "Connection Error", message: "AppRemote is null", details: nil))
                return
            }
            guard let swiftArguments = call.arguments as? [String: Any],
                let shuffle = swiftArguments[SpotifySdkConstants.paramShuffle] as? Bool
            else {
                result(
                    FlutterError(
                        code: "Shuffle mode error", message: "No ShuffleMode was specified",
                        details: nil))
                return
            }
            appRemote.playerAPI?.setShuffle(shuffle, callback: defaultPlayAPICallback)
        case SpotifySdkConstants.methodSetRepeatMode:
            guard let appRemote = appRemote else {
                result(
                    FlutterError(
                        code: "Connection Error", message: "AppRemote is null", details: nil))
                return
            }
            guard let swiftArguments = call.arguments as? [String: Any],
                let repeatModeIndex = swiftArguments[SpotifySdkConstants.paramRepeatMode] as? UInt,
                let repeatMode = SPTAppRemotePlaybackOptionsRepeatMode(rawValue: repeatModeIndex)
            else {
                result(
                    FlutterError(
                        code: "Repeat mode error", message: "No RepeatMode was specified",
                        details: nil))
                return
            }
            appRemote.playerAPI?.setRepeatMode(repeatMode, callback: defaultPlayAPICallback)
        case SpotifySdkConstants.getLibraryState:
            guard let appRemote = appRemote else {
                result(
                    FlutterError(
                        code: "Connection Error", message: "AppRemote is null", details: nil))
                return
            }
            guard let swiftArguments = call.arguments as? [String: Any],
                let uri = swiftArguments[SpotifySdkConstants.paramSpotifyUri] as? String
            else {
                result(
                    FlutterError(code: "URI Error", message: "No URI was specified", details: nil))
                return
            }
            appRemote.userAPI?.fetchLibraryState(
                forURI: uri,
                callback: { libraryStateResult, error in
                    guard error == nil else {
                        result(
                            FlutterError(
                                code: "fetchLibraryStateError",
                                message: error?.localizedDescription, details: nil))
                        return
                    }
                    guard let libraryState = libraryStateResult as? SPTAppRemoteLibraryState else {
                        result(
                            FlutterError(
                                code: "fetchLibraryStateError",
                                message: error?.localizedDescription, details: nil))
                        return
                    }

                    result(State.libraryStateDictionary(libraryState).json)
                })
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func connectToSpotify(
        clientId: String, redirectURL: String, accessToken: String? = nil, spotifyUri: String = "",
        asRadio: Bool?, additionalScopes: String? = nil
    ) throws {
        func configureAppRemote(clientID: String, redirectURL: String, accessToken: String? = nil)
            throws
        {
            guard let redirectURL = URL(string: redirectURL) else {
                throw SpotifyError.redirectURLInvalid
            }
            let configuration = SPTConfiguration(clientID: clientID, redirectURL: redirectURL)
            let appRemote = SPTAppRemote(configuration: configuration, logLevel: .none)
            appRemote.delegate = connectionStatusHandler
            let playerDelegate = PlayerDelegate()
            playerStateHandler = PlayerStateHandler(
                appRemote: appRemote, playerDelegate: playerDelegate)
            SwiftSpotifySdkPlugin.playerStateChannel?.setStreamHandler(playerStateHandler)

            playerContextHandler = PlayerContextHandler(
                appRemote: appRemote, playerDelegate: playerDelegate)
            SwiftSpotifySdkPlugin.playerContextChannel?.setStreamHandler(playerContextHandler)

            appRemote.connectionParameters.accessToken = accessToken
            self.appRemote = appRemote
        }

        try configureAppRemote(
            clientID: clientId, redirectURL: redirectURL, accessToken: accessToken)

        var scopes: [String]?
        if let additionalScopes = additionalScopes {
            scopes = additionalScopes.components(separatedBy: ",")
        }

        if accessToken != nil {
            appRemote?.connect()
        } else {
            // Note: A blank string will play the user's last song or pick a random one.
            self.appRemote?.authorizeAndPlayURI(
                spotifyUri, asRadio: asRadio ?? false, additionalScopes: scopes
            ) { success in
                if !success {
                    self.connectionStatusHandler?.connectionResult?(
                        FlutterError(
                            code: "spotifyNotInstalled", message: "Spotify app is not installed",
                            details: nil))
                }
            }
        }
    }

    private func isSpotifyInstalled() -> Bool {
        return UIApplication.shared.canOpenURL(URL(string: "spotify:")!)
    }

    private func authenticateTokenSwap(
        clientId: String,
        redirectUri: String,
        scopes: [String],
        tokenSwapUrl: String,
        tokenRefreshUrl: String?,
        result: @escaping FlutterResult
    ) {
        guard let redirectURL = URL(string: redirectUri) else {
            result(
                FlutterError(
                    code: "INVALID_URI",
                    message: "Invalid redirect URI",
                    details: nil))
            return
        }

        // Create configuration
        let configuration = SPTConfiguration(clientID: clientId, redirectURL: redirectURL)
        configuration.tokenSwapURL = URL(string: tokenSwapUrl)
        if let tokenRefreshUrl = tokenRefreshUrl {
            configuration.tokenRefreshURL = URL(string: tokenRefreshUrl)
        }

        // Initialize session manager if needed
        if sessionManager == nil {
            sessionManager = SPTSessionManager(configuration: configuration, delegate: self)
        }

        authCallback = result

        // Convert string scopes to SPTScope
        let spotifyScopes: SPTScope = scopes.reduce(into: []) { result, scope in
            switch scope {
            case "user-read-private":
                result.insert(.userReadPrivate)
            case "user-read-email":
                result.insert(.userReadEmail)
            case "playlist-read-private":
                result.insert(.playlistReadPrivate)
            case "playlist-modify-public":
                result.insert(.playlistModifyPublic)
            case "playlist-modify-private":
                result.insert(.playlistModifyPrivate)
            case "user-library-read":
                result.insert(.userLibraryRead)
            case "user-library-modify":
                result.insert(.userLibraryModify)
            case "streaming":
                result.insert(.streaming)
            case "app-remote-control":
                result.insert(.appRemoteControl)
            case "user-follow-read":
                result.insert(.userFollowRead)
            case "user-follow-modify":
                result.insert(.userFollowModify)
            case "user-top-read":
                result.insert(.userTopRead)
            case "playlist-read-collaborative":
                result.insert(.playlistReadCollaborative)
            case "user-read-playback-state":
                result.insert(.userReadPlaybackState)
            case "user-modify-playback-state":
                result.insert(.userModifyPlaybackState)
            case "user-read-currently-playing":
                result.insert(.userReadCurrentlyPlaying)
            case "user-read-recently-played":
                result.insert(.userReadRecentlyPlayed)
            default:
                break
            }
        }

        sessionManager?.initiateSession(with: spotifyScopes, options: .clientOnly, campaign: "app")
    }

    public func handleSpotifyCallback(url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
            let code = components.queryItems?.first(where: { $0.name == "code" })?.value
        else {
            authCallback?(
                FlutterError(
                    code: "INVALID_CALLBACK",
                    message: "Missing authorization code",
                    details: nil))
            return
        }
        authCallback?(code)
        authCallback = nil
    }
}

extension SwiftSpotifySdkPlugin: SPTSessionManagerDelegate {
    public func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
        authCallback?(session.accessToken)
        authCallback = nil
    }

    public func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
        authCallback?(
            FlutterError(
                code: "AUTH_FAILED",
                message: error.localizedDescription,
                details: nil))
        authCallback = nil
    }

    public func application(
        _ application: UIApplication, open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        setAccessTokenFromURL(url: url)
        return true
    }

    public func application(
        _ application: UIApplication, continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([Any]) -> Void
    ) -> Bool {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
            let url = userActivity.webpageURL
        else {
            connectionStatusHandler?.connectionResult?(
                FlutterError(
                    code: "errorConnecting", message: "client id or redirectUrl is invalid",
                    details: nil))
            connectionStatusHandler?.tokenResult?(
                FlutterError(
                    code: "errorConnecting", message: "client id or redirectUrl is invalid",
                    details: nil))
            connectionStatusHandler?.connectionResult = nil
            connectionStatusHandler?.tokenResult = nil
            return false
        }

        setAccessTokenFromURL(url: url)
        return false
    }

    private func setAccessTokenFromURL(url: URL) {
        guard let appRemote = appRemote else {
            connectionStatusHandler?.connectionResult?(
                FlutterError(code: "errorConnection", message: "AppRemote is null", details: nil))
            connectionStatusHandler?.tokenResult?(
                FlutterError(code: "errorConnection", message: "AppRemote is null", details: nil))
            connectionStatusHandler?.connectionResult = nil
            connectionStatusHandler?.tokenResult = nil
            return
        }

        guard let token = appRemote.authorizationParameters(from: url)?[SPTAppRemoteAccessTokenKey]
        else {
            connectionStatusHandler?.connectionResult?(
                FlutterError(
                    code: "authenticationTokenError",
                    message: appRemote.authorizationParameters(from: url)?[
                        SPTAppRemoteErrorDescriptionKey], details: nil))
            connectionStatusHandler?.tokenResult?(
                FlutterError(
                    code: "authenticationTokenError",
                    message: appRemote.authorizationParameters(from: url)?[
                        SPTAppRemoteErrorDescriptionKey], details: nil))
            connectionStatusHandler?.connectionResult = nil
            connectionStatusHandler?.tokenResult = nil
            return
        }

        appRemote.connectionParameters.accessToken = token
        appRemote.connect()
    }
}
