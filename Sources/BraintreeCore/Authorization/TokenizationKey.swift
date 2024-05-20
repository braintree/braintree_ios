import Foundation

class TokenizationKey: ClientAuthorization {
    
    // MARK: - Internal Properties
    
    let type = AuthorizationType.tokenizationKey
    let bearer: String
    let configURL: URL
    let originalValue: String
    
    // MARK: - Initializer
    
    init(_ rawValue: String) throws {
        self.bearer = rawValue
        self.originalValue = rawValue
        guard let configURL = TokenizationKey.baseURLFromTokenizationKey(rawValue) else {
            throw TokenizationKeyError.invalid
        }
        self.configURL = configURL
    }
    
    // MARK: - Private Methods
    
    private static func baseURLFromTokenizationKey(_ tokenizationKey: String) -> URL? {
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
        components.scheme = environment == "development" ? "http" : "https"

        guard let host = host(for: environment) else { return nil }
        let hostComponents: [String] = host.components(separatedBy: ":")

        components.host = hostComponents.first

        if hostComponents.count > 1 {
            let portString: String = hostComponents[1]
            components.port = Int(portString)
        }

        components.path = "/merchants/\(merchantID)/client_api" + "/v1/configuration"

        return components.url
    }

    private static func host(for environment: String) -> String? {
        if environment.lowercased() == "sandbox" {
            return "api.sandbox.braintreegateway.com"
        } else if environment.lowercased() == "production" {
            return "api.braintreegateway.com:443"
        } else if environment.lowercased() == "development" {
            return "localhost:3000"
        }

        return nil
    }
}
