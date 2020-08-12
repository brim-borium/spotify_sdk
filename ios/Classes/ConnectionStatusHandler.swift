import SpotifyiOS

class ConnectionStatusHandler: StatusHandler, SPTAppRemoteDelegate {

    private var onConnect: (()->())?

    init(onConnect: (()->())? ) {
        super.init()
        self.onConnect = onConnect
    }

    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        // emit connection established event
        eventSink?("{\"connected\": true}")
        onConnect?()
    }

    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        //
    }

    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        eventSink?(FlutterError(code: "didDisconnectWithError", message: error?.localizedDescription, details: nil))
    }
}
