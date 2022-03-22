import XCTest
@testable import BraintreeCore
@testable import BraintreeSEPADirectDebit

class SEPADirectDebitAPI_Tests: XCTestCase {
    var billingAddress = BTPostalAddress()
    var sepaDirectDebitRequest = BTSEPADirectDebitRequest()

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
    }

    func testBuildHttpRequest_withAllParams() {
        let expectedHTTPBody = """
        {
            "sepa_debit":{
                "customer_id":"A0E243A0A200491D929D",
                "mandate_type":"ONE_OFF",
                "account_holder_name":"John Doe",
                "iban":"FR891751244434203564412313",
                "billing_address":{
                    "admin_area_2":"Annaberg-buchholz",
                    "country_code":"FR",
                    "address_line_2":"#170",
                    "address_line_1":"Kantstraße 70",
                    "admin_area_1":"Freistaat Sachsen",
                    "postal_code":"09456"
                }
            },
            "merchant_account_id":"eur_pwpp_multi_account_merchant_account",
            "cancel_url":"com.apple.dt.xctest.tool://sepa/cancel",
            "return_url":"com.apple.dt.xctest.tool://sepa/success"
        }
        """
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .joined()

        let api = SEPADirectDebitAPI()
        let request = api.buildRequest(sepaDirectDebitRequest: sepaDirectDebitRequest)
        let body = String(data: request.httpBody ?? Data(), encoding: .utf8)?.replacingOccurrences(of: "\\/\\/", with: "//").replacingOccurrences(of: "\\", with: "")
        
        XCTAssertEqual(request.url, URL(string: "http://localhost:3000/merchants/pwpp_multi_account_merchant/client_api/v1/sepa_debit"))
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(
            request.allHTTPHeaderFields,
            ["Content-Type": "application/json", "Client-Key": "development_testing_pwpp_multi_account_merchant"]
        )
        XCTAssertEqual(body, expectedHTTPBody)
    }
    
    func testCreateMandate_onSuccessfulHttpResponse_returnsCreateMandateResult() {
        // TODO: in a future PR we should be testing the SEPADirectDebitAPI with the MockAPIClient here instead of MockSEPADirectDebitAPI
        let api = MockSEPADirectDebitAPI()
        let approvalURL = """
        https://api.test19.stage.paypal.com/directdebit/mandate/authorize?cart_id=1JH42426EL748934W&auth_code=C21_A.AAdcUj4loKRxLtfw336KxbGY7dA7UsLJQTpZU3cE2h49eKkhN1OjFcLxxxzOGVzRiwOzGLlS_cS2BU4ZLKjMnR6lZSG2iQ
        """
        
        api.cannedCreateMandateResult = CreateMandateResult(
            approvalURL: approvalURL,
            ibanLastFour: "2313",
            customerID: "A0E243A0A200491D929D",
            bankReferenceToken: "QkEtWDZDQkpCUU5TWENDVw",
            mandateType: "ONE_OFF"
        )
        
        api.createMandate(sepaDirectDebitRequest: sepaDirectDebitRequest) { result, error in
            if error != nil {
                XCTFail("This request should be successful.")
            } else if result != nil {
                XCTAssertEqual(result?.ibanLastFour, "2313")
                XCTAssertEqual(result?.approvalURL, approvalURL)
                XCTAssertEqual(result?.bankReferenceToken, "QkEtWDZDQkpCUU5TWENDVw")
                XCTAssertEqual(result?.customerID, "A0E243A0A200491D929D")
                XCTAssertEqual(result?.mandateType, BTSEPADirectDebitMandateType.oneOff.description)
            }
        }
    }
    
    func testCreateMandate_onInvalidResponseJSON_returnsError() {
        // TODO: in a future PR we should be testing the SEPADirectDebitAPI with the MockAPIClient here instead of MockSEPADirectDebitAPI
        let api = MockSEPADirectDebitAPI()
        api.cannedCreateMandateError = NSError(domain: "CannedError", code: 0, userInfo: [NSLocalizedDescriptionKey: "This is a fake error"])
        
        api.createMandate(sepaDirectDebitRequest: sepaDirectDebitRequest) { result, error in
            if error != nil, let error = error as NSError? {
                XCTAssertEqual(error.domain, "CannedError")
                XCTAssertEqual(error.code, 0)
                XCTAssertEqual(error.localizedDescription, "This is a fake error")
            } else if result != nil {
                XCTFail("This request should fail.")
            }
        }
    }
    
    func testCreateMandate_merchantAccountIDNotIncluded_returnsCreateMandateResult() {
        // TODO: When in sandbox we should test to confirm that not passing a merchant account ID uses the default merchant account ID as expected
    }
    
    func testCreateMandate_createMandateResultContainsNil_returnsError() {
        // TODO: when BTAPIClient is used in SEPADirectDebitAPI we need to tested that we return the SEPADirectDebitError.invalidResult if any fields are nil during decoding
    }
    
}
