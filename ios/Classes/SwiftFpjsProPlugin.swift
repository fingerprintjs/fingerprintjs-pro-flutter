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
                let region = parseRegion(passedRegion: args["region"] as? String, endpoint: args["endpoint"] as? String)

                initFpjs(token: token, region: region)
                result("Successfully initialized FingerprintJS Pro Client")
            } else {
                result(FlutterError.init(code: "errorApiToken", message: "missing API Token", details: nil))
            }
        } else if (call.method == "getVisitorId") {
            let args = call.arguments as? Dictionary<String, Any>
            let tags = args?["tags"] as? [String: JSONTypeConvertible]
            var metadata = Metadata()
            
            tags?.forEach({ (tagName: String, tagValue: JSONTypeConvertible) in
                metadata.setTag(tagValue, forKey: tagName)
            })

            getVisitorId(metadata, result)
        }
    }

    private func parseRegion(passedRegion: String?, endpoint: String?) -> Region {
        var region: Region
        switch passedRegion {
        case "eu":
            region = .eu
        case "ap":
            region = .ap
        default:
            region = .global
        }

        if let endpointString = endpoint {
            region = .custom(domain: endpointString)
        }

        return region
    }

    private func initFpjs(token: String, region: Region) {
        let configuration = Configuration(apiKey: token, region: region)
        fpjsClient = FingerprintProFactory.getInstance(configuration)
    }

    private func getVisitorId(_ metadata: Metadata?, _ result: @escaping FlutterResult) {
        Task {
            do {
                let visitorId = try await fpjsClient?.getVisitorId(metadata)
                result(visitorId)
            } catch FPJSError.apiError(let apiError) {
                result(FlutterError.init(code: "errorGetVisitorId", message: apiError.error?.message, details: nil))
            }
        }
    }
}
