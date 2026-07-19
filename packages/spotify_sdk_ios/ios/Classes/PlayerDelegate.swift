import SpotifyiOS
import Flutter

class PlayerDelegate: NSObject, SPTAppRemotePlayerStateDelegate {

    var playerStateSink: FlutterEventSink?
    var playerContextSink: FlutterEventSink?

    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        print("playerStateDidChange")
        playerStateSink?(State.playerStateDictionary(playerState).json)
        playerContextSink?(State.playerContextDictionary(playerState).json)
    }
}
