import XCTest
@testable import BraintreeCore
@testable import BraintreeVenmo

class BTVenmoAppSwitchRedirectURL_Tests: XCTestCase {

    func testAppSwitchURL_whenAllValuesAreInitialized_returnsURLWithPaymentContextID() {
        do {
            let requestURL = try BTVenmoAppSwitchRedirectURL(
                returnURLScheme: "url-scheme",
                paymentContextID: "12345",
                metadata: BTClientMetadata(),
                forMerchantID: "merchant-id",
                accessToken: "access-token",
                bundleDisplayName: "display-name",
                environment: "sandbox"
            )

            XCTAssertTrue(requestURL.appSwitchURL()!.absoluteString.contains("com.venmo.touch.v2://x-callback-url/vzero/auth"))

            let components = URLComponents(string: requestURL.appSwitchURL()!.absoluteString)
            guard let queryItems = components?.queryItems else { XCTFail(); return }
            XCTAssertTrue(queryItems.contains(URLQueryItem(name: "resource_id", value: "12345")))
        } catch {
            XCTFail("This request URL should be constructed successfully")
        }
    }

    func testAppSwitchURL_whenMerchantIDNil_throwsError() {
        do {
            _ = try BTVenmoAppSwitchRedirectURL(
                returnURLScheme: "url-scheme",
                paymentContextID: "12345",
                metadata: BTClientMetadata(),
                forMerchantID: nil,
                accessToken: "access-token",
                bundleDisplayName: "display-name",
                environment: "sandbox"
            )
        } catch {
            XCTAssertEqual(error as? BTVenmoError, .invalidRedirectURLParameter)
            XCTAssertEqual((error as NSError).code, 11)
            XCTAssertEqual((error as NSError).localizedDescription, "One or more values in redirect URL are invalid.")
        }
    }

    func testUniversalLinkURL_whenAllValuesInitialized_returnsURLWithAllValues() {
        do {
            let requestURL = try BTVenmoAppSwitchRedirectURL(
                returnURLScheme: "url-scheme",
                paymentContextID: "12345",
                metadata: BTClientMetadata(),
                forMerchantID: "merchant-id",
                accessToken: "access-token",
                bundleDisplayName: "display-name",
                environment: "sandbox"
            )

            XCTAssertTrue(requestURL.universalLinksURL()!.absoluteString.contains("https://venmo.com/go/checkout"))

            let components = URLComponents(string: requestURL.universalLinksURL()!.absoluteString)
            guard let queryItems = components?.queryItems else { XCTFail(); return }
            XCTAssertTrue(queryItems.contains(URLQueryItem(name: "x-success", value: "url-scheme://x-callback-url/vzero/auth/venmo/success")))
            XCTAssertTrue(queryItems.contains(URLQueryItem(name: "x-error", value: "url-scheme://x-callback-url/vzero/auth/venmo/error")))
            XCTAssertTrue(queryItems.contains(URLQueryItem(name: "x-cancel", value: "url-scheme://x-callback-url/vzero/auth/venmo/cancel")))
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
