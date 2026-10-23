import Flutter
import SpotifyiOS

class PlayerStateHandler: PlayerSubscriptionHandler {
    init(playerDelegate: PlayerDelegate) {
        super.init(playerDelegate: playerDelegate, sinkKeyPath: \.playerStateSink)
    }
}
