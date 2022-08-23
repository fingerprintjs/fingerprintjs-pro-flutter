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
        guard let args = call.arguments as? [String: Any] else {
            result(FlutterError(code: "missingArguments", message: "Missing or invalid arguments", details: nil))
            return
        }
        
        if (call.method == "init") {
            if let token = args["apiToken"] as? String {
                let region = parseRegion(passedRegion: args["region"] as? String, endpoint: args["endpoint"] as? String)

                initFpjs(token: token, region: region)
                result("Successfully initialized FingerprintJS Pro Client")
            } else {
                result(FlutterError.init(code: "errorApiToken", message: "missing API Token", details: nil))
            }
        } else if (call.method == "getVisitorId") {
            let metadata = prepareMetadata(args["tags"])
            getVisitorId(metadata, result)
        }
    }
    
    private func prepareMetadata(_ tags: Any?) -> Metadata? {
        guard
            let tags = tags,
            let jsonTags = JSONTypeConvertor.convertObjectToJSONTypeConvertible(tags)
        else {
            return nil
        }
        
        var metadata = Metadata()
        if let dict = jsonTags as? [String: JSONTypeConvertible] {
            dict.forEach { key, jsonType in
                metadata.setTag(jsonType, forKey: key)
            }
        } else {
            metadata.setTag(jsonTags, forKey: "tag")
        }
        return metadata
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
        guard let client = fpjsClient else {
            result(FlutterError.init(code: "undefinedFpClient", message: "You need to call init method first", details: nil))
            return
        }
        Task {
            do {
                let visitorId = try await client.getVisitorId(metadata)
                result(visitorId)
            } catch FPJSError.apiError(let apiError) {
                result(FlutterError.init(code: "errorGetVisitorId", message: apiError.error?.message, details: nil))
            }
        }
    }
}
