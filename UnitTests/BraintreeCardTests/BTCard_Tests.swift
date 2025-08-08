import XCTest
@testable import BraintreeCard

class BTCard_Tests: XCTestCase {

    func testInitialization_withoutParameters() {
        let card = BTCard(
            number: "4111111111111111", 
            expirationMonth: "12",
            expirationYear: "2038",
            cvv: "123"
        )

        XCTAssertEqual(card.number, "4111111111111111")
        XCTAssertEqual(card.expirationMonth, "12")
        XCTAssertEqual(card.expirationYear, "2038")
        XCTAssertNil(card.postalCode)
        XCTAssertEqual(card.cvv, "123")
    }

    // MARK: - Non-GraphQL Parameters

    func testParameters_setsAllParameters() {
        let card = BTCard(
            number: "4111111111111111",
            expirationMonth: "12",
            expirationYear: "2038",
            cvv: "123",
            postalCode: "11111",
            cardholderName: "Brian Tree",
            firstName: "Brian",
            lastName: "Tree",
            company: "Braintree",
            streetAddress: "123 Main St.",
            extendedAddress: "Apt 2",
            locality: "Chicago",
            region: "IL",
            countryName: "US",
            countryCodeAlpha2: "US",
            countryCodeAlpha3: "USA",
            countryCodeNumeric: "123",
            shouldValidate: true
        )
        
        let params = try! card.graphQLParameters().toDictionary()
                        
        let variablesDict = params["variables"] as! [String: Any]
        let inputDict = variablesDict["input"] as! [String: Any]
        let creditCardDict = inputDict["creditCard"] as! [String: Any]
                
        XCTAssertEqual(creditCardDict["number"] as? String, "4111111111111111")
        XCTAssertEqual(creditCardDict["expirationMonth"] as? String, "12")
        XCTAssertEqual(creditCardDict["expirationYear"] as? String, "2038")
        XCTAssertEqual(creditCardDict["cvv"] as? String, "123")
        XCTAssertEqual(creditCardDict["cardholderName"] as? String, "Brian Tree")
                
        let billingDict = creditCardDict["billingAddress"] as! [String: Any]
        XCTAssertEqual(billingDict["firstName"] as? String, "Brian")
        XCTAssertEqual(billingDict["lastName"] as? String, "Tree")
        XCTAssertEqual(billingDict["company"] as? String, "Braintree")
        XCTAssertEqual(billingDict["postalCode"] as? String, "11111")
        XCTAssertEqual(billingDict["streetAddress"] as? String, "123 Main St.")
        XCTAssertEqual(billingDict["extendedAddress"] as? String, "Apt 2")
        XCTAssertEqual(billingDict["locality"] as? String, "Chicago")
        XCTAssertEqual(billingDict["region"] as? String, "IL")
        XCTAssertEqual(billingDict["countryName"] as? String, "US")
        XCTAssertEqual(billingDict["countryCodeAlpha2"] as? String, "US")
        XCTAssertEqual(billingDict["countryCode"] as? String, "USA")
        XCTAssertEqual(billingDict["countryCodeNumeric"] as? String, "123")
            
        let optionsDict = inputDict["options"] as! [String: Any]
        XCTAssertEqual(optionsDict["validate"] as? Bool, card.shouldValidate)
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
        let card = BTCard(
            number: "4111111111111111",
            expirationMonth: "12",
            expirationYear: "20",
            cvv: "123",
            postalCode: "94107",
            cardholderName: "Brian Tree",
            firstName: "Joe",
            lastName: "Smith",
            company: "Company",
            streetAddress: "123 Townsend St",
            extendedAddress: "Unit 1",
            locality: "San Francisco",
            region: "CA",
            countryName: "United States of America",
            countryCodeAlpha2: "US",
            countryCodeAlpha3: "USA",
            countryCodeNumeric: "123",
            shouldValidate: false
        )

        let params = try! card.graphQLParameters().toDictionary()
        
        let variablesDict = params["variables"] as! [String: Any]
        let inputDict = variablesDict["input"] as! [String: Any]
        let optionsDict = inputDict["options"] as! [String: Any]
        
        XCTAssertEqual(optionsDict["validate"] as? Bool, false)
        XCTAssertNotNil(params["query"])
    }

    func testGraphQLParameters_whenDoingCVVOnly_returnsExpectedValue() {
        let card = BTCard(cvv: "321")

        let params = try! card.graphQLParameters().toDictionary()

        let operationName = params["operationName"] as! String
        XCTAssertEqual(operationName, "TokenizeCreditCard")

        XCTAssertNotNil(params["query"])

        let variablesDict = params["variables"] as! [String: Any]
        let inputDict = variablesDict["input"] as! [String: Any]
        let creditCardDict = inputDict["creditCard"] as! [String: Any]
        let optionsDict = inputDict["options"] as! [String: Any]

        XCTAssertEqual(creditCardDict["cvv"] as? String, "321")
        XCTAssertEqual(creditCardDict["number"] as? String, "")
        XCTAssertNil(creditCardDict["cardholderName"])

        let billingDict = creditCardDict["billingAddress"] as? [String: Any]
        XCTAssertNil(billingDict?["firstName"])

        XCTAssertEqual(optionsDict["validate"] as? Bool, false)
    }
    
    func testGraphQLParameters_whenMerchantAccountIDIsPresent_andAuthInsightRequestedIsTrue_requestsAuthInsight() {
        let card = BTCard(
            number: "5111111111111111",
            expirationMonth: "12",
            expirationYear: "2038",
            cvv: "1234",
            authenticationInsightRequested: true,
            merchantAccountID: "some id"
        )
        
        let params = try! card.graphQLParameters().toDictionary()
        
        let queryValue = params["query"] as! String
        XCTAssertEqual(queryValue, graphQLQueryWithAuthInsightRequested)

        let variablesDict = params["variables"] as! [String: Any]
        let inputDict = variablesDict["input"] as! [String: Any]
        let creditCardDict = inputDict["creditCard"] as! [String: Any]
        
        XCTAssertEqual(creditCardDict["number"] as? String, "5111111111111111")

        let optionsDict = inputDict["options"] as! [String: Any]
        XCTAssertEqual(optionsDict["validate"] as? Bool, false)

        if let authInsightInput = variablesDict["authenticationInsightInput"] as? [String: Any] {
            XCTAssertEqual(authInsightInput["merchantAccountId"] as? String, "some id")
        } else {
            XCTFail("Expected authenticationInsightInput dictionary not found")
        }

        let billingDict = creditCardDict["billingAddress"] as? [String: Any]
        XCTAssertNil(billingDict?["firstName"])
        XCTAssertNil(creditCardDict["cardholderName"])
    }
    
    func testGraphQLParameters_whenMerchantAccountIDIsPresent_andAuthInsightRequestedIsFalse_doesNotRequestAuthInsight() {
        let card = BTCard(
            number: "6111111111111111",
            expirationMonth: "12",
            expirationYear: "2038",
            cvv: "1234",
            authenticationInsightRequested: false,
            merchantAccountID: "some id"
        )
         
        let params = try! card.graphQLParameters().toDictionary()
        
        let operationName = params["operationName"] as! String
        XCTAssertEqual(operationName, "TokenizeCreditCard")
        XCTAssertNotNil(params["query"])

        let variablesDict = params["variables"] as! [String: Any]
        let inputDict = variablesDict["input"] as! [String: Any]

        let creditCardDict = inputDict["creditCard"] as! [String: Any]
        XCTAssertEqual(creditCardDict["number"] as? String, "6111111111111111")

        let optionsDict = inputDict["options"] as! [String: Any]
        XCTAssertEqual(optionsDict["validate"] as? Bool, false)
        
        if let authInsightDict = inputDict["authenticationInsightInput"] as? [String: Any] {
            XCTAssertNil(authInsightDict["merchantAccountId"], "Expected merchantAccountId to be nil")
        }
    }
    
    func testGraphQLParameters_whenMerchantAccountIDIsNil_andAuthInsightRequestedIsTrue_requestsAuthInsight() {
        let card = BTCard(
            number: "7111111111111111",
            expirationMonth: "12",
            expirationYear: "2038",
            cvv: "1234",
            authenticationInsightRequested: true,
            merchantAccountID: nil
        )
        
        let params = try! card.graphQLParameters().toDictionary()

        let operationName = params["operationName"] as! String
        XCTAssertEqual(operationName, "TokenizeCreditCard")
        XCTAssertNotNil(params["query"])
        
        let variablesDict = params["variables"] as! [String: Any]
        let inputDict = variablesDict["input"] as! [String: Any]

        let creditCardDict = inputDict["creditCard"] as! [String: Any]
        XCTAssertEqual(creditCardDict["number"] as? String, "7111111111111111")

        let optionsDict = inputDict["options"] as! [String: Any]
        XCTAssertEqual(optionsDict["validate"] as? Bool, false)
    }

    func testGraphQLParameters_whenMerchantAccountIDIsNil_andAuthInsightRequestedIsFalse_doesNotRequestAuthInsight() {
        let card = BTCard(
            number: "8111111111111111",
            expirationMonth: "12",
            expirationYear: "2038",
            cvv: "123",
            authenticationInsightRequested: false,
            merchantAccountID: nil
        )
        
        let params = try! card.graphQLParameters().toDictionary()
        
        let operationName = params["operationName"] as! String
        XCTAssertEqual(operationName, "TokenizeCreditCard")
        XCTAssertNotNil(params["query"])

        let variablesDict = params["variables"] as! [String: Any]
        let inputDict = variablesDict["input"] as! [String: Any]

        let creditCardDict = inputDict["creditCard"] as! [String: Any]
        XCTAssertEqual(creditCardDict["number"] as? String, "8111111111111111")

        let optionsDict = inputDict["options"] as! [String: Any]
        XCTAssertEqual(optionsDict["validate"] as? Bool, false)

        XCTAssertNil(inputDict["authenticationInsightInput"])

        let authInsightDict = inputDict["authenticationInsightInput"] as? [String: Any]
        XCTAssertNil(authInsightDict?["merchantAccountID"])
    }
}
