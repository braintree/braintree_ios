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
                    ] as [String: Any],
                    "options": ["validate": false]
                ]
            ]
        ] as [String: Any] as NSObject)
    }

    func testGraphQLParameters_whenDoingCVVOnly_returnsExpectedValue() {
        let card = BTCard(cvv: "123")

        XCTAssertEqual(card.graphQLParameters() as NSObject, [
            "operationName": "TokenizeCreditCard",
            "query": graphQLQuery,
            "variables": [
                "input": [
                    "creditCard": ["cvv": "123"] as [String: String],
                    "options": ["validate": false]
                ] as [String: Any]
            ]
        ] as [String: Any] as NSObject)
    }
    
    func testGraphQLParameters_whenMerchantAccountIDIsPresent_andAuthInsightRequestedIsTrue_requestsAuthInsight() {
        let card = BTCard(
            number: "4111111111111111",
            authenticationInsightRequested: true,
            merchantAccountID: "some id"
        )
        
        XCTAssertEqual(card.graphQLParameters() as NSObject, [
            "operationName": "TokenizeCreditCard",
            "query": graphQLQueryWithAuthInsightRequested,
            "variables": [
                "input": [
                    "creditCard": [
                        "number": "4111111111111111",
                    ],
                    "options": [ "validate": false ],
                ] as [String: Any],
                "authenticationInsightInput": [
                    "merchantAccountId": "some id"
                ]
            ]
        ] as [String: Any] as NSObject)
    }
    
    func testGraphQLParameters_whenMerchantAccountIDIsPresent_andAuthInsightRequestedIsFalse_doesNotRequestAuthInsight() {
        let card = BTCard(
            number: "4111111111111111",
            authenticationInsightRequested: false,
            merchantAccountID: "some id"
        )
        
        XCTAssertEqual(card.graphQLParameters() as NSObject, [
            "operationName": "TokenizeCreditCard",
            "query": graphQLQuery,
            "variables": [
                "input": [
                    "creditCard": ["number": "4111111111111111"] as [String: String],
                    "options": ["validate": false],
                ] as [String: Any]
            ]
        ] as [String: Any] as NSObject)
    }
    
    func testGraphQLParameters_whenMerchantAccountIDIsNil_andAuthInsightRequestedIsTrue_requestsAuthInsight() {
        let card = BTCard(
            number: "4111111111111111",
            authenticationInsightRequested: true,
            merchantAccountID: nil
        )
        
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
        ] as [String: Any] as NSObject)
    }
    
    func testGraphQLParameters_whenMerchantAccountIDIsNil_andAuthInsightRequestedIsFalse_doesNotRequestAuthInsight() {
        let card = BTCard(
            number: "4111111111111111",
            authenticationInsightRequested: false,
            merchantAccountID: nil
        )
        
        XCTAssertEqual(card.graphQLParameters() as NSObject, [
            "operationName": "TokenizeCreditCard",
            "query": graphQLQuery,
            "variables": [
                "input": [
                    "creditCard": ["number": "4111111111111111"] as [String: String],
                    "options": [ "validate": false ],
                ] as [String: Any]
            ]
        ] as [String: Any] as NSObject)
    }
}
