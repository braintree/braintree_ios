import Foundation
@testable import BraintreeCore

class FakeAnalyticsService: BTAnalyticsService {
    var lastEvent: String? = nil
    var endpoint: String? = nil
    
    convenience init() {
        self.init(
            authorization: try! TokenizationKey("development_tokenization_key"),
            configuration:  BTConfiguration(json: BTJSON(value: ["environment": "fake-env1"])),
            metadata: BTClientMetadata()
        )
    }

    override func sendAnalyticsEvent(
        _ eventName: String,
        connectionStartTime: Int? = nil,
        correlationID: String? = nil,
        endpoint: String? = nil,
        endTime: Int? = nil,
        errorDescription: String? = nil,
        isVaultRequest: Bool? = nil,
        linkType: String? = nil,
        payPalContextID: String? = nil,
        requestStartTime: Int? = nil,
        startTime: Int? = nil
    ) {
        self.lastEvent = eventName
        self.endpoint = endpoint
    }
}
