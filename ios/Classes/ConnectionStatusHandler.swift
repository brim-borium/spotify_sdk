import Flutter
import UIKit
import SpotifyiOS

class ConnectionStatusHandler: NSObject, FlutterStreamHandler {

    private var eventSink: FlutterEventSink?

    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil;
        return nil
    }

}

extension ConnectionStatusHandler: SPTAppRemoteDelegate {
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        // emit connection established event
        eventSink?("{\"connected\": true}")
    }

    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        //
    }

    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        eventSink?(FlutterError(code: "UNAVAILABLE", message: "Battery info unavailable", details: nil))
    }


}
