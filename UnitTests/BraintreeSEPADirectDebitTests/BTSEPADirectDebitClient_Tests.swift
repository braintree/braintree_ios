import XCTest
@testable import BraintreeCore
@testable import BraintreeSEPADirectDebit
import BraintreeTestShared
import AuthenticationServices

class BTSEPADirectDebitClient_Tests: XCTestCase {
    
    var billingAddress = BTPostalAddress()
    var sepaDirectDebitRequest = BTSEPADirectDebitRequest()
    var mockAPIClient : MockAPIClient = MockAPIClient(authorization: "development_client_key")!

    override func setUp() {
        mockAPIClient = MockAPIClient(authorization: "development_tokenization_key")!

        billingAddress.streetAddress = "Kantstraße 70"
        billingAddress.extendedAddress = "#170"
        billingAddress.locality = "Freistaat Sachsen"
        billingAddress.region = "Annaberg-buchholz"
        billingAddress.postalCode = "09456"
        billingAddress.countryCodeAlpha2 = "FR"
        
        sepaDirectDebitRequest.accountHolderName = "John Doe"
        sepaDirectDebitRequest.iban = "FR891751244434203564412313"
        sepaDirectDebitRequest.customerID = "A0E243A0A200491D929D"
        sepaDirectDebitRequest.mandateType = .oneOff
        sepaDirectDebitRequest.billingAddress = billingAddress
        sepaDirectDebitRequest.merchantAccountID = "eur_pwpp_multi_account_merchant_account"
    }
    
    func testTokenizeWithPresentationContext_callsCreateMandate_returnsSuccess() {
        let sepaDirectDebitClient = BTSEPADirectDebitClient(apiClient: mockAPIClient)
        let mockSepaDirectDebitAPI = MockSEPADirectDebitAPI()
        
        let mockCreateMandateResult = CreateMandateResult(
            approvalURL: "https://example-success",
            ibanLastFour: "1234",
            customerID: "a-customer-id",
            bankReferenceToken: "a-bank-reference-token",
            mandateType: "ONE_OFF"
        )

        mockSepaDirectDebitAPI.cannedCreateMandateResult = mockCreateMandateResult

        if #available(iOS 13.0, *) {
            sepaDirectDebitClient.tokenize(request: sepaDirectDebitRequest, context: MockViewController()) { nonce, error in
                if nonce != nil {
                    XCTAssertEqual(mockCreateMandateResult.approvalURL, "https://example-success")
                    XCTAssertEqual(mockCreateMandateResult.ibanLastFour, "1234")
                    XCTAssertEqual(mockCreateMandateResult.customerID, "a-customer-id")
                    XCTAssertEqual(mockCreateMandateResult.bankReferenceToken, "a-bank-reference-token")
                    XCTAssertEqual(mockCreateMandateResult.mandateType, "ONE_OFF")
                } else {
                    XCTFail("This request should be successful.")
                }
            }
        } else {
            XCTFail("This should not get here as we use iOS 13.")
        }
    }
    
    func testTokenize_callsCreateMandate_returnsSuccess() {
        let sepaDirectDebitClient = BTSEPADirectDebitClient(apiClient: mockAPIClient)
        let mockSepaDirectDebitAPI = MockSEPADirectDebitAPI()
        
        let mockCreateMandateResult = CreateMandateResult(
            approvalURL: "https://example-success",
            ibanLastFour: "1234",
            customerID: "a-customer-id",
            bankReferenceToken: "a-bank-reference-token",
            mandateType: "ONE_OFF"
        )

        mockSepaDirectDebitAPI.cannedCreateMandateResult = mockCreateMandateResult

        sepaDirectDebitClient.tokenize(request: sepaDirectDebitRequest) { nonce, error in
            if nonce != nil {
                XCTAssertEqual(mockCreateMandateResult.approvalURL, "https://example-success")
                XCTAssertEqual(mockCreateMandateResult.ibanLastFour, "1234")
                XCTAssertEqual(mockCreateMandateResult.customerID, "a-customer-id")
                XCTAssertEqual(mockCreateMandateResult.bankReferenceToken, "a-bank-reference-token")
                XCTAssertEqual(mockCreateMandateResult.mandateType, "ONE_OFF")
            } else {
                XCTFail("This request should be successful.")
            }
        }
    }

    func testTokenizeWithPresentationContext_callsCreateMandateWithError_returnsError() {
        let sepaDirectDebitClient = BTSEPADirectDebitClient(apiClient: mockAPIClient)
        let mockSepaDirectDebitAPI = MockSEPADirectDebitAPI()
        mockSepaDirectDebitAPI.cannedCreateMandateError = NSError(
            domain: "CannedError",
            code: 0,
            userInfo: [NSLocalizedDescriptionKey: "This is a create mandate fake error"]
        )

        sepaDirectDebitClient.sepaDirectDebitAPI = mockSepaDirectDebitAPI
        
        if #available(iOS 13.0, *) {
            sepaDirectDebitClient.tokenize(
                request: sepaDirectDebitRequest, context: MockViewController()) { nonce, error in
                    if error != nil, let error = error as NSError? {
                        XCTAssertEqual(error.domain, "CannedError")
                        XCTAssertEqual(error.code, 0)
                        XCTAssertEqual(error.localizedDescription, "This is a create mandate fake error")
                    } else if nonce != nil {
                        XCTFail("This request should fail.")
                    }
                }
        } else {
            XCTFail("This should not get here as we use iOS 13.")
        }
    }
    
    func testTokenize_callsCreateMandateWithError_returnsError() {
        let sepaDirectDebitClient = BTSEPADirectDebitClient(apiClient: mockAPIClient)
        let mockSepaDirectDebitAPI = MockSEPADirectDebitAPI()
        mockSepaDirectDebitAPI.cannedCreateMandateError = NSError(
            domain: "CannedError",
            code: 0,
            userInfo: [NSLocalizedDescriptionKey: "This is a create mandate fake error"]
        )

        sepaDirectDebitClient.sepaDirectDebitAPI = mockSepaDirectDebitAPI
        
        sepaDirectDebitClient.tokenize(request: sepaDirectDebitRequest) { nonce, error in
            if error != nil, let error = error as NSError? {
                XCTAssertEqual(error.domain, "CannedError")
                XCTAssertEqual(error.code, 0)
                XCTAssertEqual(error.localizedDescription, "This is a create mandate fake error")
            } else if nonce != nil {
                XCTFail("This request should fail.")
            }
        }
    }
    
    @available(iOS 13.0, *)
    func testTokenizeWithPresentationContext_handleWebAuthenticationSessionResultCalledWithCancelledLogin_returnsError() {
        let sepaDirectDebitClient = BTSEPADirectDebitClient(apiClient: mockAPIClient)
        let mockWebAuthenticationSession = MockWebAuthenticationSession()
        
        sepaDirectDebitClient.webAuthenticationSession = mockWebAuthenticationSession

        mockWebAuthenticationSession.cannedErrorResponse = ASWebAuthenticationSessionError(
            _bridgedNSError: NSError(
                domain: ASWebAuthenticationSessionError.errorDomain,
                code: ASWebAuthenticationSessionError.canceledLogin.rawValue,
                userInfo: ["Description": "Mock cancellation error description."]
            )
        )
       
        
            
    }
    
    @available(iOS 13.0, *)
    func testTokenize_handleWebAuthenticationSessionResultCalledWithCancelledLogin_returnsError() {
        let sepaDirectDebitClient = BTSEPADirectDebitClient(apiClient: mockAPIClient)
        let mockWebAuthenticationSession = MockWebAuthenticationSession()
        
        sepaDirectDebitClient.webAuthenticationSession = mockWebAuthenticationSession

        mockWebAuthenticationSession.cannedErrorResponse = ASWebAuthenticationSessionError(
            _bridgedNSError: NSError(
                domain: ASWebAuthenticationSessionError.errorDomain,
                code: ASWebAuthenticationSessionError.canceledLogin.rawValue,
                userInfo: ["Description": "Mock cancellation error description."]
            )
        )
            
            
    }
}
