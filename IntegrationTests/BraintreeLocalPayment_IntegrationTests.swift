import Foundation
import XCTest
@testable import BraintreeCore
@testable import BraintreeLocalPayment

class BTLocalPaymentClient_IntegrationTests: XCTestCase {

    // MARK: - Properties

    var localPaymentClient: BTLocalPaymentClient!

    // MARK: - Setup

    override func setUp() {
        super.setUp()
        localPaymentClient = BTLocalPaymentClient(authorization: BTIntegrationTestsConstants.sandboxClientToken)
    }

    // MARK: - start

    func testStart_withIDeal_callsDelegateWithPaymentID() {
        let delegate = LocalPaymentStartedDelegate()
        delegate.expectation = expectation(description: "Delegate called with paymentID for iDEAL")

        let request = BTLocalPaymentRequest(
            paymentType: "ideal",
            amount: "1.01",
            currencyCode: "EUR",
            paymentTypeCountryCode: "NL",
            email: "lingo-buyer@paypal.com",
            givenName: "Lizenka",
            surname: "Penna",
            phone: "16040000000",
            isShippingAddressRequired: false
        )
        request.localPaymentFlowDelegate = delegate

        localPaymentClient.start(request) { _, _ in }

        waitForExpectations(timeout: 15)
        XCTAssertFalse(delegate.receivedPaymentID?.isEmpty == true)
    }

    func testStart_withBancontact_callsDelegateWithPaymentID() {
        let delegate = LocalPaymentStartedDelegate()
        delegate.expectation = expectation(description: "Delegate called with paymentID for Bancontact")

        let request = BTLocalPaymentRequest(
            paymentType: "bancontact",
            amount: "2.00",
            currencyCode: "EUR",
            paymentTypeCountryCode: "BE",
            email: "lingo-buyer@paypal.com",
            givenName: "Jan",
            surname: "De Smet"
        )
        request.localPaymentFlowDelegate = delegate

        localPaymentClient.start(request) { _, _ in }

        waitForExpectations(timeout: 15)
        XCTAssertFalse(delegate.receivedPaymentID?.isEmpty == true)
    }

    func testStart_withSofort_callsDelegateWithPaymentID() {
        let delegate = LocalPaymentStartedDelegate()
        delegate.expectation = expectation(description: "Delegate called with paymentID for Sofort")

        let request = BTLocalPaymentRequest(
            paymentType: "sofort",
            amount: "5.00",
            currencyCode: "EUR",
            paymentTypeCountryCode: "DE",
            email: "lingo-buyer@paypal.com",
            givenName: "Hans",
            surname: "Müller"
        )
        request.localPaymentFlowDelegate = delegate

        localPaymentClient.start(request) { _, _ in }

        waitForExpectations(timeout: 15)
        XCTAssertFalse(delegate.receivedPaymentID?.isEmpty == true)
    }

    func testStart_withShippingAddressRequired_callsDelegateWithPaymentID() {
        let delegate = LocalPaymentStartedDelegate()
        delegate.expectation = expectation(description: "Delegate called with paymentID with shipping address required")

        let request = BTLocalPaymentRequest(
            paymentType: "ideal",
            amount: "1.01",
            currencyCode: "EUR",
            paymentTypeCountryCode: "NL",
            email: "lingo-buyer@paypal.com",
            givenName: "Lizenka",
            surname: "Penna",
            phone: "16040000000",
            isShippingAddressRequired: true
        )
        request.localPaymentFlowDelegate = delegate

        localPaymentClient.start(request) { _, _ in }

        waitForExpectations(timeout: 15)
        XCTAssertFalse(delegate.receivedPaymentID?.isEmpty == true)
    }

    func testStart_withDisplayName_callsDelegateWithPaymentID() {
        let delegate = LocalPaymentStartedDelegate()
        delegate.expectation = expectation(description: "Delegate called with paymentID with display name")

        let request = BTLocalPaymentRequest(
            paymentType: "ideal",
            amount: "1.01",
            currencyCode: "EUR",
            paymentTypeCountryCode: "NL",
            displayName: "My Brand!",
            email: "lingo-buyer@paypal.com",
            givenName: "Lizenka",
            surname: "Penna",
            phone: "16040000000",
            isShippingAddressRequired: false
        )
        request.localPaymentFlowDelegate = delegate

        localPaymentClient.start(request) { _, _ in }

        waitForExpectations(timeout: 15)
        XCTAssertFalse(delegate.receivedPaymentID?.isEmpty == true)
    }

    // MARK: - Error cases

    func testStart_whenLocalPaymentDelegateIsNil_failsWithIntegrationError() {
        let request = BTLocalPaymentRequest(
            paymentType: "ideal",
            amount: "1.01",
            currencyCode: "EUR",
            paymentTypeCountryCode: "NL",
            email: "lingo-buyer@paypal.com",
            givenName: "Lizenka",
            surname: "Penna",
            phone: "16040000000"
        )
        // localPaymentFlowDelegate intentionally left nil

        let expectation = expectation(description: "Start local payment with nil delegate")

        localPaymentClient.start(request) { result, error in
            guard let error = error as? NSError else {
                XCTFail("Expected an error to be returned")
                return
            }

            XCTAssertNil(result)
            XCTAssertEqual(error.domain, BTLocalPaymentError.errorDomain)
            XCTAssertEqual(error.code, BTLocalPaymentError.integration.errorCode)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 15)
    }

    func testStart_whenPaymentTypeIsInvalid_failsWithHTTPError() {
        let delegate = LocalPaymentStartedDelegate()

        let request = BTLocalPaymentRequest(
            paymentType: "invalid_type",
            amount: "1.00",
            currencyCode: "EUR",
            paymentTypeCountryCode: "NL",
            email: "lingo-buyer@paypal.com",
            givenName: "Test",
            surname: "User"
        )
        request.localPaymentFlowDelegate = delegate

        let expectation = expectation(description: "Start local payment with invalid payment type")

        localPaymentClient.start(request) { result, error in
            guard let error = error as? NSError else {
                XCTFail("Expected an error to be returned")
                return
            }

            XCTAssertNil(result)
            XCTAssertEqual(error.domain, BTCoreConstants.httpErrorDomain)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 15)
    }

    func testStart_usingTokenizationKey_failsWithAuthorizationError() {
        localPaymentClient = BTLocalPaymentClient(authorization: BTIntegrationTestsConstants.sandboxTokenizationKey)

        let delegate = LocalPaymentStartedDelegate()

        let request = BTLocalPaymentRequest(
            paymentType: "ideal",
            amount: "1.01",
            currencyCode: "EUR",
            paymentTypeCountryCode: "NL",
            email: "lingo-buyer@paypal.com",
            givenName: "Lizenka",
            surname: "Penna",
            phone: "16040000000"
        )
        request.localPaymentFlowDelegate = delegate

        let expectation = expectation(description: "Start local payment using tokenization key")

        localPaymentClient.start(request) { result, error in
            guard let error = error as? NSError else {
                XCTFail("Expected an error to be returned")
                return
            }

            XCTAssertNil(result)
            XCTAssertEqual(error.domain, BTCoreConstants.httpErrorDomain)
            XCTAssertEqual(error.code, 2)

            let httpResponse = error.userInfo[BTCoreConstants.urlResponseKey] as! HTTPURLResponse
            XCTAssertEqual(httpResponse.statusCode, 422)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 15)
    }
}

// MARK: - LocalPaymentStartedDelegate

/// Captures the paymentID from `localPaymentStarted` and fulfills the expectation
/// without calling `start()`, so `ASWebAuthenticationSession` never launches.
class LocalPaymentStartedDelegate: NSObject, BTLocalPaymentRequestDelegate {

    var expectation: XCTestExpectation?
    var receivedPaymentID: String?

    func localPaymentStarted(_ request: BTLocalPaymentRequest, paymentID: String, start: @escaping () -> Void) {
        receivedPaymentID = paymentID
        expectation?.fulfill()
        // Intentionally does not call start() — stops the flow before the browser launches.
    }
}
