import Foundation
import FingerprintPro

extension FPJSError {
    var flutterFields: (String, String) {
        let description = self.localizedDescription
        switch self {
        case .invalidURL:
            return ("InvalidURL", description)
        case .invalidURLParams:
            return ("InvalidURLParams", description)
        case .apiError(let apiError):
            let code = apiError.flutterCode("apiError")
            let message = apiError.message ?? description
            return (code, message)
        case .networkError(let networkError):
            return ("NetworkError", networkError.localizedDescription)
        case .jsonParsingError(let jsonParsingError):
            return ("JsonParsingError", jsonParsingError.localizedDescription)
        case .invalidResponseType:
            return ("InvalidResponseType", description)
        case .clientTimeout:
            return ("ClientTimeout", description)
        case .unknownError:
            fallthrough
        @unknown default:
            return ("UnknownError", description)
        }
    }
}

extension APIError {
    func flutterCode(_ defaultName: String) -> String {
        let name = self.error?.code?.rawValue ?? defaultName
        return name.firstUppercased
    }

    var message: String? {
        return self.error?.message
    }
}

extension StringProtocol {
    var firstUppercased: String { prefix(1).uppercased() + dropFirst() }
}
