import XCTest

// See also BTCard_Internal_Tests
class BTCard_Tests: XCTestCase {
    
    // MARK: - Initialization
    
    func testInitialization_savesStandardProperties() {
        let card = BTCard(number: "4111111111111111", expirationMonth:"12", expirationYear:"2038", cvv: "123")

        XCTAssertEqual(card.number, "4111111111111111")
        XCTAssertEqual(card.expirationMonth, "12")
        XCTAssertEqual(card.expirationYear, "2038")
        XCTAssertNil(card.postalCode)
        XCTAssertEqual(card.cvv, "123")
    }

    func testInitialization_acceptsNilCvv() {
        let card = BTCard(number: "4111111111111111", expirationMonth: "12", expirationYear: "2038", cvv: nil)
        XCTAssertNil(card.cvv)
    }

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

    func testInitWithParameters_withAllValuesPresent_setsAllProperties() {
        let card = BTCard(parameters: [
            "number": "4111111111111111",
            "expiration_date": "12/20",
            "cvv": "123",
            "billing_address": [
                "first_name": "Joe",
                "last_name": "Smith",
                "company": "Company",
                "street_address": "123 Townsend St",
                "extended_address": "Unit 1",
                "locality": "San Francisco",
                "region": "CA",
                "country_name": "United States of America",
                "country_code_alpha2": "US",
                "country_code_alpha3": "USA",
                "country_code_numeric": "840",
                "postal_code": "94107"
            ],
            "options": ["validate": true],
            "cardholder_name": "Brian Tree"
            ])

        XCTAssertEqual(card.number, "4111111111111111")
        XCTAssertEqual(card.expirationMonth, "12")
        XCTAssertEqual(card.expirationYear, "20")
        XCTAssertEqual(card.postalCode, "94107")
        XCTAssertEqual(card.cvv, "123")
        XCTAssertTrue(card.shouldValidate)
        XCTAssertEqual(card.cardholderName, "Brian Tree")
        XCTAssertEqual(card.firstName, "Joe")
        XCTAssertEqual(card.lastName, "Smith")
        XCTAssertEqual(card.company, "Company")
        XCTAssertEqual(card.streetAddress, "123 Townsend St")
        XCTAssertEqual(card.extendedAddress, "Unit 1")
        XCTAssertEqual(card.locality, "San Francisco")
        XCTAssertEqual(card.region, "CA")
        XCTAssertEqual(card.countryName, "United States of America")
        XCTAssertEqual(card.countryCodeAlpha2, "US")
        XCTAssertEqual(card.countryCodeAlpha3, "USA")
        XCTAssertEqual(card.countryCodeNumeric, "840")
        XCTAssertEqual(card.postalCode, "94107")
    }

    func testInitWithParameters_withEmptyParameters_setsPropertiesToExpectedValues() {
        let card = BTCard(parameters: [:])

        XCTAssertNil(card.number)
        XCTAssertNil(card.expirationMonth)
        XCTAssertNil(card.expirationYear)
        XCTAssertNil(card.postalCode)
        XCTAssertNil(card.cvv)
        XCTAssertNil(card.cardholderName)
        XCTAssertFalse(card.shouldValidate)
        XCTAssertNil(card.streetAddress)
        XCTAssertNil(card.locality)
        XCTAssertNil(card.region)
        XCTAssertNil(card.countryName)
        XCTAssertNil(card.countryCodeAlpha2)
        XCTAssertNil(card.countryCodeAlpha3)
        XCTAssertNil(card.countryCodeNumeric)
    }

    func testInitWithParameters_withCVVAndPostalCode_setsPropertiesToExpectedValues() {
        let card = BTCard(parameters: [
            "cvv": "123",
            "billing_address": ["postal_code": "94949"],
            ])

        XCTAssertNil(card.number)
        XCTAssertNil(card.expirationMonth)
        XCTAssertNil(card.expirationYear)
        XCTAssertEqual(card.postalCode, "94949")
        XCTAssertEqual(card.cvv, "123")
        XCTAssertFalse(card.shouldValidate)
    }

    func testParameters_whenInitializedWithInitWithParameters_returnsExpectedValues() {
        let card = BTCard(parameters: [
            "number": "4111111111111111",
            "expiration_date": "12/20",
            "cvv": "123",
            "billing_address": [
                "first_name": "Joe",
                "last_name": "Smith",
                "company": "Company",
                "street_address": "123 Townsend St",
                "extended_address": "Unit 1",
                "locality": "San Francisco",
                "region": "CA",
                "country_name": "United States of America",
                "country_code_alpha2": "US",
                "postal_code": "94107"
            ],
            "options": ["validate": false],
            "cardholder_name": "Brian Tree"
            ])

        XCTAssertEqual(card.parameters() as NSObject, [
            "number": "4111111111111111",
            "expiration_date": "12/20",
            "cvv": "123",
            "billing_address": [
                "first_name": "Joe",
                "last_name": "Smith",
                "company": "Company",
                "street_address": "123 Townsend St",
                "extended_address": "Unit 1",
                "locality": "San Francisco",
                "region": "CA",
                "country_name": "United States of America",
                "country_code_alpha2": "US",
                "postal_code": "94107"
            ],
            "options": ["validate": false],
            "cardholder_name": "Brian Tree"
            ] as NSObject)
    }

    // MARK: - Non-GraphQL Parameters
    
    func testParameters_whenInitializedWithCustomParameters_returnsExpectedValues() {
        let card = BTCard(parameters: [
            "cvv": "123",
            "billing_address": ["postal_code": "94949"],
            "options": ["foo": "bar"],
            ])

        XCTAssertEqual(card.parameters() as NSObject, [
            "cvv": "123",
            "billing_address": ["postal_code": "94949"],
            "options": [
                "foo": "bar",
                "validate": false,
            ],
            ] as NSObject)
    }

    func testParameters_whenShouldValidateIsSetToNewValue_returnsExpectedValues() {
        let card = BTCard(parameters: ["options": ["validate": false]])
        card.shouldValidate = true
        XCTAssertEqual(card.parameters() as NSObject, [
            "options": [ "validate": true ],
            ] as NSObject)
    }

    // MARK: - GraphQL Parameters
    
    let graphQLQuery = """
    mutation TokenizeCreditCard($input: TokenizeCreditCardInput!) {\
      tokenizeCreditCard(input: $input) {\
        token\
        creditCard {\
          brand\
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
        let card = BTCard(parameters: [
            "cardholder_name": "Brian Tree",
            "number": "4111111111111111",
            "expiration_date": "12/20",
            "cvv": "123",
            "billing_address": [
                "first_name": "Joe",
                "last_name": "Smith",
                "company": "Company",
                "street_address": "123 Townsend St",
                "extended_address": "Unit 1",
                "locality": "San Francisco",
                "region": "CA",
                "country_name": "United States of America",
                "country_code_alpha2": "US",
                "country_code_alpha3": "USA",
                "postal_code": "94107"
            ],
            "options": ["validate": false]
            ])

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
                            "postalCode": "94107"
                        ],
                    ],
                    "options": ["validate": false]
                ]
            ]
        ] as NSObject)
    }

    func testGraphQLParameters_whenDoingCVVOnly_returnsExpectedValue() {
        let card = BTCard(parameters: ["cvv": "123"])

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

    func testGraphQLParameters_whenInitializedWithCustomParameters_doesNotAddCustomParameters() {
        let card = BTCard(parameters: [
            "cvv": "123",
            "billing_address": ["postal_code": "94949"],
            "options": ["foo": "bar"],
            ])

        XCTAssertEqual(card.graphQLParameters() as NSObject, [
            "operationName": "TokenizeCreditCard",
            "query": graphQLQuery,
            "variables": [
                "input": [
                    "creditCard": [
                        "cvv": "123",
                        "billingAddress": ["postalCode": "94949"],
                    ],
                    "options": [
                        "validate": false,
                    ]
                ]
            ]
        ] as NSObject)
    }

    func testGraphQLParameters_whenShouldValidateIsSetToNewValue_returnsExpectedValues() {
        let card = BTCard(parameters: [
            "cvv": "123",
            "options": ["validate": false]
        ])
        card.shouldValidate = true
        XCTAssertEqual(card.graphQLParameters() as NSObject, [
            "operationName": "TokenizeCreditCard",
            "query": graphQLQuery,
            "variables": [
                "input": [
                    "creditCard": [
                        "cvv": "123",
                    ],
                    "options": [ "validate": true ],
                ]
            ]
        ] as NSObject)
    }
    
    func testGraphQLParameters_whenMerchantAccountIdIsPresent_andAuthInsightRequestedIsTrue_requestsAuthInsight() {
        let card = BTCard()
        card.number = "4111111111111111"
        card.authenticationInsightRequested = true
        card.merchantAccountId = "some id"
        
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
    
    func testGraphQLParameters_whenMerchantAccountIdIsPresent_andAuthInsightRequestedIsFalse_doesNotRequestAuthInsight() {
        let card = BTCard()
        card.number = "4111111111111111"
        card.authenticationInsightRequested = false
        card.merchantAccountId = "some id"
        
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
    
    func testGraphQLParameters_whenMerchantAccountIdIsNil_andAuthInsightRequestedIsTrue_requestsAuthInsight() {
        let card = BTCard()
        card.number = "4111111111111111"
        card.authenticationInsightRequested = true
        card.merchantAccountId = nil
        
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
    
    func testGraphQLParameters_whenMerchantAccountIdIsNil_andAuthInsightRequestedIsFalse_doesNotRequestAuthInsight() {
        let card = BTCard()
        card.number = "4111111111111111"
        card.authenticationInsightRequested = false
        card.merchantAccountId = nil
        
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
