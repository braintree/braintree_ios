import Foundation

class BTAPIHTTP: BTHTTP {

    let accessToken: String

    @objc(initWithBaseURL:accessToken:)
    public init(url: URL, accessToken: String) {
        self.accessToken = accessToken
        super.init(url: url)
    }
    
    override var defaultHeaders: [String: String] {
        [
            "User-Agent": userAgentString,
            "Accept": acceptString,
            "Accept-Language": acceptLanguageString,
            "Braintree-Version": BTCoreConstants.apiVersion,
            "Authorization": "Bearer \(accessToken)"
        ]
    }
}
