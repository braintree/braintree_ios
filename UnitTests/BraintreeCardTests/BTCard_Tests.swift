import XCTest

// See also BTCard_Internal_Tests
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

        let expectedParameters: [String : Any] = [
            "number": "4111111111111111",
            "expiration_month": "12",
            "expiration_year": "2038",
            "cardholder_name": "Brian Tree",
            "cvv": "123",
            "billing_address": [
                "first_name": "Brian",
                "last_name": "Tree",
                "company": "Braintree",
                "postal_code": "11111",
                "street_address": "123 Main St.",
                "extended_address": "Apt 2",
                "locality": "Chicago",
                "region": "IL",
                "country_name": "US",
                "country_code_alpha2": "US",
                "country_code_alpha3": "USA",
                "country_code_numeric": "123",
            ],
            "options": [
                "validate": 1
            ]
        ]

        XCTAssertEqual(card.parameters() as NSObject, expectedParameters as NSObject)
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

        XCTAssertEqual(card.graphQLParameters() as NSObject, [
            "operationName": "TokenizeCreditCard",
            "query": graphQLQuery,
            "variables": [
                "input": [
                    "creditCard": [
                        "cardholderName": "Brian Tree",
                        "number": "4111111111111111",
                        "expirationMonth": "12",
                        "expirationYear": "20",
                        "cvv": "123",
                        "billingAddress": [
                            "firstName": "Joe",
                            "lastName": "Smith",
                            "company": "Company",
                            "streetAddress": "123 Townsend St",
                            "extendedAddress": "Unit 1",
                            "locality": "San Francisco",
                            "region": "CA",
                            "countryName": "United States of America",
                            "countryCodeAlpha2": "US",
                            "countryCode": "USA",
                            "countryCodeNumeric": "123",
                            "postalCode": "94107"
                        ],
                    ],
                    "options": ["validate": false]
                ]
            ]
        ] as NSObject)
    }

    func testGraphQLParameters_whenDoingCVVOnly_returnsExpectedValue() {
        let card = BTCard()
        card.cvv = "123"

        XCTAssertEqual(card.graphQLParameters() as NSObject, [
            "operationName": "TokenizeCreditCard",
            "query": graphQLQuery,
            "variables": [
                "input": [
                    "creditCard": [
                        "cvv": "123"
                    ],
                    "options": ["validate": false]
                ]
            ]
        ] as NSObject)
    }
    
    func testGraphQLParameters_whenMerchantAccountIDIsPresent_andAuthInsightRequestedIsTrue_requestsAuthInsight() {
        let card = BTCard()
        card.number = "4111111111111111"
        card.authenticationInsightRequested = true
        card.merchantAccountID = "some id"
        
        XCTAssertEqual(card.graphQLParameters() as NSObject, [
            "operationName": "TokenizeCreditCard",
            "query": graphQLQueryWithAuthInsightRequested,
            "variables": [
                "input": [
                    "creditCard": [
                        "number": "4111111111111111",
                    ],
                    "options": [ "validate": false ],
                ],
                "authenticationInsightInput": [
                    "merchantAccountId": "some id"
                ]
            ]
        ] as NSObject)
    }
    
    func testGraphQLParameters_whenMerchantAccountIDIsPresent_andAuthInsightRequestedIsFalse_doesNotRequestAuthInsight() {
        let card = BTCard()
        card.number = "4111111111111111"
        card.authenticationInsightRequested = false
        card.merchantAccountID = "some id"
        
        XCTAssertEqual(card.graphQLParameters() as NSObject, [
            "operationName": "TokenizeCreditCard",
            "query": graphQLQuery,
            "variables": [
                "input": [
                    "creditCard": [
                        "number": "4111111111111111",
                    ],
                    "options": [ "validate": false ],
                ]
            ]
            ] as NSObject)
    }
    
    func testGraphQLParameters_whenMerchantAccountIDIsNil_andAuthInsightRequestedIsTrue_requestsAuthInsight() {
        let card = BTCard()
        card.number = "4111111111111111"
        card.authenticationInsightRequested = true
        card.merchantAccountID = nil
        
        XCTAssertEqual(card.graphQLParameters() as NSObject, [
            "operationName": "TokenizeCreditCard",
            "query": graphQLQueryWithAuthInsightRequested,
            "variables": [
                "input": [
                    "creditCard": [
                        "number": "4111111111111111",
                    ],
                    "options": [ "validate": false ],
                ],
                "authenticationInsightInput": NSDictionary()
            ]
            ] as NSObject)
    }
    
    func testGraphQLParameters_whenMerchantAccountIDIsNil_andAuthInsightRequestedIsFalse_doesNotRequestAuthInsight() {
        let card = BTCard()
        card.number = "4111111111111111"
        card.authenticationInsightRequested = false
        card.merchantAccountID = nil
        
        XCTAssertEqual(card.graphQLParameters() as NSObject, [
            "operationName": "TokenizeCreditCard",
            "query": graphQLQuery,
            "variables": [
                "input": [
                    "creditCard": [
                        "number": "4111111111111111",
                    ],
                    "options": [ "validate": false ],
                ]
            ]
            ] as NSObject)
    }
}
