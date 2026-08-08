import Flutter
import SpotifyiOS

class PlayerHandler: NSObject {
    private unowned let remoteManager: RemoteManager

    init(remoteManager: RemoteManager) {
        self.remoteManager = remoteManager
        super.init()
    }

    private var defaultPlayCallback: (_ result: @escaping FlutterResult) -> SPTAppRemoteCallback {
        return { result in
            return { _, error in
                if let error = error {
                    result(SpotifyErrorMapper.makeError(code: "PlayerAPI Error", message: error.localizedDescription))
                } else {
                    result(true)
                }
            }
        }
    }

    public func getPlayerState(result: @escaping FlutterResult) {
        guard let appRemote = remoteManager.appRemote else {
            result(SpotifyErrorMapper.notConnectedError())
            return
        }
        appRemote.playerAPI?.getPlayerState({ (playerState, error) in
            guard error == nil else {
                result(SpotifyErrorMapper.makeError(code: "PlayerAPI Error", message: error?.localizedDescription ?? ""))
                return
            }
            guard let playerState = playerState as? SPTAppRemotePlayerState else {
                result(SpotifyErrorMapper.makeError(code: "PlayerAPI Error", message: "PlayerState is empty"))
                return
            }
            result(State.playerStateDictionary(playerState).json)
        })
    }

    public func play(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let appRemote = remoteManager.appRemote else {
            result(SpotifyErrorMapper.notConnectedError())
            return
        }
        guard let swiftArguments = call.arguments as? [String: Any],
              let uri = swiftArguments[SpotifySdkConstants.paramSpotifyUri] as? String else {
            result(SpotifyErrorMapper.argumentError("No URI was specified"))
            return
        }
        let asRadio: Bool = (swiftArguments[SpotifySdkConstants.paramAsRadio] as? Bool) ?? false
        appRemote.playerAPI?.play(uri, asRadio: asRadio, callback: defaultPlayCallback(result))
    }

    public func pause(result: @escaping FlutterResult) {
        guard let appRemote = remoteManager.appRemote else {
            result(SpotifyErrorMapper.notConnectedError())
            return
        }
        appRemote.playerAPI?.pause(defaultPlayCallback(result))
    }

    public func resume(result: @escaping FlutterResult) {
        guard let appRemote = remoteManager.appRemote else {
            result(SpotifyErrorMapper.notConnectedError())
            return
        }
        appRemote.playerAPI?.resume(defaultPlayCallback(result))
    }

    public func queueTrack(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let appRemote = remoteManager.appRemote else {
            result(SpotifyErrorMapper.notConnectedError())
            return
        }
        guard let swiftArguments = call.arguments as? [String: Any],
              let uri = swiftArguments[SpotifySdkConstants.paramSpotifyUri] as? String else {
            result(SpotifyErrorMapper.argumentError("No URI was specified"))
            return
        }
        appRemote.playerAPI?.enqueueTrackUri(uri, callback: defaultPlayCallback(result))
    }

    public func skipNext(result: @escaping FlutterResult) {
        guard let appRemote = remoteManager.appRemote else {
            result(SpotifyErrorMapper.notConnectedError())
            return
        }
        appRemote.playerAPI?.skip(toNext: defaultPlayCallback(result))
    }

    public func skipPrevious(result: @escaping FlutterResult) {
        guard let appRemote = remoteManager.appRemote else {
            result(SpotifyErrorMapper.notConnectedError())
            return
        }
        appRemote.playerAPI?.skip(toPrevious: { (_, error) in
            if let error = error {
                result(SpotifyErrorMapper.makeError(code: "PlayerAPI Error", message: error.localizedDescription))
                return
            }
            result(true)
        })
    }

    public func skipToIndex(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let appRemote = remoteManager.appRemote else {
            result(SpotifyErrorMapper.notConnectedError())
            return
        }
        guard let swiftArguments = call.arguments as? [String: Any],
              let uri = swiftArguments[SpotifySdkConstants.paramSpotifyUri] as? String else {
            result(SpotifyErrorMapper.argumentError("No URI was specified"))
            return
        }
        let index = (swiftArguments[SpotifySdkConstants.paramTrackIndex] as? Int) ?? 0

        appRemote.contentAPI?.fetchContentItem(forURI: uri, callback: { (contentItemResult, error) in
            guard error == nil else {
                result(SpotifyErrorMapper.makeError(code: "PlayerAPI Error", message: error?.localizedDescription ?? ""))
                return
            }
            guard let contentItem = contentItemResult as? SPTAppRemoteContentItem else {
                result(SpotifyErrorMapper.argumentError("No URI was specified"))
                return
            }
            appRemote.playerAPI?.play(contentItem, skipToTrackIndex: index, callback: self.defaultPlayCallback(result))
        })
    }

    public func seekTo(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let appRemote = remoteManager.appRemote else {
            result(SpotifyErrorMapper.notConnectedError())
            return
        }
        guard let swiftArguments = call.arguments as? [String: Any],
              let position = swiftArguments[SpotifySdkConstants.paramPositionedMilliseconds] as? Int else {
            result(SpotifyErrorMapper.argumentError("No position was specified"))
            return
        }
        appRemote.playerAPI?.seek(toPosition: position, callback: defaultPlayCallback(result))
    }

    public func seekToRelativePosition(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let appRemote = remoteManager.appRemote else {
            result(SpotifyErrorMapper.notConnectedError())
            return
        }
        guard let swiftArguments = call.arguments as? [String: Any],
              let relativeMilliseconds = swiftArguments[SpotifySdkConstants.paramRelativeMilliseconds] as? Int else {
            result(SpotifyErrorMapper.argumentError("No relative position was specified"))
            return
        }
        appRemote.playerAPI?.getPlayerState({ (playerState, error) in
            guard error == nil else {
                result(SpotifyErrorMapper.makeError(code: "PlayerAPI Error", message: error?.localizedDescription ?? ""))
                return
            }
            guard let playerState = playerState as? SPTAppRemotePlayerState else {
                result(SpotifyErrorMapper.makeError(code: "PlayerAPI Error", message: "PlayerState is empty"))
                return
            }
            let targetPos = max(0, playerState.playbackPosition + relativeMilliseconds)
            appRemote.playerAPI?.seek(toPosition: targetPos, callback: self.defaultPlayCallback(result))
        })
    }

    public func getCrossfadeState(result: @escaping FlutterResult) {
        guard let appRemote = remoteManager.appRemote else {
            result(SpotifyErrorMapper.notConnectedError())
            return
        }
        appRemote.playerAPI?.getCrossfadeState({ (crossfadeState, error) in
            guard error == nil else {
                result(SpotifyErrorMapper.makeError(code: "PlayerAPI Error", message: error?.localizedDescription ?? ""))
                return
            }
            guard let crossfadeState = crossfadeState as? SPTAppRemoteCrossfadeState else {
                result(SpotifyErrorMapper.makeError(code: "PlayerAPI Error", message: "PlayerState is empty"))
                return
            }
            result(State.crossfadeStateDictionary(crossfadeState).json)
        })
    }

    public func setShuffle(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let appRemote = remoteManager.appRemote else {
            result(SpotifyErrorMapper.notConnectedError())
            return
        }
        guard let swiftArguments = call.arguments as? [String: Any],
              let shuffle = swiftArguments[SpotifySdkConstants.paramShuffle] as? Bool else {
            result(SpotifyErrorMapper.argumentError("No ShuffleMode was specified"))
            return
        }
        appRemote.playerAPI?.setShuffle(shuffle, callback: defaultPlayCallback(result))
    }

    public func toggleShuffle(result: @escaping FlutterResult) {
        guard let appRemote = remoteManager.appRemote else {
            result(SpotifyErrorMapper.notConnectedError())
            return
        }
        appRemote.playerAPI?.getPlayerState({ (playerState, error) in
            guard error == nil else {
                result(SpotifyErrorMapper.makeError(code: "PlayerAPI Error", message: error?.localizedDescription ?? ""))
                return
            }
            guard let playerState = playerState as? SPTAppRemotePlayerState else {
                result(SpotifyErrorMapper.makeError(code: "PlayerAPI Error", message: "PlayerState is empty"))
                return
            }
            let currentShuffle = playerState.playbackOptions.isShuffling
            appRemote.playerAPI?.setShuffle(!currentShuffle, callback: self.defaultPlayCallback(result))
        })
    }

    public func setRepeatMode(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let appRemote = remoteManager.appRemote else {
            result(SpotifyErrorMapper.notConnectedError())
            return
        }
        guard let swiftArguments = call.arguments as? [String: Any],
              let repeatModeIndex = swiftArguments[SpotifySdkConstants.paramRepeatMode] as? UInt,
              let repeatMode = SPTAppRemotePlaybackOptionsRepeatMode(rawValue: repeatModeIndex) else {
            result(SpotifyErrorMapper.argumentError("No RepeatMode was specified"))
            return
        }
        appRemote.playerAPI?.setRepeatMode(repeatMode, callback: defaultPlayCallback(result))
    }

    public func toggleRepeat(result: @escaping FlutterResult) {
        guard let appRemote = remoteManager.appRemote else {
            result(SpotifyErrorMapper.notConnectedError())
            return
        }
        appRemote.playerAPI?.getPlayerState({ (playerState, error) in
            guard error == nil else {
                result(SpotifyErrorMapper.makeError(code: "PlayerAPI Error", message: error?.localizedDescription ?? ""))
                return
            }
            guard let playerState = playerState as? SPTAppRemotePlayerState else {
                result(SpotifyErrorMapper.makeError(code: "PlayerAPI Error", message: "PlayerState is empty"))
                return
            }
            let nextMode: SPTAppRemotePlaybackOptionsRepeatMode
            switch playerState.playbackOptions.repeatMode {
            case .off: nextMode = .context
            case .context: nextMode = .track
            case .track: nextMode = .off
            @unknown default: nextMode = .off
            }
            appRemote.playerAPI?.setRepeatMode(nextMode, callback: self.defaultPlayCallback(result))
        })
    }

    public func switchToLocalDevice(result: @escaping FlutterResult) {
        result(FlutterMethodNotImplemented)
    }
}
