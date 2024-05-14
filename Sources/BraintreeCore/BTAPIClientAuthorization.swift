import UIKit

public enum BTAPIClientAuthorization {
    case tokenizationKey
    case clientToken
}

public protocol Authorization {
    
    var type: BTAPIClientAuthorization { get }
    var configURL: URL { get }
    var bearer: String { get }
    
    /// The original Client token or Tokenization Key string
    var originalValue: String { get } // TODO: rawValue re-name
}

//extension Authorization {
//
//    func isTokenizationKey() {
//        print("Drawing a \(bearer) shape.")
//    }
//}

class BTTokenizationKey: Authorization {
    
    let type = BTAPIClientAuthorization.tokenizationKey
    
    let bearer: String
    let configURL: URL
    let originalValue: String
    
    init(_ rawValue: String) throws {
        self.bearer = rawValue
        self.originalValue = rawValue
        guard let configURL = BTTokenizationKey.baseURLFromTokenizationKey(rawValue) else {
            throw BTClientTokenError.invalidAuthorizationFingerprint // todo
        }
        self.configURL = configURL
    }
    
    static func baseURLFromTokenizationKey(_ tokenizationKey: String) -> URL? {
        let pattern: String = "([a-zA-Z0-9]+)_[a-zA-Z0-9]+_([a-zA-Z0-9_]+)"
        guard let regularExpression = try? NSRegularExpression(pattern: pattern) else { return nil }

        let range = NSRange(location: 0, length: tokenizationKey.count)
        let matches = regularExpression.matches(in: tokenizationKey, range: range)

        if matches.count != 1 || matches.first?.numberOfRanges != 3 {
            return nil
        }

        var environment: String = ""
        var merchantID: String = ""

        matches.forEach { match in
            environment = (tokenizationKey as NSString).substring(with: match.range(at: 1))
            merchantID = (tokenizationKey as NSString).substring(with: match.range(at: 2))
        }

        var components: URLComponents = URLComponents()
        components.scheme = scheme(forEnvironment: environment)

        guard let host = host(forEnvironment: environment, httpType: .gateway) else { return nil }
        let hostComponents: [String] = host.components(separatedBy: ":")

        components.host = hostComponents.first

        if hostComponents.count > 1 {
            let portString: String = hostComponents[1]
            components.port = Int(portString)
        }

        components.path = clientApiBasePath(forMerchantID: merchantID)

        return components.url
    }
    
    static func scheme(forEnvironment environment: String) -> String {
        environment.lowercased() == "development" ? "http" : "https"
    }

    static func host(forEnvironment environment: String, httpType: BTAPIClientHTTPService) -> String? {
        var host: String? = nil
        let environmentLowercased: String = environment.lowercased()

        switch httpType {
        case .gateway:
            if environmentLowercased == "sandbox" {
                host = "api.sandbox.braintreegateway.com"
            } else if environmentLowercased == "production" {
                host = "api.braintreegateway.com:443"
            } else if environmentLowercased == "development" {
                host = "localhost:3000"
            }

        case .graphQLAPI:
            if environmentLowercased == "sandbox" {
                host = "payments.sandbox.braintree-api.com"
            } else if environmentLowercased == "development" {
                host = "localhost:8080"
            } else {
                host = "payments.braintree-api.com"
            }

        default:
            host = nil
        }

        return host
    }
    
    static func clientApiBasePath(forMerchantID merchantID: String) -> String {
        "/merchants/\(merchantID)/client_api"
    }
}
