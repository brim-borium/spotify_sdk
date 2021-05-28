import SpotifyiOS

struct State {
    static func playerStateDictionary(_ playerState: SPTAppRemotePlayerState) -> [String : Any] {
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

    static func playerContextDictionary(_ playerState: SPTAppRemotePlayerState) -> [String : Any] {
        return [
            "title" : playerState.contextTitle,
            "subtitle" : playerState.contextTitle,
            "type" : playerState.contextURI.absoluteString.components(separatedBy: ":")[1],
            "uri" : playerState.contextURI.absoluteString
        ]
    }

    static func crossfadeStateDictionary(_ crossfadeState: SPTAppRemoteCrossfadeState) -> [String : Any] {
        return [
            "duration": crossfadeState.duration,
            "isEnabled": crossfadeState.isEnabled,
        ]
    }

    static func userCapabilitiesDictionary(_ userCapabilities: SPTAppRemoteUserCapabilities) -> [String : Any] {
        return [
            "can_play_on_demand": userCapabilities.canPlayOnDemand
        ]
    }
}
