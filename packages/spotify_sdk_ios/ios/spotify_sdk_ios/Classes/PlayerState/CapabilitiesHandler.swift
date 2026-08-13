import Flutter
import SpotifyiOS

class CapabilitiesHandler: StatusHandler, SPTAppRemoteUserAPIDelegate {
    private weak var appRemote: SPTAppRemote?

    func setAppRemote(_ appRemote: SPTAppRemote) {
        self.appRemote = appRemote
        appRemote.userAPI?.delegate = self
        appRemote.userAPI?.subscribe(toCapabilityChanges: { (_, error) in
            if let error = error {
                print("Failed to subscribe to capability changes: \(error.localizedDescription)")
            }
        })
    }

    override func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        _ = super.onListen(withArguments: arguments, eventSink: events)
        if let userAPI = appRemote?.userAPI {
            userAPI.delegate = self
            userAPI.fetchCapabilities { [weak self] (capabilitiesResult, error) in
                guard error == nil, let userCapabilities = capabilitiesResult as? SPTAppRemoteUserCapabilities else { return }
                self?.userAPI(userAPI, didReceive: userCapabilities)
            }
            userAPI.subscribe(toCapabilityChanges: { (_, error) in
                if let error = error {
                    print("Failed to subscribe to capability changes: \(error.localizedDescription)")
                }
            })
        }
        return nil
    }

    func userAPI(_ userAPI: SPTAppRemoteUserAPI, didReceive capabilities: SPTAppRemoteUserCapabilities) {
        let dictionary = State.userCapabilitiesDictionary(capabilities)
        eventSink?(dictionary.json)
    }
}
