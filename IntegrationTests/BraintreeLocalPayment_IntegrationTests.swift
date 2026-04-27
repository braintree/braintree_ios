import Foundation
import XCTest
@testable import BraintreeCore
@testable import BraintreeLocalPayment

class BTLocalPaymentClient_IntegrationTests: XCTestCase {

    // MARK: - Properties

    var localPaymentClient: BTLocalPaymentClient!
    var delegate = MockLocalPaymentRequestDelegate()

    // MARK: - Setup

    override func setUp() {
        super.setUp()
        localPaymentClient = BTLocalPaymentClient(authorization: BTIntegrationTestsConstants.sandboxClientToken)
    }

    // MARK: - start

    func testStart_withIDeal_returnsNonce() {
        let request = BTLocalPaymentRequest(
            paymentType: "ideal",
            amount: "1.01",
            currencyCode: "EUR",
            paymentTypeCountryCode: "NL",
            merchantAccountID: "customer-nl-merchant-account",
            email: "lingo-buyer@paypal.com",
            givenName: "Lizenka",
            surname: "Penna",
            phone: "16040000000",
            isShippingAddressRequired: false
        )
        request.localPaymentFlowDelegate = delegate

        let expectation = expectation(description: "Start local payment for iDEAL")

        localPaymentClient.start(request) { result, error in
            guard let result else {
                XCTFail("Expected a result to be returned")
                return
            }

            XCTAssertTrue(result.nonce.isValidNonce)
            XCTAssertNil(error)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5)
    }

    func testStart_withBancontact_returnsNonce() {
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

        let expectation = expectation(description: "Start local payment for Bancontact")

        localPaymentClient.start(request) { result, error in
            guard let result else {
                XCTFail("Expected a result to be returned")
                return
            }

            XCTAssertTrue(result.nonce.isValidNonce)
            XCTAssertNil(error)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5)
    }

    func testStart_withSofort_returnsNonce() {
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

        let expectation = expectation(description: "Start local payment for Sofort")

        localPaymentClient.start(request) { result, error in
            guard let result else {
                XCTFail("Expected a result to be returned")
                return
            }

            XCTAssertTrue(result.nonce.isValidNonce)
            XCTAssertNil(error)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5)
    }

    func testStart_withGiropay_returnsNonce() {
        let request = BTLocalPaymentRequest(
            paymentType: "giropay",
            amount: "10.00",
            currencyCode: "EUR",
            paymentTypeCountryCode: "DE",
            email: "lingo-buyer@paypal.com",
            givenName: "Lena",
            surname: "Fischer"
        )
        request.localPaymentFlowDelegate = delegate

        let expectation = expectation(description: "Start local payment for Giropay")

        localPaymentClient.start(request) { result, error in
            guard let result else {
                XCTFail("Expected a result to be returned")
                return
            }

            XCTAssertTrue(result.nonce.isValidNonce)
            XCTAssertNil(error)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5)
    }

    func testStart_withShippingAddressRequired_returnsNonce() {
        let address = BTPostalAddress(
            streetAddress: "836486 of 22321 Park Lake",
            extendedAddress: "#102",
            locality: "Den Haag",
            countryCodeAlpha2: "NL",
            postalCode: "2585 GJ",
            region: "CA"
        )

        let request = BTLocalPaymentRequest(
            paymentType: "ideal",
            amount: "1.01",
            currencyCode: "EUR",
            paymentTypeCountryCode: "NL",
            merchantAccountID: "customer-nl-merchant-account",
            address: address,
            email: "lingo-buyer@paypal.com",
            givenName: "Lizenka",
            surname: "Penna",
            phone: "16040000000",
            isShippingAddressRequired: true
        )
        request.localPaymentFlowDelegate = delegate

        let expectation = expectation(description: "Start local payment with shipping address required")

        localPaymentClient.start(request) { result, error in
            guard let result else {
                XCTFail("Expected a result to be returned")
                return
            }

            XCTAssertTrue(result.nonce.isValidNonce)
            XCTAssertNil(error)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5)
    }

    func testStart_withDisplayName_returnsNonce() {
        let request = BTLocalPaymentRequest(
            paymentType: "ideal",
            amount: "1.01",
            currencyCode: "EUR",
            paymentTypeCountryCode: "NL",
            merchantAccountID: "customer-nl-merchant-account",
            displayName: "My Brand!",
            email: "lingo-buyer@paypal.com",
            givenName: "Lizenka",
            surname: "Penna",
            phone: "16040000000",
            isShippingAddressRequired: false
        )
        request.localPaymentFlowDelegate = delegate

        let expectation = expectation(description: "Start local payment with display name")

        localPaymentClient.start(request) { result, error in
            guard let result else {
                XCTFail("Expected a result to be returned")
                return
            }

            XCTAssertTrue(result.nonce.isValidNonce)
            XCTAssertNil(error)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5)
    }

    func testStart_usingVersionThreeClientToken_returnsNonce() {
        localPaymentClient = BTLocalPaymentClient(authorization: BTIntegrationTestsConstants.sandboxClientTokenVersion3)

        let request = BTLocalPaymentRequest(
            paymentType: "ideal",
            amount: "1.01",
            currencyCode: "EUR",
            paymentTypeCountryCode: "NL",
            merchantAccountID: "customer-nl-merchant-account",
            email: "lingo-buyer@paypal.com",
            givenName: "Lizenka",
            surname: "Penna",
            phone: "16040000000",
            isShippingAddressRequired: false
        )
        request.localPaymentFlowDelegate = delegate

        let expectation = expectation(description: "Start local payment using v3 client token")

        localPaymentClient.start(request) { result, error in
            guard let result else {
                XCTFail("Expected a result to be returned")
                return
            }

            XCTAssertTrue(result.nonce.isValidNonce)
            XCTAssertNil(error)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5)
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

        waitForExpectations(timeout: 5)
    }

    func testStart_whenPaymentTypeIsInvalid_failsWithExpectedError() {
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
            XCTAssertEqual(error.domain, BTLocalPaymentError.errorDomain)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5)
    }

    func testStart_usingTokenizationKeyAndLocalPaymentsEnabled_failsWithAuthorizationError() {
        localPaymentClient = BTLocalPaymentClient(authorization: BTIntegrationTestsConstants.sandboxTokenizationKey)

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
            XCTAssertEqual(httpResponse.statusCode, 403)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5)
    }
}

// MARK: - MockLocalPaymentRequestDelegate

class MockLocalPaymentRequestDelegate: NSObject, BTLocalPaymentRequestDelegate {

    func localPaymentStarted(_ request: BTLocalPaymentRequest, paymentID: String, start: @escaping () -> Void) {
        start()
    }
}
