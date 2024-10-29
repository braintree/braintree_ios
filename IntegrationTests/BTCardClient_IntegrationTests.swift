import XCTest
@testable import BraintreeCore
@testable import BraintreeCard

class BTCardClient_IntegrationTests: XCTestCase {

    func testTokenizeCard_whenCardHasValidationDisabledAndCardIsInvalid_tokenizesSuccessfully() {
        let apiClient = BTAPIClient(authorization: BTIntegrationTestsConstants.sandboxTokenizationKey)!
        let cardClient = BTCardClient(apiClient: apiClient)
        let expectation = expectation(description: "Tokenize card")
        let card = BTCard(
            number: "123123",
            expirationMonth: "XX",
            expirationYear: "XXXX",
            cvv: "1234"
        )
        
        cardClient.tokenize(card) { tokenizedCard, error in
            guard let tokenizedCard else {
                XCTFail("Expect a nonce to be returned")
                return
            }

            XCTAssertTrue(tokenizedCard.nonce.isValidNonce)
            XCTAssertFalse(tokenizedCard.threeDSecureInfo.wasVerified)
            XCTAssertNil(error)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5)
    }

    func testTokenizeCard_whenCardIsInvalidAndValidationIsEnabled_failsWithExpectedValidationError() {
        let apiClient = BTAPIClient(authorization: BTIntegrationTestsConstants.sandboxClientToken)!
        let cardClient = BTCardClient(apiClient: apiClient)
        let card = BTCard(
            number: "123",
            expirationMonth: "12",
            expirationYear: Helpers.shared.futureYear(),
            cvv: "1234",
            shouldValidate: true
        )

        let expectation = expectation(description: "Tokenize card")

        cardClient.tokenize(card) { tokenizedCard, error in
            guard let error = error as? NSError else {
                XCTFail("Expect an error to be returned")
                return
            }

            XCTAssertNil(tokenizedCard)
            XCTAssertEqual(error.domain, BTCardError.errorDomain)
            XCTAssertEqual(error.code, BTCardError.customerInputInvalid([:]).errorCode)
            XCTAssertEqual(error.localizedDescription, "Input is invalid")
            XCTAssertEqual(error.localizedFailureReason, "Credit card number must be 12-19 digits")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5)
    }

    func testTokenizeCard_whenCardHasValidationDisabledAndCardIsValid_tokenizesSuccessfully() {
        let apiClient = BTAPIClient(authorization: BTIntegrationTestsConstants.sandboxTokenizationKey)!
        let cardClient = BTCardClient(apiClient: apiClient)
        let expectation = expectation(description: "Tokenize card")
        let card = BTCard(
            number: "123",
            expirationMonth: "12",
            expirationYear: Helpers.shared.futureYear(),
            cvv: "1234",
            cardholderName: "Cookie Monster"
        )
        
        cardClient.tokenize(card) { tokenizedCard, error in
            guard let tokenizedCard else {
                XCTFail("Expect a nonce to be returned")
                return
            }

            XCTAssertTrue(tokenizedCard.nonce.isValidNonce)
            XCTAssertNotNil(tokenizedCard.expirationMonth)
            XCTAssertNotNil(tokenizedCard.expirationYear)
            XCTAssertNotNil(tokenizedCard.cardholderName)
            XCTAssertNotNil(tokenizedCard.binData.prepaid)
            XCTAssertNotNil(tokenizedCard.binData.healthcare)
            XCTAssertNotNil(tokenizedCard.binData.debit)
            XCTAssertNotNil(tokenizedCard.binData.durbinRegulated)
            XCTAssertNotNil(tokenizedCard.binData.commercial)
            XCTAssertNotNil(tokenizedCard.binData.payroll)
            XCTAssertNotNil(tokenizedCard.binData.issuingBank)
            XCTAssertNotNil(tokenizedCard.binData.countryOfIssuance)
            XCTAssertNotNil(tokenizedCard.binData.productID)
            XCTAssertFalse(tokenizedCard.threeDSecureInfo.liabilityShiftPossible)
            XCTAssertFalse(tokenizedCard.threeDSecureInfo.liabilityShifted)
            XCTAssertFalse(tokenizedCard.threeDSecureInfo.wasVerified)
            XCTAssertNil(error)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5)
    }

    func testTokenizeCard_whenUsingTokenizationKeyAndCardHasValidationEnabled_failsWithAuthorizationError() {
        let apiClient = BTAPIClient(authorization: BTIntegrationTestsConstants.sandboxTokenizationKey)!
        let cardClient = BTCardClient(apiClient: apiClient)
        let card = BTCard(
            number: "123123",
            expirationMonth: "XX",
            expirationYear: "XXXX",
            cvv: "1234",
            shouldValidate: true
        )

        let expectation = expectation(description: "Tokenize card")
        cardClient.tokenize(card) { tokenizedCard, error in
            guard let error = error as? NSError else {
                XCTFail("Expect an error to be returned")
                return
            }

            XCTAssertNil(tokenizedCard)
            XCTAssertEqual(error.domain, BTCoreConstants.httpErrorDomain)
            XCTAssertEqual(error.code, 2)

            let httpResponse: HTTPURLResponse = error.userInfo[BTCoreConstants.urlResponseKey] as! HTTPURLResponse
            XCTAssertEqual(httpResponse.statusCode, 403)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5)
    }

    func testTokenizeCard_whenUsingClientTokenAndCardHasValidationEnabledAndCardIsValid_tokenizesSuccessfully() {
        let apiClient = BTAPIClient(authorization: BTIntegrationTestsConstants.sandboxClientToken)!
        let cardClient = BTCardClient(apiClient: apiClient)
        let card = BTCard(
            number: "4111111111111111",
            expirationMonth: "12",
            expirationYear: Helpers.shared.futureYear(),
            cvv: "123",
            cardholderName: "Cookie Monster",
            shouldValidate: true
        )

        let expectation = expectation(description: "Tokenize card")

        cardClient.tokenize(card) { tokenizedCard, error in
            guard let tokenizedCard else {
                XCTFail("Expect a nonce to be returned")
                return
            }

            XCTAssertTrue(tokenizedCard.nonce.isValidNonce)
            XCTAssertFalse(tokenizedCard.threeDSecureInfo.wasVerified)
            XCTAssertNil(error)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5)
    }

    func testTokenizeCard_whenUsingVersionThreeClientTokenAndCardHasValidationEnabledAndCardIsValid_tokenizesSuccessfully() {
        let apiClient = BTAPIClient(authorization: BTIntegrationTestsConstants.sandboxClientTokenVersion3)!
        let cardClient = BTCardClient(apiClient: apiClient)
        let card = BTCard(
            number: "4111111111111111",
            expirationMonth: "12",
            expirationYear: Helpers.shared.futureYear(),
            cvv: "123",
            shouldValidate: true
        )

        let expectation = expectation(description: "Tokenize card")

        cardClient.tokenize(card) { tokenizedCard, error in
            guard let tokenizedCard else {
                XCTFail("Expect a nonce to be returned")
                return
            }

            XCTAssertTrue(tokenizedCard.nonce.isValidNonce)
            XCTAssertFalse(tokenizedCard.threeDSecureInfo.wasVerified)
            XCTAssertNil(error)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5)
    }
}
