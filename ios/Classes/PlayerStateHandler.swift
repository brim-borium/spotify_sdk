import SpotifyiOS

class PlayerStateHandler: StatusHandler, SPTAppRemotePlayerStateDelegate {

    private var appRemote: SPTAppRemote
    private var subscribedToPlayerState = false

    init (appRemote: SPTAppRemote) {
        self.appRemote = appRemote
        super.init()
    }

    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        print("playerStateDidChange")
        eventSink?(stateJson(playerState).json)
    }

    func subscribeToPlayerState() {
        print("Subscribed to player state")
        guard !subscribedToPlayerState else { return }
        appRemote.playerAPI!.delegate = self
        appRemote.playerAPI?.subscribe { (_, error) -> Void in
            guard error == nil else { return }
            self.subscribedToPlayerState = true
        }
    }

    override func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        _ = super.onListen(withArguments: arguments, eventSink: events)
        subscribeToPlayerState()
        return nil
    }

    private func stateJson(_ playerState: SPTAppRemotePlayerState) -> [String : Any] {
        let artist = [
            "name" : playerState.track.artist.name,
            "uri" : playerState.track.artist.uri
        ]

        let album = [
            "name" : playerState.track.album.name,
            "uri" : playerState.track.album.uri
        ]

        let imageIdentifier = [
            "raw" : playerState.track.imageIdentifier

        ]

        let track: [String : Any] = [
            "album" : album,
            "artist" : artist,
            "artists" : [artist],
            "duration_ms" : playerState.track.duration,
            "image_id" : imageIdentifier,
            "is_episode" : playerState.track.isEpisode,
            "is_podcast" : playerState.track.isPodcast,
            "name" : playerState.track.name,
            "uri" : playerState.track.uri
        ]

        let playbackOptions: [String : Any] = [
            "shuffle" : playerState.playbackOptions.isShuffling,
            "repeat" : playerState.playbackOptions.repeatMode.rawValue
        ]

        let playbackRestrictions = [
            "can_skip_next" : playerState.playbackRestrictions.canSkipNext,
            "can_skip_prev" : playerState.playbackRestrictions.canSkipPrevious,
            "can_repeat_track" : playerState.playbackRestrictions.canRepeatTrack,
            "can_repeat_context" : playerState.playbackRestrictions.canRepeatContext,
            "can_toggle_shuffle" : playerState.playbackRestrictions.canToggleShuffle,
            "can_seek" : playerState.playbackRestrictions.canSeek
        ]

        return [
            "track" : track,
            "is_paused" : playerState.isPaused,
            "playback_speed" : playerState.playbackSpeed,
            "playback_position" : playerState.playbackPosition,
            "playback_options" : playbackOptions,
            "playback_restrictions" : playbackRestrictions
        ]
    }
}

extension Dictionary {

    var json: String {
        let invalidJson = "Invalid JSON"
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            return String(bytes: jsonData, encoding: String.Encoding.utf8) ?? invalidJson
        } catch {
            return invalidJson
        }
    }
}
