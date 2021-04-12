import XCTest
import BraintreeVenmo

class BTVenmoAppSwitchRequestURL_Tests: XCTestCase {

    func testAppSwitchURL_whenPaymentContextIDIsNotNil_returnsURLWithPaymentContextID() {
        let requestURL = BTVenmoAppSwitchRequestURL.appSwitch(forMerchantID: "merchant-id",
                                                              accessToken: "access-token",
                                                              returnURLScheme: "url-scheme",
                                                              bundleDisplayName: "display-name",
                                                              environment: "sandbox",
                                                              paymentContextID: "12345",
                                                              metadata: BTClientMetadata())

        let components = requestURL.flatMap { URLComponents(url: $0, resolvingAgainstBaseURL: false) }
        guard let queryItems = components?.queryItems else { XCTFail(); return }
        XCTAssertTrue(queryItems.contains(URLQueryItem(name: "resource_id", value: "12345")))
    }

    func testAppSwitchURL_whenPaymentContextIDIsNil_returnsURLWithoutPaymentContextID() {
        let requestURL = BTVenmoAppSwitchRequestURL.appSwitch(forMerchantID: "merchant-id",
                                                              accessToken: "access-token",
                                                              returnURLScheme: "url-scheme",
                                                              bundleDisplayName: "display-name",
                                                              environment: "sandbox",
                                                              paymentContextID: nil,
                                                              metadata: BTClientMetadata())

        let components = requestURL.flatMap { URLComponents(url: $0, resolvingAgainstBaseURL: false) }
        guard let queryItems = components?.queryItems else { XCTFail(); return }
        XCTAssertNil(queryItems.first(where: { $0.name == "resource_id" }))
    }
}
