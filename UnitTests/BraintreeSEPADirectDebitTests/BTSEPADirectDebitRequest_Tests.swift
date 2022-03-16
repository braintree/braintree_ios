import XCTest
@testable import BraintreeCore
@testable import BraintreeSEPADirectDebit

class BTSEPADirectDebitRequest_Tests: XCTestCase {

    func testEncoding() throws {
        let expectedJSON = """
{\"sepa_debit\":{\"customer_id\":\"A0E243A0A200491D929D\",\"mandate_type\":\"ONE_OFF\",\"account_holder_name\":\"John Doe\",\"iban\":\"FR891751244434203564412313\",\"billing_address\":{\"admin_area_2\":\"Annaberg-buchholz\",\"country_code\":\"FR\",\"address_line_2\":\"#170\",\"address_line_1\":\"Kantstraße 70\",\"admin_area_1\":\"Freistaat Sachsen\",\"postal_code\":\"09456\"}},\"merchant_account_id\":\"eur_pwpp_multi_account_merchant_account\",\"cancel_url\":\"https:\\/\\/example.com\",\"return_url\":\"https:\\/\\/example.com\"}
"""

        let billingAddress = BTPostalAddress()
        billingAddress.streetAddress = "Kantstraße 70"
        billingAddress.extendedAddress = "#170"
        billingAddress.locality = "Freistaat Sachsen"
        billingAddress.region = "Annaberg-buchholz"
        billingAddress.postalCode = "09456"
        billingAddress.countryCodeAlpha2 = "FR"
        
        let sepaDirectDebitRequest = BTSEPADirectDebitRequest(
            accountHolderName: "John Doe",
            iban: "FR891751244434203564412313",
            customerID: "A0E243A0A200491D929D",
            mandateType: .oneOff,
            billingAddress: billingAddress,
            merchantAccountID: "eur_pwpp_multi_account_merchant_account"
        )
        
        let encodedRequest = try XCTUnwrap(JSONEncoder().encode(sepaDirectDebitRequest))
        let encodedRequestData = String(data: encodedRequest, encoding: .utf8)

        XCTAssertEqual(encodedRequestData, expectedJSON)
    }
}
