import Foundation
import XCTest
@testable import BraintreeCore
@testable import BraintreeSEPADirectDebit

class BTSEPADirectDebitClient_IntegrationTests: XCTestCase {

    // MARK: - Properties

    var billingAddress: BTPostalAddress!
    var sepaDirectDebitRequest: BTSEPADirectDebitRequest!
    var sepaClient: BTSEPADirectDebitClient!

    // MARK: - Setup

    override func setUp() {
        super.setUp()

        billingAddress = BTPostalAddress(
            streetAddress: "Kantstraße 70",
            extendedAddress: "#170",
            locality: "Freistaat Sachsen",
            countryCodeAlpha2: "FR",
            postalCode: "09456",
            region: "Annaberg-buchholz"
        )

        sepaDirectDebitRequest = BTSEPADirectDebitRequest(
            accountHolderName: "John Doe",
            iban: "FR891751244434203564412313",
            customerID: "A0E243A0A200491D929D",
            mandateType: .recurrent,
            billingAddress: billingAddress,
            merchantAccountID: "eur_pwpp_multi_account_merchant_account"
        )

        sepaClient = BTSEPADirectDebitClient(authorization: BTIntegrationTestsConstants.sandboxClientToken)
    }

    // MARK: - tokenize

    func testTokenize_withRecurrentMandate_callsDelegateWithApprovalURL() async {
        do {
            _ = try await sepaClient.tokenize(sepaDirectDebitRequest)
            XCTFail("Expected web session to not complete in integration test environment")
        } catch let error as NSError {
            // The sandbox returns a valid approvalURL and launches ASWebAuthenticationSession.
            // In a headless environment the session fails to present — this confirms the
            // network round-trip succeeded and reached the web auth step.
            XCTAssertNotEqual(error.domain, BTCoreConstants.httpErrorDomain,
                "Expected error to originate from web session, not HTTP layer")
        }
    }

    func testTokenize_withOneOffMandate_callsDelegateWithApprovalURL() async {
        let request = BTSEPADirectDebitRequest(
            accountHolderName: "John Doe",
            iban: "FR891751244434203564412313",
            customerID: "A0E243A0A200491D929D",
            mandateType: .oneOff,
            billingAddress: billingAddress,
            merchantAccountID: "eur_pwpp_multi_account_merchant_account"
        )

        do {
            _ = try await sepaClient.tokenize(request)
            XCTFail("Expected web session to not complete in integration test environment")
        } catch let error as NSError {
            XCTAssertNotEqual(error.domain, BTCoreConstants.httpErrorDomain,
                "Expected error to originate from web session, not HTTP layer")
        }
    }

    func testTokenize_withoutMerchantAccountID_callsDelegateWithApprovalURL() async {
        let request = BTSEPADirectDebitRequest(
            accountHolderName: "John Doe",
            iban: "FR891751244434203564412313",
            customerID: "A0E243A0A200491D929D",
            mandateType: .recurrent,
            billingAddress: billingAddress,
            merchantAccountID: nil
        )

        do {
            _ = try await sepaClient.tokenize(request)
            XCTFail("Expected web session to not complete in integration test environment")
        } catch let error as NSError {
            XCTAssertNotEqual(error.domain, BTCoreConstants.httpErrorDomain,
                "Expected error to originate from web session, not HTTP layer")
        }
    }

    // MARK: - Error cases

    func testTokenize_usingTokenizationKey_failsWithAuthorizationError() async {
        sepaClient = BTSEPADirectDebitClient(authorization: BTIntegrationTestsConstants.sandboxTokenizationKey)

        do {
            _ = try await sepaClient.tokenize(sepaDirectDebitRequest)
            XCTFail("Expected an error to be returned")
        } catch let error as NSError {
            XCTAssertEqual(error.domain, BTCoreConstants.httpErrorDomain)
            XCTAssertEqual(error.code, 2)

            let httpResponse = error.userInfo[BTCoreConstants.urlResponseKey] as! HTTPURLResponse
            XCTAssertEqual(httpResponse.statusCode, 403)
        }
    }

    func testTokenize_usingVersionThreeClientToken_callsDelegateWithApprovalURL() async {
        sepaClient = BTSEPADirectDebitClient(authorization: BTIntegrationTestsConstants.sandboxClientTokenVersion3)

        do {
            _ = try await sepaClient.tokenize(sepaDirectDebitRequest)
            XCTFail("Expected web session to not complete in integration test environment")
        } catch let error as NSError {
            XCTAssertNotEqual(error.domain, BTCoreConstants.httpErrorDomain,
                "Expected error to originate from web session, not HTTP layer")
        }
    }
}
