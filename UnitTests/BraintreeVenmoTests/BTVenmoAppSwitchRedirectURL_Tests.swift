import XCTest
@testable import BraintreeCore
@testable import BraintreeVenmo

class BTVenmoAppSwitchRedirectURL_Tests: XCTestCase {

    func testAppSwitchURL_whenMerchantIDNil_throwsError() {
        do {
            _ = try BTVenmoAppSwitchRedirectURL(
                paymentContextID: "12345",
                metadata: BTClientMetadata(),
                universalLink: URL(string: "https://mywebsite.com/braintree-payments")!,
                forMerchantID: nil,
                accessToken: "access-token",
                bundleDisplayName: "display-name",
                environment: "sandbox"
            )
        } catch {
            XCTAssertEqual(error as? BTVenmoError, .invalidRedirectURLParameter)
            XCTAssertEqual((error as NSError).code, 10)
            XCTAssertEqual((error as NSError).localizedDescription, "One or more values in redirect URL are invalid.")
        }
    }

    func testUniversalLinkURL_whenAllValuesInitialized_returnsURLWithAllValues() {
        do {
            let requestURL = try BTVenmoAppSwitchRedirectURL(
                paymentContextID: "12345",
                metadata: BTClientMetadata(),
                universalLink: URL(string: "https://mywebsite.com/braintree-payments")!,
                forMerchantID: "merchant-id",
                accessToken: "access-token",
                bundleDisplayName: "display-name",
                environment: "sandbox"
            )

            XCTAssertTrue(requestURL.universalLinksURL()!.absoluteString.contains("https://venmo.com/go/checkout"))

            let components = URLComponents(string: requestURL.universalLinksURL()!.absoluteString)
            guard let queryItems = components?.queryItems else { XCTFail(); return }
            XCTAssertTrue(queryItems.contains(URLQueryItem(name: "x-success", value: "https://mywebsite.com/braintree-payments/success")))
            XCTAssertTrue(queryItems.contains(URLQueryItem(name: "x-error", value: "https://mywebsite.com/braintree-payments/error")))
            XCTAssertTrue(queryItems.contains(URLQueryItem(name: "x-cancel", value: "https://mywebsite.com/braintree-payments/cancel")))
            XCTAssertTrue(queryItems.contains(URLQueryItem(name: "x-source", value: "display-name")))
            XCTAssertTrue(queryItems.contains(URLQueryItem(name: "braintree_merchant_id", value: "merchant-id")))
            XCTAssertTrue(queryItems.contains(URLQueryItem(name: "braintree_access_token", value: "access-token")))
            XCTAssertTrue(queryItems.contains(URLQueryItem(name: "braintree_environment", value: "sandbox")))
            XCTAssertTrue(queryItems.contains(URLQueryItem(name: "resource_id", value: "12345")))
            XCTAssertTrue(queryItems.contains(URLQueryItem(name: "customerClient", value: "MOBILE_APP")))
        } catch {
            XCTFail("This request URL should be constructed successfully")
        }
    }
}
