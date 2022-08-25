import Foundation

@objcMembers public class BTAPIHTTPSwift: BTHTTPSwift {
    
    let accessToken: String

    @objc(initWithBaseURL:accessToken:)
    public init(url: URL, accessToken: String) {
        self.accessToken = accessToken
        super.init(url: url)
    }
    
    override func defaultHeaders() -> [String: String] {
        [
            "User-Agent": self.userAgentString(),
            "Accept": self.acceptString(),
            "Accept-Language": self.acceptLanguageString(),
            "Braintree-Version": BTCoreConstants.apiVersion,
            "Authorization": "Bearer \(self.accessToken)"
        ]
    }
}
