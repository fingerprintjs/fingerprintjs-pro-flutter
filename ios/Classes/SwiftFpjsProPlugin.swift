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
                let region = parseRegion(passedRegion: args["region"] as? String, endpoint: args["endpoint"] as? String, endpointFallbacks: args["endpointFallbacks"] as? [String] ?? [])
                let extendedResponseFormat = args["extendedResponseFormat"] as? Bool ?? false
                let pluginVersion = args["pluginVersion"] as? String ?? "unknown"

                initFpjs(token: token, region: region, extendedResponseFormat: extendedResponseFormat, pluginVersion: pluginVersion)
                result("Successfully initialized FingerprintJS Pro Client")
            } else {
                result(FlutterError.init(code: "errorApiToken", message: "missing API Token", details: nil))
            }
        } else if (call.method == "getVisitorId") {
            let metadata = prepareMetadata(args["linkedId"] as? String, tags: args["tags"])
            getVisitorId(metadata, result)
        } else if (call.method == "getVisitorData") {
            let metadata = prepareMetadata(args["linkedId"] as? String, tags: args["tags"])
            getVisitorData(metadata, result)
        }
    }

    private func prepareMetadata(_ linkedId: String?, tags: Any?) -> Metadata {
        var metadata = Metadata(linkedId: linkedId)
        guard
            let tags = tags,
            let jsonTags = JSONTypeConvertor.convertObjectToJSONTypeConvertible(tags)
        else {
            return metadata
        }

        if let dict = jsonTags as? [String: JSONTypeConvertible] {
            dict.forEach { key, jsonType in
                metadata.setTag(jsonType, forKey: key)
            }
        } else {
            metadata.setTag(jsonTags, forKey: "tag")
        }
        return metadata
    }

    private func parseRegion(passedRegion: String?, endpoint: String?, endpointFallbacks: [String] = []) -> Region {
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
            region = .custom(domain: endpointString, fallback: endpointFallbacks)
        }

        return region
    }

    private func initFpjs(token: String, region: Region, extendedResponseFormat: Bool, pluginVersion: String) {
        let configuration = Configuration(apiKey: token, region: region, integrationInfo: [("fingerprint-pro-flutter", pluginVersion)], extendedResponseFormat: extendedResponseFormat)
        fpjsClient = FingerprintProFactory.getInstance(configuration)
    }

    private func getVisitorId(_ metadata: Metadata?, _ result: @escaping FlutterResult) {
        guard let client = fpjsClient else {
            result(FlutterError.init(code: "undefinedFpClient", message: "You need to call init method first", details: nil))
            return
        }

        client.getVisitorId(metadata) { visitorIdResult in
            switch visitorIdResult {
            case .success(let visitorId):
                result(visitorId)
            case .failure(let error):
                self.processNativeLibraryError(error, result: result)
            }
        }
    }

    private func getVisitorData(_ metadata: Metadata?, _ result: @escaping FlutterResult) {
        guard let client = fpjsClient else {
            result(FlutterError(code: "undefinedFpClient", message: "You need to call init method first", details: nil))
            return
        }

        client.getVisitorIdResponse(metadata) { visitorIdResponseResult in
            switch visitorIdResponseResult {
            case .success(let visitorDataResponse):
                result([
                    visitorDataResponse.requestId,
                    visitorDataResponse.confidence,
                    visitorDataResponse.asJSON()
                ])
            case .failure(let error):
                self.processNativeLibraryError(error, result: result)
            }
        }
    }

    private func processNativeLibraryError(_ error: FPJSError, result: @escaping FlutterResult) {
        let (code, description) = error.flutterFields
        result(FlutterError(code: code, message: description, details: nil))
    }
}
