import Flutter
import UIKit

class ConnectionStatusHandler: NSObject, FlutterStreamHandler {

    private var eventSink: FlutterEventSink?

    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        print("onListen")
        events(true) // any generic type or more compex dictionary of [String:Any]
        events(FlutterError(code: "ERROR_CODE",
                             message: "Detailed message",
                             details: nil)) // in case of errors
        events(FlutterEndOfEventStream) // when stream is over
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        print("onCancel")
        return nil
    }

}
