import XCTest
@testable import BraintreeTestShared
@testable import BraintreeCore
@testable import BraintreeSEPADirectDebit

class SEPADirectDebitAPI_Tests: XCTestCase {

    var billingAddress: BTPostalAddress!
    var sepaDirectDebitRequest: BTSEPADirectDebitRequest!
    var successApprovalURL: String = ""
    var mockAPIClient: MockAPIClient = MockAPIClient(authorization: "development_client_key")
    let authorization: String = "sandbox_9dbg82cq_dcpspy2brwdjr3qn"
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
            billingAddress: billingAddress,
            mandateType: .oneOff,
            merchantAccountID: "eur_pwpp_multi_account_merchant_account"
        )
        
        successApprovalURL = """
        https://api.test19.stage.paypal.com/directdebit/mandate/authorize?cart_id=1JH42426EL748934W&auth_code=C21_A.AAdcUj4loKRxLtfw336KxbGY7dA7UsLJQTpZU3cE2h49eKkhN1OjFcLxxxzOGVzRiwOzGLlS_cS2BU4ZLKjMnR6lZSG2iQ
        """
    }
    
    func testCreateMandate_properlyFormatsPOSTURL() async throws {
        let api = SEPADirectDebitAPI(apiClient: mockAPIClient)
        mockAPIClient.cannedResponseBody = BTJSON(value: ["message": ["body": ["sepaDebitAccount": [:]]]])
        
        _ = try await api.createMandate(sepaDirectDebitRequest: sepaDirectDebitRequest)
        
        XCTAssertEqual(mockAPIClient.lastPOSTPath, "v1/sepa_debit")
    }

    func testCreateMandate_properlyFormatsPOSTBody() async throws {
        let billingAddress = BTPostalAddress(
            streetAddress: "fake-street-addres",
            extendedAddress: "fake-extended-address",
            locality: "fake-locality",
            countryCodeAlpha2: "fake-country-code",
            postalCode: "fake-postal-code",
            region: "fake-region"
        )
        
        let sepaDirectDebitRequest = BTSEPADirectDebitRequest(
            accountHolderName: "fake-name",
            iban: "fake-iban",
            customerID: "fake-customer-id",
            billingAddress: billingAddress,
            merchantAccountID: "fake-account-id",
            locale: "fr-FR"
        )

        let api = SEPADirectDebitAPI(apiClient: mockAPIClient)
        
        mockAPIClient.cannedResponseBody = BTJSON(value: ["message": ["body": ["sepaDebitAccount": [:]]]])
        
        _ = try await api.createMandate(sepaDirectDebitRequest: sepaDirectDebitRequest)
        
        let lastPOSTParameters = mockAPIClient.lastPOSTParameters!
        XCTAssertEqual(lastPOSTParameters["merchant_account_id"] as! String, "fake-account-id")
        XCTAssertEqual(lastPOSTParameters["cancel_url"] as! String, "sdk.ios.braintree://sepa/cancel")
        XCTAssertEqual(lastPOSTParameters["return_url"] as! String, "sdk.ios.braintree://sepa/success")
        XCTAssertEqual(lastPOSTParameters["locale"] as! String, "fr-FR")
        
        let sepaDebit = lastPOSTParameters["sepa_debit"] as! [String: Any]
        XCTAssertEqual(sepaDebit["merchant_or_partner_customer_id"] as! String, "fake-customer-id")
        XCTAssertEqual(sepaDebit["mandate_type"] as! String, "ONE_OFF")
        XCTAssertEqual(sepaDebit["account_holder_name"] as! String, "fake-name")
        XCTAssertEqual(sepaDebit["iban"] as! String, "fake-iban")
        
        let billingAddressFields = sepaDebit["billing_address"] as! [String: String]
        XCTAssertEqual(billingAddressFields["address_line_1"], "fake-street-addres")
        XCTAssertEqual(billingAddressFields["address_line_2"], "fake-extended-address")
        XCTAssertEqual(billingAddressFields["admin_area_1"], "fake-locality")
        XCTAssertEqual(billingAddressFields["admin_area_2"], "fake-region")
        XCTAssertEqual(billingAddressFields["postal_code"], "fake-postal-code")
        XCTAssertEqual(billingAddressFields["country_code"], "fake-country-code")
    }
    
    func testCreateMandate_onSuccessfulHttpResponse_returnsCreateMandateResult() async throws {
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
        
        let result = try await api.createMandate(sepaDirectDebitRequest: sepaDirectDebitRequest)
        
        XCTAssertEqual(result.ibanLastFour, "2313")
        XCTAssertEqual(result.approvalURL, successApprovalURL)
        XCTAssertEqual(result.bankReferenceToken, "QkEtWDZDQkpCUU5TWENDVw")
        XCTAssertEqual(result.customerID, "A0E243A0A200491D929D")
        XCTAssertEqual(result.mandateType, BTSEPADirectDebitMandateType.oneOff.description)
    }
    
    func testCreateMandate_onNoBodyReturned_throwsError() async throws {
        let api = SEPADirectDebitAPI(apiClient: mockAPIClient)
        mockAPIClient.cannedResponseError = BTSEPADirectDebitError.noBodyReturned as NSError
        
        do {
            _ = try await api.createMandate(sepaDirectDebitRequest: sepaDirectDebitRequest)
            XCTFail("Expected error to be thrown")
        } catch let error as NSError {
            XCTAssertEqual(error.domain, BTSEPADirectDebitError.errorDomain)
            XCTAssertEqual(error.code, BTSEPADirectDebitError.noBodyReturned.errorCode)
            XCTAssertEqual(error.localizedDescription, BTSEPADirectDebitError.noBodyReturned.localizedDescription)
        }
    }
    
    func testTokenize_onSuccessfulHttpResponse_returnsSEPADirectDebitNonce() async throws {
        let api = SEPADirectDebitAPI(apiClient: mockAPIClient)
        
        let json = BTJSON(
            value: [
                "nonce": "a-fake-payment-method-nonce",
                "details": [
                    "ibanLastChars": "1234",
                    "merchantOrPartnerCustomerId": "a-customer-id",
                    "mandateType": "RECURRENT"
                ]
            ] as [String: Any]
        )
        
        mockAPIClient.cannedResponseBody = json
        
        let nonce = try await api.tokenize(createMandateResult: mockCreateMandateResult)
        
        XCTAssertEqual(nonce.nonce, "a-fake-payment-method-nonce")
        XCTAssertEqual(nonce.ibanLastFour, "1234")
        XCTAssertEqual(nonce.customerID, "a-customer-id")
        XCTAssertEqual(nonce.mandateType?.description, "RECURRENT")
    }
}
