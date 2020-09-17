import SpotifyiOS

class ConnectionStatusHandler: StatusHandler, SPTAppRemoteDelegate {

    let pluginInstance : SwiftSpotifySdkPlugin
    init(pluginInstance: SwiftSpotifySdkPlugin){
        self.pluginInstance = pluginInstance
    }
    
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        defer {
            pluginInstance.connectionResult = nil
        }
        
        pluginInstance.connectionResult?(true)
        eventSink?("{\"connected\": true}")
    }

    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        if error != nil {
            // report spotify remote error to plugin
            eventSink?("{\"connected\": false, \"errorCode\": \"\(error!._code)\", \"errorDetails\": \"\(error!.localizedDescription)\"}")
        } else {
            // report disconnection to plugin
            eventSink?("{\"connected\": false}")
        }
    }

    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        if error != nil {
            // report spotify remote error to plugin
            eventSink?("{\"connected\": false, \"errorCode\": \"\(error!._code)\", \"errorDetails\": \"\(error!.localizedDescription)\"}")
        } else {
            // report disconnection to plugin
            eventSink?("{\"connected\": false}")
        }
    }
}
