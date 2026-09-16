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
        let client = try await makePaymentActionsClient(confirmationMethod: "AUTOMATIC", captureMethod: "AUTOMATIC")
        let result = try await client.submitForPaymentAction(cardRequest)
        
        XCTAssertEqual(result.type, .completed)
    }
    
    func testSubmitForPaymentAction_manualConfirmAutoCapture_returnServerActionRequiredConfirm() async throws {
        let client = try await makePaymentActionsClient(confirmationMethod: "MANUAL", captureMethod: "AUTOMATIC")
        let result = try await client.submitForPaymentAction(cardRequest)
        
        XCTAssertEqual(result.type, .serverActionRequired)
        let serverActionResult = try XCTUnwrap(result as? BTServerActionRequiredResult)
        XCTAssertEqual(serverActionResult.serverAction, .confirm)
    }
    
    func testSubmitForPaymentAction_autoConfirmManualCapture_returnsProcessingResult() async throws {
        let client = try await makePaymentActionsClient(confirmationMethod: "AUTOMATIC", captureMethod: "MANUAL")
        let result = try await client.submitForPaymentAction(cardRequest)
        
        XCTAssertEqual(result.type, .serverActionRequired)
        let serverActionResult = try XCTUnwrap(result as? BTServerActionRequiredResult)
        XCTAssertEqual(serverActionResult.serverAction, .capture)
    }
    
    func testSubmitForPaymentAction_flow4_manualConfirmManualCapture_returnsServerActionRequiredConfirm() async throws {
        let client = try await makePaymentActionsClient(confirmationMethod: "MANUAL", captureMethod: "MANUAL")
        let result = try await client.submitForPaymentAction(cardRequest)
        
        XCTAssertEqual(result.type, .serverActionRequired)
        let serverActionResult = try XCTUnwrap(result as? BTServerActionRequiredResult)
        XCTAssertEqual(serverActionResult.serverAction, .confirm)
    }
    
    // MARK: - Failure Path
    
    func testSubmitForPaymentAction_usingTokenizationKey_failsWithAuthrorizationError() async throws {
        let client = BTPaymentActionsClient(authorization: BTIntegrationTestsConstants.sandboxTokenizationKey)
        
        do {
            _ = try await client.submitForPaymentAction(cardRequest)
            XCTFail("Expected an error to be thrown")
        } catch {
            let nsError = error as NSError
            XCTAssertEqual(nsError.domain, BTCoreConstants.httpErrorDomain)
            XCTAssertEqual(nsError.code, 2)
            
            let httpResponse = try XCTUnwrap(nsError.userInfo[BTCoreConstants.urlResponseKey] as? HTTPURLResponse)
            XCTAssertEqual(httpResponse.statusCode, 422)
        }
    }
    
    // MARK: Helpers
    
    /// Fetches a client token configured for the given confirm/capture combination and builds a fresh `BTPaymentActionsClient` from it.
    /// The sever decides which flow triggers based on these parameters, so the same test card works for all four combinations.
    private func makePaymentActionsClient(
        confirmationMethod: String,
        captureMethod: String
    ) async throws -> BTPaymentActionsClient {
        let clientToken = try await fetchPaymentActionClientToken(
            confirmationMethod: confirmationMethod,
            captureMethod: captureMethod
        )
        return BTPaymentActionsClient(authorization: clientToken)
    }
    
    /// Standalone port of `BraintreeDemoMerchantAPIClient.fetchPaymentActionClientToken`, kept local to this test target.
    private func fetchPaymentActionClientToken(
        amount: String = "10.00",
        merchantAccountID: String = "stch2nfdfwszytw5",
        confirmationMethod: String,
        captureMethod: String
    ) async throws -> String {
        guard var urlComponents = URLComponents(string: "https://braintree-sample-merchant.herokuapp.com/create_payment_action") else {
            throw NSError(
                domain: "BTPaymentActionsClient_IntegrationTests",
                code: 0,
                userInfo: [
                    NSLocalizedDescriptionKey: "Could not construct create_payment_action URL"
                ]
            )
        }
        urlComponents.queryItems = [
            URLQueryItem(name: "amount", value: amount),
            URLQueryItem(name: "merchant_account_id", value: merchantAccountID),
            URLQueryItem(name: "confirmation_method", value: confirmationMethod),
            URLQueryItem(name: "capture_method", value: captureMethod)
        ]
        
        guard let url = urlComponents.url else {
            throw NSError(
                domain: "BTPaymentActionsClient_IntegrationTests",
                code: 0,
                userInfo: [
                    NSLocalizedDescriptionKey: "Could not build URL from components"
                ]
            )
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        
        do {
            let response = try jsonDecoder.decode(PaymentActionClientTokenResponse.self, from: data)
            return response.clientToken
        } catch {
            let rawBody = String(data: data, encoding: .utf8) ?? "<undecodable body>"
            throw NSError(
                domain: "BTPaymentActionsClient_IntegrationTests",
                code: 0,
                userInfo: [
                    NSLocalizedDescriptionKey: "Failed to decode PaymentActionClientTokenResponse: \(error). Raw body: \(rawBody)"
                ]
            )
        }
    }
    
    /// Mirrors `BraintreeDemoMerchantAPIClient.PaymentActionResponse` / `PaymentActionDetail`
    /// kept local to this test target to avoid a dependency on the Demo app.
    private struct PaymentActionClientTokenResponse: Codable {
        let clientToken: String
        let paymentAction: PaymentActionDetail
    }
    
    private struct PaymentActionDetail: Codable {
        let id: String
        let status: String
    }
}
