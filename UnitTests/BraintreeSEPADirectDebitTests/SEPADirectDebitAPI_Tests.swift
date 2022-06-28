import XCTest
import BraintreeTestShared
@testable import BraintreeCore
@testable import BraintreeSEPADirectDebit

class SEPADirectDebitAPI_Tests: XCTestCase {
    var billingAddress = BTPostalAddress()
    var sepaDirectDebitRequest = BTSEPADirectDebitRequest()
    var successApprovalURL: String = ""
    var mockAPIClient : MockAPIClient = MockAPIClient(authorization: "development_client_key")!
    var mockCreateMandateResult = CreateMandateResult(json:
        BTJSON(
            value: [
                "message": [
                    "body": [
                        "sepaDebitAccount": [
                            "approvalUrl": "https://api.test19.stage.paypal.com/directdebit/mandate/authorize?cart_id=1JH42426EL748934W&auth_code=C21_A.AAdcUj4loKRxLtfw336KxbGY7dA7UsLJQTpZU3cE2h49eKkhN1OjFcLxxxzOGVzRiwOzGLlS_cS2BU4ZLKjMnR6lZSG2iQ",
                            "last4": "1234",
                            "merchantOrPartnerCustomerId": "a-customer-id",
                            "bankReferenceToken": "a-bank-reference-token",
                            "mandateType": "ONE_OFF"
                        ]
                    ]
                ]
            ]
        )
    )

    override func setUp() {
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
        
        successApprovalURL = """
        https://api.test19.stage.paypal.com/directdebit/mandate/authorize?cart_id=1JH42426EL748934W&auth_code=C21_A.AAdcUj4loKRxLtfw336KxbGY7dA7UsLJQTpZU3cE2h49eKkhN1OjFcLxxxzOGVzRiwOzGLlS_cS2BU4ZLKjMnR6lZSG2iQ
        """
    }
    
    func testCreateMandate_onSuccessfulHttpResponse_returnsCreateMandateResult() {
        let api = SEPADirectDebitAPI(apiClient: mockAPIClient)
        mockAPIClient.cannedResponseBody = BTJSON(
            value: [
                "message": [
                    "body": [
                        "sepaDebitAccount": [
                            "approvalUrl": successApprovalURL,
                            "last4": "2313",
                            "merchantOrPartnerCustomerId": "A0E243A0A200491D929D",
                            "bankReferenceToken": "QkEtWDZDQkpCUU5TWENDVw",
                            "mandateType": "ONE_OFF"
                        ]
                    ]
                ]
            ]
        )
        
        api.createMandate(sepaDirectDebitRequest: sepaDirectDebitRequest) { result, error in
            if error != nil {
                XCTFail("This request should be successful.")
            } else if result != nil {
                XCTAssertEqual(result?.ibanLastFour, "2313")
                XCTAssertEqual(result?.approvalURL, self.successApprovalURL)
                XCTAssertEqual(result?.bankReferenceToken, "QkEtWDZDQkpCUU5TWENDVw")
                XCTAssertEqual(result?.customerID, "A0E243A0A200491D929D")
                XCTAssertEqual(result?.mandateType, BTSEPADirectDebitMandateType.oneOff.description)
            }
        }
    }
    
    func testCreateMandate_onNoBodyReturned_returnsError() {
        let api = SEPADirectDebitAPI(apiClient: mockAPIClient)
        mockAPIClient.cannedResponseError = SEPADirectDebitError.noBodyReturned as NSError
        
        api.createMandate(sepaDirectDebitRequest: sepaDirectDebitRequest) { result, error in
            if error != nil, let error = error as NSError? {
                XCTAssertEqual(error.domain, SEPADirectDebitError.errorDomain)
                XCTAssertEqual(error.code, SEPADirectDebitError.noBodyReturned.errorCode)
                XCTAssertEqual(error.localizedDescription, SEPADirectDebitError.noBodyReturned.localizedDescription)
            } else if result != nil {
                XCTFail("This request should fail.")
            }
        }
    }
    
    func testTokenize_onSuccessfulHttpResponse_returnsSEPADirectDebitNonce() {
        let api = SEPADirectDebitAPI(apiClient: mockAPIClient)
        
        let json = BTJSON(
            value: [
                "nonce": "a-fake-payment-method-nonce",
                "details": [
                    "last4": "1234",
                    "customerId": "a-customer-id",
                    "mandateType": "RECURRENT"
                ]
            ]
        )
        
        mockAPIClient.cannedResponseBody = json
        
        api.tokenize(createMandateResult: mockCreateMandateResult) { nonce, error in
            if error != nil {
                XCTFail("This request should be successful.")
            } else if nonce != nil {
                XCTAssertEqual(nonce?.nonce, "a-fake-payment-method-nonce")
                XCTAssertEqual(nonce?.ibanLastFour, "1234")
                XCTAssertEqual(nonce?.customerID, "a-customer-id")
                XCTAssertEqual(nonce?.mandateType?.description, "RECURRENT")
            }
        }
    }
}
