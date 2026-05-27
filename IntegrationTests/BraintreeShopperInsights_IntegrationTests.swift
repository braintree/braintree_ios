import Foundation
import XCTest
@testable import BraintreeCore
@testable import BraintreeShopperInsights

class BraintreeShopperInsights_IntegrationTests: XCTestCase {

    // MARK: - Properties

    var shopperInsightsClient: BTShopperInsightsClientV2!

    // MARK: - Setup

    override func setUp() {
        super.setUp()
        shopperInsightsClient = BTShopperInsightsClientV2(authorization: BTIntegrationTestsConstants.sandboxClientToken)
    }

    // MARK: - createCustomerSession

    func testCreateCustomerSession_withMinimalRequest_throwsError() async {
        do {
            _ = try await shopperInsightsClient.createCustomerSession(request: BTCustomerSessionRequest())
            XCTFail("Expected an error to be returned")
        } catch let error as NSError {
            XCTAssertTrue(
                error.domain == BTCoreConstants.httpErrorDomain || error.domain == NSURLErrorDomain,
                "Unexpected error domain: \(error.domain)"
            )
        }
    }

    func testCreateCustomerSession_withFullRequest_throwsError() async {
        let purchaseUnit = BTPurchaseUnit(amount: "10.00", currencyCode: "USD")
        let request = BTCustomerSessionRequest(
            hashedEmail: "8476ee4a4461ba6b5f6e5f3b84d92dac390cfe7a17b1bc7e5038ef01a04c065a",
            hashedPhoneNumber: "2f7b41e87f8de5da39f7d8a57ee0c5b34f0d0db0a43f5c1e80e47a5a7a7b3db",
            payPalAppInstalled: false,
            venmoAppInstalled: false,
            purchaseUnits: [purchaseUnit]
        )

        do {
            _ = try await shopperInsightsClient.createCustomerSession(request: request)
            XCTFail("Expected an error to be returned")
        } catch let error as NSError {
            XCTAssertTrue(
                error.domain == BTCoreConstants.httpErrorDomain || error.domain == NSURLErrorDomain,
                "Unexpected error domain: \(error.domain)"
            )
        }
    }

    // MARK: - updateCustomerSession

    func testUpdateCustomerSession_throwsError() async {
        let request = BTCustomerSessionRequest(
            hashedEmail: "8476ee4a4461ba6b5f6e5f3b84d92dac390cfe7a17b1bc7e5038ef01a04c065a",
            payPalAppInstalled: false,
            venmoAppInstalled: false
        )

        do {
            _ = try await shopperInsightsClient.updateCustomerSession(
                request: request,
                sessionID: "fake-session-id"
            )
            XCTFail("Expected an error to be returned")
        } catch let error as NSError {
            XCTAssertTrue(
                error.domain == BTCoreConstants.httpErrorDomain || error.domain == NSURLErrorDomain,
                "Unexpected error domain: \(error.domain)"
            )
        }
    }

    // MARK: - generateCustomerRecommendations

    func testGenerateCustomerRecommendations_withSessionID_throwsError() async {
        do {
            _ = try await shopperInsightsClient.generateCustomerRecommendations(
                request: nil,
                sessionID: "fake-session-id"
            )
            XCTFail("Expected an error to be returned")
        } catch let error as NSError {
            XCTAssertTrue(
                error.domain == BTCoreConstants.httpErrorDomain || error.domain == NSURLErrorDomain,
                "Unexpected error domain: \(error.domain)"
            )
        }
    }

    func testGenerateCustomerRecommendations_withRequestAndSessionID_throwsError() async {
        let request = BTCustomerSessionRequest(
            hashedEmail: "8476ee4a4461ba6b5f6e5f3b84d92dac390cfe7a17b1bc7e5038ef01a04c065a",
            payPalAppInstalled: false,
            venmoAppInstalled: false
        )

        do {
            _ = try await shopperInsightsClient.generateCustomerRecommendations(
                request: request,
                sessionID: "fake-session-id"
            )
            XCTFail("Expected an error to be returned")
        } catch let error as NSError {
            XCTAssertTrue(
                error.domain == BTCoreConstants.httpErrorDomain || error.domain == NSURLErrorDomain,
                "Unexpected error domain: \(error.domain)"
            )
        }
    }
}
