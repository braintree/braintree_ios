import XCTest
@testable import BraintreeCard

class BTCard_Tests: XCTestCase {

    func testInitialization_withoutParameters() {
        let card = BTCard()

        card.number = "4111111111111111"
        card.expirationMonth = "12"
        card.expirationYear = "2038"
        card.cvv = "123"

        XCTAssertEqual(card.number, "4111111111111111")
        XCTAssertEqual(card.expirationMonth, "12")
        XCTAssertEqual(card.expirationYear, "2038")
        XCTAssertNil(card.postalCode)
        XCTAssertEqual(card.cvv, "123")
    }

    // MARK: - Non-GraphQL Parameters

    func testParameters_setsAllParameters() {
        let card = BTCard()
        card.number = "4111111111111111"
        card.expirationMonth = "12"
        card.expirationYear = "2038"
        card.cvv = "123"
        card.cardholderName = "Brian Tree"
        card.firstName = "Brian"
        card.lastName = "Tree"
        card.company = "Braintree"
        card.postalCode = "11111"
        card.streetAddress = "123 Main St."
        card.extendedAddress = "Apt 2"
        card.locality = "Chicago"
        card.region = "IL"
        card.countryName = "US"
        card.countryCodeAlpha2 = "US"
        card.countryCodeAlpha3 = "USA"
        card.countryCodeNumeric = "123"
        card.shouldValidate = true
        
        let params = card.parameters()
        
        XCTAssertEqual(params.variables.input.creditCard.number,  "4111111111111111")
        XCTAssertEqual(params.variables.input.creditCard.expirationMonth,  "12")
        XCTAssertEqual(params.variables.input.creditCard.expirationYear,  "2038")
        XCTAssertEqual(params.variables.input.creditCard.cvv,  "123")
        XCTAssertEqual(params.variables.input.creditCard.cardholderName, "Brian Tree")
        XCTAssertEqual(params.variables.input.creditCard.billingAddress?.firstName, "Brian")
        XCTAssertEqual(params.variables.input.creditCard.billingAddress?.lastName, "Tree")
        XCTAssertEqual(params.variables.input.creditCard.billingAddress?.company, "Braintree")
        XCTAssertEqual(params.variables.input.creditCard.billingAddress?.postalCode, "11111")
        XCTAssertEqual(params.variables.input.creditCard.billingAddress?.streetAddress, "123 Main St.")
        XCTAssertEqual(params.variables.input.creditCard.billingAddress?.extendedAddress, "Apt 2")
        XCTAssertEqual(params.variables.input.creditCard.billingAddress?.locality, "Chicago")
        XCTAssertEqual(params.variables.input.creditCard.billingAddress?.region,  "IL")
        XCTAssertEqual(params.variables.input.creditCard.billingAddress?.countryName,  "US")
        XCTAssertEqual(params.variables.input.creditCard.billingAddress?.countryCodeAlpha2,  "US")
        XCTAssertEqual(params.variables.input.creditCard.billingAddress?.countryCodeAlpha3,  "USA")
        XCTAssertEqual(params.variables.input.creditCard.billingAddress?.countryCodeNumeric,  "123")
        XCTAssertEqual(params.variables.input.options.validate,  card.shouldValidate)
    }

    // MARK: - graphQLParameters
    
    let graphQLQuery = """
    mutation TokenizeCreditCard($input: TokenizeCreditCardInput!) {\
      tokenizeCreditCard(input: $input) {\
        token\
        creditCard {\
          brand\
          expirationMonth\
          expirationYear\
          cardholderName\
          last4\
          bin\
          binData {\
            prepaid\
            healthcare\
            debit\
            durbinRegulated\
            commercial\
            payroll\
            issuingBank\
            countryOfIssuance\
            productId\
          }\
        }\
      }\
    }
    """
    
    let graphQLQueryWithAuthInsightRequested = """
    mutation TokenizeCreditCard($input: TokenizeCreditCardInput!, $authenticationInsightInput: AuthenticationInsightInput!) {\
      tokenizeCreditCard(input: $input) {\
        token\
        creditCard {\
          brand\
          expirationMonth\
          expirationYear\
          cardholderName\
          last4\
          bin\
          binData {\
            prepaid\
            healthcare\
            debit\
            durbinRegulated\
            commercial\
            payroll\
            issuingBank\
            countryOfIssuance\
            productId\
          }\
        }\
        authenticationInsight(input: $authenticationInsightInput) {\
          customerAuthenticationRegulationEnvironment\
        }\
      }\
    }
    """

    func testGraphQLParameters_whenInitializedWithInitWithParameters_returnsExpectedValues() {
        let card = BTCard()
        card.number = "4111111111111111"
        card.expirationMonth = "12"
        card.expirationYear = "20"
        card.cvv = "123"
        card.cardholderName = "Brian Tree"
        card.firstName = "Joe"
        card.lastName = "Smith"
        card.company = "Company"
        card.postalCode = "94107"
        card.streetAddress = "123 Townsend St"
        card.extendedAddress = "Unit 1"
        card.locality = "San Francisco"
        card.region = "CA"
        card.countryName = "United States of America"
        card.countryCodeAlpha2 = "US"
        card.countryCodeAlpha3 = "USA"
        card.countryCodeNumeric = "123"
        card.shouldValidate = false

        let params = card.parameters()
        
        XCTAssertEqual(params.variables.input.options.validate,  false)
        XCTAssertNotNil(params.query)
    }

    func testGraphQLParameters_whenDoingCVVOnly_returnsExpectedValue() {
        let card = BTCard()
        card.cvv = "321"

        let params = card.parameters()
        
        XCTAssertEqual(params.variables.input.creditCard.cvv, "321")
        XCTAssertEqual(params.operationName, "TokenizeCreditCard")
        XCTAssertNotNil(params.query)
        XCTAssertEqual(params.variables.input.options.validate,  false)
        
        XCTAssertNil(params.variables.input.creditCard.number)
        XCTAssertNil(params.variables.input.creditCard.billingAddress?.firstName)
        XCTAssertNil(params.variables.input.creditCard.cardholderName)
    }
    
    func testGraphQLParameters_whenMerchantAccountIDIsPresent_andAuthInsightRequestedIsTrue_requestsAuthInsight() {
        let card = BTCard()
        card.number = "5111111111111111"
        card.authenticationInsightRequested = true
        card.merchantAccountID = "some id"
        
        let params = card.parameters()
        
        XCTAssertEqual(params.query, graphQLQueryWithAuthInsightRequested)
        XCTAssertEqual(params.variables.input.creditCard.number, "5111111111111111")
        XCTAssertEqual(params.variables.input.options.validate,  false)
        XCTAssertEqual(params.variables.input.authenticationInsightInput?.merchantAccountId, "some id")
        
        XCTAssertNil(params.variables.input.creditCard.cvv)
        XCTAssertNil(params.variables.input.creditCard.billingAddress?.firstName)
        XCTAssertNil(params.variables.input.creditCard.cardholderName)
    }
    
    func testGraphQLParameters_whenMerchantAccountIDIsPresent_andAuthInsightRequestedIsFalse_doesNotRequestAuthInsight() {
        let card = BTCard()
        card.number = "6111111111111111"
        card.authenticationInsightRequested = false
        card.merchantAccountID = "some id"
        
        let params = card.parameters()
        
        XCTAssertEqual(params.variables.input.creditCard.number, "6111111111111111")
        XCTAssertEqual(params.operationName, "TokenizeCreditCard")
        XCTAssertNotNil(params.query)
        XCTAssertEqual(params.variables.input.options.validate,  false)
        
        XCTAssertNil(params.variables.input.authenticationInsightInput?.merchantAccountId, "some id")
    }
    
    func testGraphQLParameters_whenMerchantAccountIDIsNil_andAuthInsightRequestedIsTrue_requestsAuthInsight() {
        let card = BTCard()
        card.number = "7111111111111111"
        card.authenticationInsightRequested = true
        card.merchantAccountID = nil
        
        let params = card.parameters()
        printEncodableObject(params)
        
        XCTAssertEqual(params.variables.input.creditCard.number, "7111111111111111")
        XCTAssertEqual(params.operationName, "TokenizeCreditCard")
        XCTAssertNotNil(params.query)
        XCTAssertEqual(params.variables.input.options.validate,  false)
        
        XCTAssertNotNil(params.variables.input.authenticationInsightInput)
    }
    
    func printEncodableObject<T: Encodable>(_ object: T) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted // Makes the JSON easier to read
        do {
            let jsonData = try encoder.encode(object)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("Encoded JSON:\n\(jsonString)")
            }
        } catch {
            print("Failed to encode object: \(error)")
        }
    }
    
    func testGraphQLParameters_whenMerchantAccountIDIsNil_andAuthInsightRequestedIsFalse_doesNotRequestAuthInsight() {
        let card = BTCard()
        card.number = "8111111111111111"
        card.authenticationInsightRequested = false
        card.merchantAccountID = nil
        
        let params = card.parameters()
        
        XCTAssertEqual(params.variables.input.creditCard.number, "8111111111111111")
        XCTAssertEqual(params.operationName, "TokenizeCreditCard")
        XCTAssertNotNil(params.query)
        XCTAssertEqual(params.variables.input.options.validate,  false)
        
        XCTAssertNil(params.variables.input.authenticationInsightInput)
    }
}
