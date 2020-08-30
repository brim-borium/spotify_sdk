import SpotifyiOS
import Flutter

class PlayerDelegate: NSObject, SPTAppRemotePlayerStateDelegate {

    var playerStateSink: FlutterEventSink?
    var playerContextSink: FlutterEventSink?

    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        print("playerStateDidChange")
        playerStateSink?(PlayerState.stateJson(playerState).json)
        playerContextSink?(PlayerState.contextJson(playerState).json)
    }
}
