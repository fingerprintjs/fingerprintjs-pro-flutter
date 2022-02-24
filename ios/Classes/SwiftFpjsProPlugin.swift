import Flutter
import UIKit
import FingerprintJSPro

public class SwiftFpjsProPlugin: NSObject, FlutterPlugin {
    var fpjsClient: FingerprintJSProClient?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "fpjs_pro_plugin", binaryMessenger: registrar.messenger())
        let instance = SwiftFpjsProPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if (call.method == "init") {
            if let args = call.arguments as? Dictionary<String, Any>,
               let token = args["apiToken"] as? String {
                let region = args["region"] as? String

                var endpoint: URL?
                if let endpointString = args["endpoint"] as? String {
                    endpoint = URL(string: endpointString)
                }
                
                initFpjs(token: token, endpoint: endpoint, region: region)
            } else {
                result(FlutterError.init(code: "errorApiToken", message: "missing API Token", details: nil))
            }
        } else if (call.method == "getVisitorId") {
            let args = call.arguments as? Dictionary<String, Any>
            let tags = args?["tags"] as? FingerprintJSProClient.Tags

            getVisitorId(tags: tags, { (visitorId: String) -> Void in result(visitorId) })
        }
    }

    private func initFpjs(token: String, endpoint: URL? = nil, region: String? = nil) {
        fpjsClient = FingerprintJSProFactory.getInstance(token: token, endpoint: endpoint, region: region)
    }

    private func getVisitorId(tags: FingerprintJSProClient.Tags?, _ handler: @escaping (String) -> Void) {
        fpjsClient?.getVisitorId { result in
            switch result {
            case let .failure(error):
                handler(error.localizedDescription)
            case let .success(visitorId):
                handler(visitorId)
            }
        }
    }
}
