import XCTest
@testable import BraintreeCore
@testable import BraintreeVenmo

class BTVenmoAppSwitchRedirectURL_Tests: XCTestCase {

    func testAppSwitchURL_whenPaymentContextIDIsNotNil_returnsURLWithPaymentContextID() {
        let requestURL = BTVenmoAppSwitchRedirectURL().appSwitch(
            returnURLScheme: "url-scheme",
            forMerchantID: "merchant-id",
            accessToken: "access-token",
            bundleDisplayName: "display-name",
            environment: "sandbox",
            paymentContextID: "12345",
            metadata: BTClientMetadata()
        )

        let components = requestURL.flatMap { URLComponents(url: $0, resolvingAgainstBaseURL: false) }
        guard let queryItems = components?.queryItems else { XCTFail(); return }
        XCTAssertTrue(queryItems.contains(URLQueryItem(name: "resource_id", value: "12345")))
    }

    func testAppSwitchURL_whenPaymentContextIDIsNil_returnsURLWithoutPaymentContextID() {
        let requestURL = BTVenmoAppSwitchRedirectURL().appSwitch(
            returnURLScheme: "url-scheme",
            forMerchantID: "merchant-id",
            accessToken: "access-token",
            bundleDisplayName: "display-name",
            environment: "sandbox",
            paymentContextID: nil,
            metadata: BTClientMetadata()
        )

        let components = requestURL.flatMap { URLComponents(url: $0, resolvingAgainstBaseURL: false) }
        guard let queryItems = components?.queryItems else { XCTFail(); return }
        XCTAssertNil(queryItems.first(where: { $0.name == "resource_id" }))
    }
}
