import Foundation

@objcMembers public class BTAPIHTTPSwift: BTHTTPSwift {
    
    let accessToken: String

    @objc(initWithBaseURL:accessToken:)
    public init(url: URL, accessToken: String) {
        self.accessToken = accessToken

        super.init(url: url)

        let configuration = URLSessionConfiguration.ephemeral
        configuration.httpAdditionalHeaders = self.defaultHeaders()

        let delegateQueue = OperationQueue()
        delegateQueue.name = "com.braintreepayments.BTHTTP"
        delegateQueue.maxConcurrentOperationCount = .max

        self.session = URLSession(
            configuration: configuration,
            delegate: self,
            delegateQueue: delegateQueue
        )

        self.pinnedCertificates = BTAPIPinnedCertificates.trustedCertificates()
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
