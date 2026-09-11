import Foundation
import XCTest
@testable import BraintreeCore
@testable import BraintreePaymentActions

class BTPaymentActionsClient_IntegrationTests: XCTestCase {
    
    // MARK: - Properties
    
    var paymentActionsClient: BTPaymentActionsClient!
    var cardRequest: BTCreditCard!
    
    // MARK: - Setup
    override func setUp() {
        super.setUp()
        paymentActionsClient = BTPaymentActionsClient(authorization: BTIntegrationTestsConstants.sandboxClientToken)
        
        cardRequest = BTCreditCard(
            cardNumber: "4111111111111111",
            expirationMonth: "12",
            expirationYear: Helpers.shared.futureYear(),
            cvv: "123",
            cardholderName: "Cookie Monster"
        )
    }
    
    // MARK: - submitForPaymentAction
    
    func testSubmitForPaymentAction_autoConfirmAutoCapture_returnsProcessingResult() async throws {
        try XCTSkipIf(true, "Pending Flow 1 (Auto Confirm / Auto Capture) test PAN")
        
        do {
            let result = try await paymentActionsClient.submitForPaymentAction(cardRequest)
            
            XCTAssertEqual(result.type, .completed)
            XCTAssertNil(result.serverAction)
        } catch {
            XCTFail("Unexpected error: \(error.localizedDescription)")
        }
    }
    
    func testSubmitForPaymentAction_manualConfirmAutoCapture_returnServerActionRequiredConfirm() async throws {
        try XCTSkipIf(true, "Pending Flow 2 (MANUAL confirm / AUTOMATIC capture) test PAN")
        
        do {
            let result = try await paymentActionsClient.submitForPaymentAction(cardRequest)
            
            XCTAssertEqual(result.type, .serverActionRequired)
            XCTAssertEqual(result.serverAction, .confirm)
        } catch {
            XCTFail("Unexpected error: \(error.localizedDescription)")
        }
    }
    
    func testSubmitForPaymentAction_autoConfirmManualCapture_returnsProcessingResult() async throws {
        try XCTSkipIf(true, "Pending Flow 3 (AUTOMATIC confirm / MANUAL capture) test PAN")
        
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
        
        do {
            let result = try await paymentActionsClient.submitForPaymentAction(cardRequest)
            
            XCTAssertEqual(result.type, .serverActionRequired)
            XCTAssertEqual(result.serverAction, .confirm)
        } catch {
            XCTFail("Unexpected error: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Failure Path
    
    func testSubmitForPaymentAction_usingTokenizationKey_failsWithAuthrorizationError() {
        let expectation = XCTestExpectation(description: "Submit for Payment Action using tokenization key")
        
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
}
