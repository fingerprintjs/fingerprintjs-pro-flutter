import Flutter
import UIKit
import FingerprintPro

public class SwiftFpjsProPlugin: NSObject, FlutterPlugin {
    var fpjsClient: FingerprintClientProviding?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "fpjs_pro_plugin", binaryMessenger: registrar.messenger())
        let instance = SwiftFpjsProPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if (call.method == "init") {
            if let args = call.arguments as? Dictionary<String, Any>,
                let token = args["apiToken"] as? String {
                let passedRegion = args["region"] as? String
                var region: Region
                
                switch passedRegion {
                case "eu":
                    region = .eu
                case "ap":
                    region = .ap
                default:
                    region = .global
                }

                var endpoint: URL?
                if let endpointString = args["endpoint"] as? String {
                    region = .custom(domain: endpointString)
                }

                initFpjs(token: token, region: region)
                result("Successfully initialized FingerprintJS Pro Client")
            } else {
                result(FlutterError.init(code: "errorApiToken", message: "missing API Token", details: nil))
            }
        } else if (call.method == "getVisitorId") {
            let args = call.arguments as? Dictionary<String, Any>
            let tags = args?["tags"] as? [String: JSONType]
//            var metadata = Metadata()
            
//            tags?.forEach({ (tagName: String, tagValue: JSONType) in
//                metadata.setTag(tagValue, forKey: tagName)
//            })

//            getVisitorId(metadata, { (visitorId: String) -> Void in result(visitorId) })
            getVisitorId(nil, { (visitorId: String) -> Void in result(visitorId) })
        }
    }

    private func initFpjs(token: String, region: Region) {
        let configuration = Configuration(apiKey: token, region: region)
        fpjsClient = FingerprintProFactory.getInstance(configuration)
    }

    private func getVisitorId(_ metadata: Metadata?, _ handler: @escaping (String) -> Void) {
        NSLog("getVisitorId")
//        fpjsClient?.getVisitorId { result in
//            switch result {
//            case let .failure(error):
//                handler(error.localizedDescription)
//            case let .success(visitorId):
//                handler(visitorId)
//            }
//        }
        Task {
            do {
                let visitorId = try await fpjsClient?.getVisitorId(metadata)
                handler(visitorId ?? "")
            } catch FPJSError.apiError(let apiError) {
                handler(apiError.error?.message ?? "")
            }
        }
    }
}
