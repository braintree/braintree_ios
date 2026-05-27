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
            countryCodeAlpha2: "DE",
            postalCode: "09456",
            region: "Annaberg-buchholz"
        )

        sepaDirectDebitRequest = BTSEPADirectDebitRequest(
            accountHolderName: "John Doe",
            iban: "DE89370400440532013000",
            customerID: "A0E243A0A200491D929D",
            billingAddress: billingAddress,
            mandateType: .recurrent,
            merchantAccountID: nil
        )

        sepaClient = BTSEPADirectDebitClient(authorization: BTIntegrationTestsConstants.sandboxClientToken)
    }

    // MARK: - Tokenize

    func testTokenize_withRecurrentMandate_failsWithExpectedError() async {
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

    func testTokenize_withOneOffMandate_failsWithExpectedError() async {
        let request = BTSEPADirectDebitRequest(
            accountHolderName: "John Doe",
            iban: "DE89370400440532013000",
            customerID: "B1F354B1B311502E030E",
            billingAddress: billingAddress,
            mandateType: .oneOff,
            merchantAccountID: nil
        )

        do {
            _ = try await sepaClient.tokenize(request)
            XCTFail("Expected an error to be returned")
        } catch let error as NSError {
            XCTAssertEqual(error.domain, BTCoreConstants.httpErrorDomain)
            XCTAssertEqual(error.code, 2)

            let httpResponse = error.userInfo[BTCoreConstants.urlResponseKey] as! HTTPURLResponse
            XCTAssertEqual(httpResponse.statusCode, 403)
        }
    }
    
    @MainActor
    func testTokenize_usingTokenizationKey_failsWithAuthorizationError() async {
        sepaClient = BTSEPADirectDebitClient(authorization: BTIntegrationTestsConstants.sandboxTokenizationKey)

        do {
            _ = try await sepaClient.tokenize(sepaDirectDebitRequest)
            XCTFail("Expected an error to be returned")
        } catch let error as NSError {
            XCTAssertEqual(error.domain, BTCoreConstants.httpErrorDomain)
            XCTAssertEqual(error.code, 2)

            let httpResponse = error.userInfo[BTCoreConstants.urlResponseKey] as! HTTPURLResponse
            XCTAssertEqual(httpResponse.statusCode, 500)
        }
    }
}
