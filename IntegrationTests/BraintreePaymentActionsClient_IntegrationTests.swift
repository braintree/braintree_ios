import Foundation
import XCTest
@testable import BraintreeCore
@testable import BraintreePaymentActions

class BTPaymentActionsClient_IntegrationTests: XCTestCase {
    
    // MARK: - Properties
    
    var paymentActionsClient: BTPaymentActionsClient!
    
    // MARK: - Setup
    
    override func setUp() {
        super.setUp()
        
        paymentActionsClient = BTPaymentActionsClient(authorization: BTIntegrationTestsConstants.sandboxClientToken)
    }
    
    // MARK: - Happy Path
    
    func testSubmitForPaymentAction_autoConfirmAutoCapture_returnsCompletedResult() async throws {
        try XCTSkipIf(true, "Pending Flow 1 (AUTO confirm / AUTO capture) test PAN")
        
        let cardRequest = BTCardPaymentActionRequest(
            cardNumber: "4111111111111111", // TODO: swap for the documented Flow 1 test PAN
            expirationMonth: "12",
            expirationYear: Helpers.shared.futureYear(),
            cvv: "123",
            cardholderName: "Cookie Monster"
        )
        
        do {
            let result = try await paymentActionsClient.submitForPaymentAction(cardRequest)
            
            XCTAssertEqual(result.type, .completed)
            XCTAssertNil(result.serverAction)
        } catch {
            XCTFail("Unexpected error: \(error.localizedDescription)")
        }
    }
    
    func testSubmitForPaymentAction_flow2_manualConfirmAutoCapture_returnsServerActionRequiredConfirm() async throws {
        try XCTSkipIf(true, "Pending Flow 2 (MANUAL confirm / AUTOMATIC capture) test PAN")
        
        let cardRequest = BTCardPaymentActionRequest(
            cardNumber: "4111111111111111", // TODO: swap for the documented Flow 2 test PAN
            expirationMonth: "12",
            expirationYear: Helpers.shared.futureYear(),
            cvv: "123",
            cardholderName: "Cookie Monster"
        )
        
        do {
            let result = try await paymentActionsClient.submitForPaymentAction(cardRequest)
            
            XCTAssertEqual(result.type, .serverActionRequired)
            XCTAssertEqual(result.serverAction, .confirm)
        } catch {
            XCTFail("Unexpected error: \(error.localizedDescription)")
        }
    }
    
    func testSubmitForPaymentAction_flow3_autoConfirmManualCapture_returnsServerActionRequiredCapture() async throws {
        try XCTSkipIf(true, "Pending Flow 3 (AUTOMATIC confirm / MANUAL capture) test PAN")
        
        let cardRequest = BTCardPaymentActionRequest(
            cardNumber: "4111111111111111", // TODO: swap for the documented Flow 3 test PAN
            expirationMonth: "12",
            expirationYear: Helpers.shared.futureYear(),
            cvv: "123",
            cardholderName: "Cookie Monster"
        )
        
        do {
            let result = try await paymentActionsClient.submitForPaymentAction(cardRequest)
            
            XCTAssertEqual(result.type, .serverActionRequired)
            XCTAssertEqual(result.serverAction, .capture)
        } catch {
            XCTFail("Unexpected error: \(error.localizedDescription)")
        }
    }
    
    func testSubmitForPaymentAction_flow4_manualConfirmManualCapture_returnsServerActionRequiredConfirm() async throws {
        try XCTSkipIf(true, "Pending Flow 4 (MANUAL confirm / MANUAL capture) test PAN")
        
        let cardRequest = BTCardPaymentActionRequest(
            cardNumber: "4111111111111111", // TODO: swap for the documented Flow 4 test PAN
            expirationMonth: "12",
            expirationYear: Helpers.shared.futureYear(),
            cvv: "123",
            cardholderName: "Cookie Monster"
        )
        
        do {
            let result = try await paymentActionsClient.submitForPaymentAction(cardRequest)
            
            XCTAssertEqual(result.type, .serverActionRequired)
            XCTAssertEqual(result.serverAction, .confirm)
        } catch {
            XCTFail("Unexpected error: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Failure Path
    
    func testSubmitForPaymentAction_usingTokenizationKey_failsWithAuthorizationError() {
        paymentActionsClient = BTPaymentActionsClient(authorization: BTIntegrationTestsConstants.sandboxTokenizationKey)
        
        let cardRequest = BTCardPaymentActionRequest(
            cardNumber: "4111111111111111",
            expirationMonth: "12",
            expirationYear: Helpers.shared.futureYear(),
            cvv: "123",
            cardholderName: "Cookie Monster"
        )
        
        let expectation = expectation(description: "Submit for Payment Action using tokenization key")
        
        paymentActionsClient.submitForPaymentAction(cardRequest) { result, error in
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
    
    func testSubmitForPaymentAction_withInvalidCard_returnsValidationError() async {
        let invalidCardRequest = BTCardPaymentActionRequest(
            cardNumber: "123",
            expirationMonth: "12",
            expirationYear: Helpers.shared.futureYear(),
            cvv: "1234"
        )
        
        do {
            _ = try await paymentActionsClient.submitForPaymentAction(invalidCardRequest)
            XCTFail("Expected an error to be returned")
        } catch {
            XCTAssertNotNil(error)
        }
    }
}
