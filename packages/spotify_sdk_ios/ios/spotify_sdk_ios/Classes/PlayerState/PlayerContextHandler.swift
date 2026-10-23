import Flutter
import SpotifyiOS

class PlayerContextHandler: PlayerSubscriptionHandler {
    init(playerDelegate: PlayerDelegate) {
        super.init(playerDelegate: playerDelegate, sinkKeyPath: \.playerContextSink)
    }
}
