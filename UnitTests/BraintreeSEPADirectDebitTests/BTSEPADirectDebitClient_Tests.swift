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

    func testTokenizeWithPresentationContext_callsCreateMandateWithError_returnsError_andSendsAnalytics() {
        let sepaDirectDebitClient = BTSEPADirectDebitClient(apiClient: mockAPIClient)
        let mockSepaDirectDebitAPI = SEPADirectDebitAPI(apiClient: mockAPIClient)
        mockAPIClient.cannedResponseError = NSError(
            domain: "CannedError",
            code: 0,
            userInfo: [NSLocalizedDescriptionKey: "This is a create mandate fake error"]
        )

        sepaDirectDebitClient.sepaDirectDebitAPI = mockSepaDirectDebitAPI
        
        if #available(iOS 13.0, *) {
            sepaDirectDebitClient.tokenize(request: sepaDirectDebitRequest, context: MockViewController()) { nonce, error in
                    if error != nil, let error = error as NSError? {
                        XCTAssertEqual(error.domain, "CannedError")
                        XCTAssertEqual(error.code, 0)
                        XCTAssertEqual(error.localizedDescription, "This is a create mandate fake error")
                        XCTAssertEqual(self.mockAPIClient.postedAnalyticsEvents.last, "ios.sepa-direct-debit.create-mandate.failure")
                    } else if nonce != nil {
                        XCTFail("This request should return an error.")
                    }
                }
        } else {
            XCTFail("This should not get here as we use iOS 13.")
        }
    }
    
    func testTokenize_callsCreateMandateWithError_returnsError_andSendsAnalytics() {
        let sepaDirectDebitClient = BTSEPADirectDebitClient(apiClient: mockAPIClient)
        let mockSepaDirectDebitAPI = SEPADirectDebitAPI(apiClient: mockAPIClient)
        mockAPIClient.cannedResponseError = NSError(
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
                XCTAssertEqual(self.mockAPIClient.postedAnalyticsEvents.last, "ios.sepa-direct-debit.create-mandate.failure")
            } else if nonce != nil {
                XCTFail("This request should return an error.")
            }
        }
    }
    
    func testTokenizeWithPresentationContext_handleWebAuthenticationSessionResultCalledWithCanceledSession_returnsError_andSendsAnalytics() {
        let mockWebAuthenticationSession = MockWebAuthenticationSession()
        let mockSepaDirectDebitAPI = SEPADirectDebitAPI(apiClient: mockAPIClient)
        
        mockAPIClient.cannedResponseBody = BTJSON(
            value: [
                "message": [
                    "body": [
                        "sepaDebitAccount": [
                            "approvalUrl": "https://example-success",
                            "ibanLastFour": "1234",
                            "merchantOrPartnerCustomerId": "a-customer-id",
                            "bankReferenceToken": "a-bank-reference-token",
                            "mandateType": "ONE_OFF"
                        ]
                    ]
                ]
            ]
        )

        mockWebAuthenticationSession.cannedErrorResponse = ASWebAuthenticationSessionError(
            _bridgedNSError: NSError(
                domain: ASWebAuthenticationSessionError.errorDomain,
                code: ASWebAuthenticationSessionError.canceledLogin.rawValue,
                userInfo: ["Description": "Mock cancellation error description."]
            )
        )

        let sepaDirectDebitClient = BTSEPADirectDebitClient(
            apiClient: mockAPIClient,
            webAuthenticationSession: mockWebAuthenticationSession,
            sepaDirectDebitAPI: mockSepaDirectDebitAPI
        )

        if #available(iOS 13.0, *) {
            sepaDirectDebitClient.tokenize(request: sepaDirectDebitRequest, context: MockViewController()) { nonce, error in
                    if error != nil, let error = error as NSError? {
                        XCTAssertEqual(error.domain, SEPADirectDebitError.errorDomain)
                        XCTAssertEqual(error.code, SEPADirectDebitError.webFlowCanceled.errorCode)
                        XCTAssertEqual(error.localizedDescription, SEPADirectDebitError.webFlowCanceled.localizedDescription)
                        XCTAssertEqual(self.mockAPIClient.postedAnalyticsEvents.last, "ios.sepa-direct-debit.web-flow.canceled")
                    } else if nonce != nil {
                        XCTFail("This request should return an error.")
                    }
                }
        } else {
            XCTFail("This should not get here as we use iOS 13.")
        }
    }
    
    func testTokenize_handleWebAuthenticationSessionResultCalledWithCanceledSession_returnsError_andSendsAnalytics() {
        let mockWebAuthenticationSession = MockWebAuthenticationSession()
        let mockSepaDirectDebitAPI = SEPADirectDebitAPI(apiClient: mockAPIClient)

        mockAPIClient.cannedResponseBody = BTJSON(
            value: [
                "message": [
                    "body": [
                        "sepaDebitAccount": [
                            "approvalUrl": "https://example-success",
                            "ibanLastFour": "1234",
                            "merchantOrPartnerCustomerId": "a-customer-id",
                            "bankReferenceToken": "a-bank-reference-token",
                            "mandateType": "ONE_OFF"
                        ]
                    ]
                ]
            ]
        )

        mockWebAuthenticationSession.cannedErrorResponse = ASWebAuthenticationSessionError(
            _bridgedNSError: NSError(
                domain: ASWebAuthenticationSessionError.errorDomain,
                code: ASWebAuthenticationSessionError.canceledLogin.rawValue,
                userInfo: ["Description": "Mock cancellation error description."]
            )
        )

        let sepaDirectDebitClient = BTSEPADirectDebitClient(
            apiClient: mockAPIClient,
            webAuthenticationSession: mockWebAuthenticationSession,
            sepaDirectDebitAPI: mockSepaDirectDebitAPI
        )

        sepaDirectDebitClient.tokenize(request: sepaDirectDebitRequest) { nonce, error in
            if error != nil, let error = error as NSError? {
                XCTAssertEqual(error.domain, SEPADirectDebitError.errorDomain)
                XCTAssertEqual(error.code, SEPADirectDebitError.webFlowCanceled.errorCode)
                XCTAssertEqual(error.localizedDescription, SEPADirectDebitError.webFlowCanceled.localizedDescription)
                XCTAssertEqual(self.mockAPIClient.postedAnalyticsEvents.last, "ios.sepa-direct-debit.web-flow.canceled")
            } else if nonce != nil {
                XCTFail("This request should return an error.")
            }
        }
    }
    
    @available(iOS 13.0, *)
    func testTokenizeWithPresentationContext_handleWebAuthenticationSessionResultCalledWithInvalidContext_returnsError_andSendsAnalytics() {
        let mockWebAuthenticationSession = MockWebAuthenticationSession()
        let mockSepaDirectDebitAPI = SEPADirectDebitAPI(apiClient: mockAPIClient)

        mockAPIClient.cannedResponseBody = BTJSON(
            value: [
                "message": [
                    "body": [
                        "sepaDebitAccount": [
                            "approvalUrl": "https://example-success",
                            "ibanLastFour": "1234",
                            "merchantOrPartnerCustomerId": "a-customer-id",
                            "bankReferenceToken": "a-bank-reference-token",
                            "mandateType": "ONE_OFF"
                        ]
                    ]
                ]
            ]
        )

        mockWebAuthenticationSession.cannedErrorResponse = ASWebAuthenticationSessionError(
            _bridgedNSError: NSError(
                domain: ASWebAuthenticationSessionError.errorDomain,
                code: ASWebAuthenticationSessionError.presentationContextInvalid.rawValue,
                userInfo: ["Description": "Mock cancellation error description."]
            )
        )

        let sepaDirectDebitClient = BTSEPADirectDebitClient(
            apiClient: mockAPIClient,
            webAuthenticationSession: mockWebAuthenticationSession,
            sepaDirectDebitAPI: mockSepaDirectDebitAPI
        )

        sepaDirectDebitClient.tokenize(
            request: sepaDirectDebitRequest,
            context: MockViewController()
        ) { nonce, error in
            if error != nil, let error = error as NSError? {
                XCTAssertEqual(error.domain, SEPADirectDebitError.errorDomain)
                XCTAssertEqual(error.code, SEPADirectDebitError.presentationContextInvalid.errorCode)
                XCTAssertEqual(error.localizedDescription, SEPADirectDebitError.presentationContextInvalid.localizedDescription)
                XCTAssertEqual(self.mockAPIClient.postedAnalyticsEvents.last, "ios.sepa-direct-debit.web-flow.presentation-context-invalid")
            } else if nonce != nil {
                XCTFail("This request should return an error.")
            }
        }
    }
    
    func testTokenize_handleWebAuthenticationSessionResultCalledWithInvalidContext_returnsError_andSendsAnalytics() {
        let mockWebAuthenticationSession = MockWebAuthenticationSession()
        let mockSepaDirectDebitAPI = SEPADirectDebitAPI(apiClient: mockAPIClient)

        mockAPIClient.cannedResponseBody = BTJSON(
            value: [
                "message": [
                    "body": [
                        "sepaDebitAccount": [
                            "approvalUrl": "https://example-success",
                            "last4": "1234",
                            "merchantOrPartnerCustomerId": "a-customer-id",
                            "bankReferenceToken": "a-bank-reference-token",
                            "mandateType": "ONE_OFF"
                        ]
                    ]
                ]
            ]
        )

        mockWebAuthenticationSession.cannedErrorResponse = ASWebAuthenticationSessionError(
            _bridgedNSError: NSError(
                domain: ASWebAuthenticationSessionError.errorDomain,
                code: 3,
                userInfo: ["Description": "Mock invalid context provided error."]
            )
        )

        let sepaDirectDebitClient = BTSEPADirectDebitClient(
            apiClient: mockAPIClient,
            webAuthenticationSession: mockWebAuthenticationSession,
            sepaDirectDebitAPI: mockSepaDirectDebitAPI
        )
        
        sepaDirectDebitClient.tokenize(request: sepaDirectDebitRequest) { nonce, error in
            if error != nil, let error = error as NSError? {
                XCTAssertEqual(error.domain, SEPADirectDebitError.errorDomain)
                XCTAssertEqual(error.code, SEPADirectDebitError.presentationContextInvalid.errorCode)
                XCTAssertEqual(error.localizedDescription, SEPADirectDebitError.presentationContextInvalid.localizedDescription)
                XCTAssertEqual(self.mockAPIClient.postedAnalyticsEvents.last, "ios.sepa-direct-debit.web-flow.presentation-context-invalid")
            } else if nonce != nil {
                XCTFail("This request should return an error.")
            }
        }
    }
    
    @available(iOS 13.0, *)
    func testTokenizeWithPresentationContext_handleWebAuthenticationSessionResultCalledWithInvalidResponseURL_returnsError_andSendsAnalytics() {
        let mockWebAuthenticationSession = MockWebAuthenticationSession()
        let mockSepaDirectDebitAPI = SEPADirectDebitAPI(apiClient: mockAPIClient)

        mockAPIClient.cannedResponseBody = BTJSON(
            value: [
                "message": [
                    "body": [
                        "sepaDebitAccount": [
                            "approvalUrl": "https://example-success",
                            "last4": "1234",
                            "merchantOrPartnerCustomerId": "a-customer-id",
                            "bankReferenceToken": "a-bank-reference-token",
                            "mandateType": "ONE_OFF"
                        ]
                    ]
                ]
            ]
        )

        mockWebAuthenticationSession.cannedResponseURL = URL(string: "invalid-url")

        let sepaDirectDebitClient = BTSEPADirectDebitClient(
            apiClient: mockAPIClient,
            webAuthenticationSession: mockWebAuthenticationSession,
            sepaDirectDebitAPI: mockSepaDirectDebitAPI
        )

        sepaDirectDebitClient.tokenize(request: sepaDirectDebitRequest, context: MockViewController()) { nonce, error in
            if error != nil, let error = error as NSError? {
                XCTAssertEqual(error.domain, SEPADirectDebitError.errorDomain)
                XCTAssertEqual(error.code, SEPADirectDebitError.resultURLInvalid.errorCode)
                XCTAssertEqual(error.localizedDescription, SEPADirectDebitError.resultURLInvalid.localizedDescription)
                XCTAssertEqual(self.mockAPIClient.postedAnalyticsEvents.last, "ios.sepa-direct-debit.web-flow.failure")
            } else if nonce != nil {
                XCTFail("This request should return an error.")
            }
        }
    }
    
    func testTokenize_handleWebAuthenticationSessionResultCalledWithInvalidResponseURL_returnsError_andSendsAnalytics() {
        let mockWebAuthenticationSession = MockWebAuthenticationSession()
        let mockSepaDirectDebitAPI = SEPADirectDebitAPI(apiClient: mockAPIClient)

        mockAPIClient.cannedResponseBody = BTJSON(
            value: [
                "message": [
                    "body": [
                        "sepaDebitAccount": [
                            "approvalUrl": "https://example-success",
                            "last4": "1234",
                            "merchantOrPartnerCustomerId": "a-customer-id",
                            "bankReferenceToken": "a-bank-reference-token",
                            "mandateType": "ONE_OFF"
                        ]
                    ]
                ]
            ]
        )

        mockWebAuthenticationSession.cannedResponseURL = URL(string: "invalid-url")

        let sepaDirectDebitClient = BTSEPADirectDebitClient(
            apiClient: mockAPIClient,
            webAuthenticationSession: mockWebAuthenticationSession,
            sepaDirectDebitAPI: mockSepaDirectDebitAPI
        )

        sepaDirectDebitClient.tokenize(request: sepaDirectDebitRequest) { nonce, error in
            if error != nil, let error = error as NSError? {
                XCTAssertEqual(error.domain, SEPADirectDebitError.errorDomain)
                XCTAssertEqual(error.code, SEPADirectDebitError.resultURLInvalid.errorCode)
                XCTAssertEqual(error.localizedDescription, SEPADirectDebitError.resultURLInvalid.localizedDescription)
                XCTAssertEqual(self.mockAPIClient.postedAnalyticsEvents.last, "ios.sepa-direct-debit.web-flow.failure")
            } else if nonce != nil {
                XCTFail("This request should return an error.")
            }
        }
    }
    
    @available(iOS 13.0, *)
    func testTokenizeWithPresentationContext_handleCreateMandateReturnsNoErrorOrResult_returnsError_andSendsAnalytics() {
        let mockWebAuthenticationSession = MockWebAuthenticationSession()
        let mockSepaDirectDebitAPI = SEPADirectDebitAPI(apiClient: mockAPIClient)

        mockWebAuthenticationSession.cannedErrorResponse = NSError(
            domain: SEPADirectDebitError.errorDomain,
            code: SEPADirectDebitError.noBodyReturned.errorCode,
            userInfo: ["Description": "Mock noBodyReturned error description."]
        )

        let sepaDirectDebitClient = BTSEPADirectDebitClient(
            apiClient: mockAPIClient,
            webAuthenticationSession: mockWebAuthenticationSession,
            sepaDirectDebitAPI: mockSepaDirectDebitAPI
        )
        
        mockAPIClient.cannedResponseBody = nil

        sepaDirectDebitClient.tokenize(request: sepaDirectDebitRequest, context: MockViewController()) { nonce, error in
            if error != nil, let error = error as NSError? {
                XCTAssertEqual(error.domain, SEPADirectDebitError.errorDomain)
                XCTAssertEqual(error.code, SEPADirectDebitError.noBodyReturned.errorCode)
                XCTAssertEqual(error.localizedDescription, SEPADirectDebitError.noBodyReturned.localizedDescription)
                XCTAssertEqual(self.mockAPIClient.postedAnalyticsEvents.last, "ios.sepa-direct-debit.create-mandate.failure")
            } else if nonce != nil {
                XCTFail("This request should return an error.")
            }
        }
    }
    
    func testTokenize_handleCreateMandateReturnsNoErrorOrResult_returnsError_andSendsAnalytics() {
        let mockWebAuthenticationSession = MockWebAuthenticationSession()
        let mockSepaDirectDebitAPI = SEPADirectDebitAPI(apiClient: mockAPIClient)

        mockWebAuthenticationSession.cannedErrorResponse = NSError(
            domain: SEPADirectDebitError.errorDomain,
            code: SEPADirectDebitError.noBodyReturned.errorCode,
            userInfo: ["Description": "Mock resultReturnedNil error description."]
        )

        let sepaDirectDebitClient = BTSEPADirectDebitClient(
            apiClient: mockAPIClient,
            webAuthenticationSession: mockWebAuthenticationSession,
            sepaDirectDebitAPI: mockSepaDirectDebitAPI
        )
        
        mockAPIClient.cannedResponseBody = nil

        sepaDirectDebitClient.tokenize(request: sepaDirectDebitRequest) { nonce, error in
            if error != nil, let error = error as NSError? {
                XCTAssertEqual(error.domain, SEPADirectDebitError.errorDomain)
                XCTAssertEqual(error.code, SEPADirectDebitError.noBodyReturned.errorCode)
                XCTAssertEqual(error.localizedDescription, SEPADirectDebitError.noBodyReturned.localizedDescription)
                XCTAssertEqual(self.mockAPIClient.postedAnalyticsEvents.last, "ios.sepa-direct-debit.create-mandate.failure")
            } else if nonce != nil {
                XCTFail("This request should return an error.")
            }
        }
    }
    
    @available(iOS 13.0, *)
    func testTokenizeWithPresentationContext_handleCreateMandateReturnsInvalidURL_returnsError_andSendsAnalytics() {
        let mockWebAuthenticationSession = MockWebAuthenticationSession()
        let mockSepaDirectDebitAPI = SEPADirectDebitAPI(apiClient: mockAPIClient)

        mockAPIClient.cannedResponseBody = BTJSON(
            value: [
                "message": [
                    "body": [
                        "sepaDebitAccount": [
                            "approvalUrl": "   ",
                            "last4": "1234",
                            "merchantOrPartnerCustomerId": "a-customer-id",
                            "bankReferenceToken": "a-bank-reference-token",
                            "mandateType": "ONE_OFF"
                        ]
                    ]
                ]
            ]
        )

        mockWebAuthenticationSession.cannedErrorResponse = NSError(
            domain: SEPADirectDebitError.errorDomain,
            code: SEPADirectDebitError.approvalURLInvalid.errorCode,
            userInfo: ["Description": "Mock approvalURLInvalid error description."]
        )

        let sepaDirectDebitClient = BTSEPADirectDebitClient(
            apiClient: mockAPIClient,
            webAuthenticationSession: mockWebAuthenticationSession,
            sepaDirectDebitAPI: mockSepaDirectDebitAPI
        )

        sepaDirectDebitClient.tokenize(request: sepaDirectDebitRequest, context: MockViewController()) { nonce, error in
            if error != nil, let error = error as NSError? {
                XCTAssertEqual(error.domain, SEPADirectDebitError.errorDomain)
                XCTAssertEqual(error.code, SEPADirectDebitError.approvalURLInvalid.errorCode)
                XCTAssertEqual(error.localizedDescription, SEPADirectDebitError.approvalURLInvalid.localizedDescription)
                XCTAssertEqual(self.mockAPIClient.postedAnalyticsEvents.last, "ios.sepa-direct-debit.create-mandate.failure")
            } else if nonce != nil {
                XCTFail("This request should return an error.")
            }
        }
    }
    
    func testTokenizeWithPresentationContext_handleWebAuthenticationSessionSuccessURLInvalid_returnsError_andSendsAnalytics() {
        let mockWebAuthenticationSession = MockWebAuthenticationSession()
        let mockSepaDirectDebitAPI = SEPADirectDebitAPI(apiClient: mockAPIClient)

        mockAPIClient.cannedResponseBody = BTJSON(
            value: [
                "message": [
                    "body": [
                        "sepaDebitAccount": [
                            "approvalUrl": "https://example-success",
                            "last4": "1234",
                            "merchantOrPartnerCustomerId": "a-customer-id",
                            "bankReferenceToken": "a-bank-reference-token",
                            "mandateType": "ONE_OFF"
                        ]
                    ]
                ]
            ]
        )

        mockWebAuthenticationSession.cannedResponseURL = nil

        let sepaDirectDebitClient = BTSEPADirectDebitClient(
            apiClient: mockAPIClient,
            webAuthenticationSession: mockWebAuthenticationSession,
            sepaDirectDebitAPI: mockSepaDirectDebitAPI
        )

        if #available(iOS 13.0, *) {
            sepaDirectDebitClient.tokenize(request: sepaDirectDebitRequest, context: MockViewController()) { nonce, error in
                    if error != nil, let error = error as NSError? {
                        XCTAssertEqual(error.domain, SEPADirectDebitError.errorDomain)
                        XCTAssertEqual(error.code, SEPADirectDebitError.authenticationResultNil.errorCode)
                        XCTAssertEqual(error.localizedDescription, SEPADirectDebitError.authenticationResultNil.localizedDescription)
                        XCTAssertEqual(self.mockAPIClient.postedAnalyticsEvents.last, "ios.sepa-direct-debit.web-flow.failure")
                    } else if nonce != nil {
                        XCTFail("This request should return an error.")
                    }
                }
        } else {
            XCTFail("This should not get here as we use iOS 13.")
        }
    }
    
    func testTokenize_handleWebAuthenticationSessionSuccessURLInvalid_returnsError_andSendsAnalytics() {
        let mockWebAuthenticationSession = MockWebAuthenticationSession()
        let mockSepaDirectDebitAPI = SEPADirectDebitAPI(apiClient: mockAPIClient)

        mockAPIClient.cannedResponseBody = BTJSON(
            value: [
                "message": [
                    "body": [
                        "sepaDebitAccount": [
                            "approvalUrl": "https://example-success",
                            "last4": "1234",
                            "merchantOrPartnerCustomerId": "a-customer-id",
                            "bankReferenceToken": "a-bank-reference-token",
                            "mandateType": "ONE_OFF"
                        ]
                    ]
                ]
            ]
        )
        
        mockWebAuthenticationSession.cannedResponseURL = nil
        
        let sepaDirectDebitClient = BTSEPADirectDebitClient(
            apiClient: mockAPIClient,
            webAuthenticationSession: mockWebAuthenticationSession,
            sepaDirectDebitAPI: mockSepaDirectDebitAPI
        )
        
        sepaDirectDebitClient.tokenize(request: sepaDirectDebitRequest) { nonce, error in
            if error != nil, let error = error as NSError? {
                XCTAssertEqual(error.domain, SEPADirectDebitError.errorDomain)
                XCTAssertEqual(error.code, SEPADirectDebitError.authenticationResultNil.errorCode)
                XCTAssertEqual(error.localizedDescription, SEPADirectDebitError.authenticationResultNil.localizedDescription)
                XCTAssertEqual(self.mockAPIClient.postedAnalyticsEvents.last, "ios.sepa-direct-debit.web-flow.failure")
            } else if nonce != nil {
                XCTFail("This request should return an error.")
            }
        }
    }
    
    func testTokenizeWithPresentationContext_callsTokenizeWithAlreadyApprovedMandate_returnsSuccess_andSendsAnalytics() {
        let mockWebAuthenticationSession = MockWebAuthenticationSession()
        let mockSepaDirectDebitAPI = SEPADirectDebitAPI(apiClient: mockAPIClient)

        mockAPIClient.cannedResponseBody = BTJSON(
            value: [
                "message": [
                    "body": [
                        "sepaDebitAccount": [
                            "approvalUrl": "null",
                            "last4": "1234",
                            "merchantOrPartnerCustomerId": "a-customer-id",
                            "bankReferenceToken": "a-bank-reference-token",
                            "mandateType": "ONE_OFF"
                        ]
                    ]
                ]
            ]
        )
        
        let mockTokenizeResponse = BTJSON(
            value: [
                "nonce": "a-fake-payment-method-nonce",
                "details": [
                    "ibanLastChars": "1234",
                    "merchantOrPartnerCustomerId": "a-customer-id",
                    "mandateType": "RECURRENT"
                ]
            ]
        )
        
        mockWebAuthenticationSession.cannedResponseURL = URL(string: "https://example/sepa/success?success=true")
        mockAPIClient.cannedResponseBody = BTJSON(value: mockTokenizeResponse)
        
        let sepaDirectDebitClient = BTSEPADirectDebitClient(
            apiClient: mockAPIClient,
            webAuthenticationSession: mockWebAuthenticationSession,
            sepaDirectDebitAPI: mockSepaDirectDebitAPI
        )
        
        if #available(iOS 13.0, *) {
            sepaDirectDebitClient.tokenize(request: sepaDirectDebitRequest, context: MockViewController()) { nonce, error in
                if error != nil {
                    XCTFail("This request should be successful.")
                } else if nonce != nil {
                    XCTAssertEqual(nonce?.nonce, "a-fake-payment-method-nonce")
                    XCTAssertEqual(nonce?.ibanLastFour, "1234")
                    XCTAssertEqual(nonce?.customerID, "a-customer-id")
                    XCTAssertEqual(nonce?.mandateType?.description, "RECURRENT")
                    XCTAssertEqual(self.mockAPIClient.postedAnalyticsEvents.last, "ios.sepa-direct-debit.tokenize.success")
                }
            }
        } else {
            XCTFail("This should not get here as we use iOS 13.")
        }
    }
    
    func testTokenize_callsTokenizeWithAlreadyApprovedMandate_returnsSuccess_andSendsAnalytics() {
        let mockWebAuthenticationSession = MockWebAuthenticationSession()
        let mockSepaDirectDebitAPI = SEPADirectDebitAPI(apiClient: mockAPIClient)

        mockAPIClient.cannedResponseBody = BTJSON(
            value: [
                "message": [
                    "body": [
                        "sepaDebitAccount": [
                            "approvalUrl": "null",
                            "last4": "1234",
                            "merchantOrPartnerCustomerId": "a-customer-id",
                            "bankReferenceToken": "a-bank-reference-token",
                            "mandateType": "ONE_OFF"
                        ]
                    ]
                ]
            ]
        )
        
        let mockTokenizeResponse = BTJSON(
            value: [
                "nonce": "a-fake-payment-method-nonce",
                "details": [
                    "ibanLastChars": "1234",
                    "merchantOrPartnerCustomerId": "a-customer-id",
                    "mandateType": "RECURRENT"
                ]
            ]
        )
        
        mockWebAuthenticationSession.cannedResponseURL = URL(string: "https://example/sepa/success?success=true")
        mockAPIClient.cannedResponseBody = BTJSON(value: mockTokenizeResponse)

        let sepaDirectDebitClient = BTSEPADirectDebitClient(
            apiClient: mockAPIClient,
            webAuthenticationSession: mockWebAuthenticationSession,
            sepaDirectDebitAPI: mockSepaDirectDebitAPI
        )
        
        sepaDirectDebitClient.tokenize(request: sepaDirectDebitRequest) { nonce, error in
            if error != nil {
                XCTFail("This request should be successful.")
            } else if nonce != nil {
                XCTAssertEqual(nonce?.nonce, "a-fake-payment-method-nonce")
                XCTAssertEqual(nonce?.ibanLastFour, "1234")
                XCTAssertEqual(nonce?.customerID, "a-customer-id")
                XCTAssertEqual(nonce?.mandateType?.description, "RECURRENT")
                XCTAssertEqual(self.mockAPIClient.postedAnalyticsEvents.last, "ios.sepa-direct-debit.tokenize.success")
            }
        }
    }
    
    func testTokenizeWithPresentationContext_callsTokenize_returnsSuccess_andSendsAnalytics() {
        let mockWebAuthenticationSession = MockWebAuthenticationSession()
        let mockSepaDirectDebitAPI = SEPADirectDebitAPI(apiClient: mockAPIClient)

        mockAPIClient.cannedResponseBody = BTJSON(
            value: [
                "message": [
                    "body": [
                        "sepaDebitAccount": [
                            "approvalUrl": "https://example-success",
                            "last4": "1234",
                            "merchantOrPartnerCustomerId": "a-customer-id",
                            "bankReferenceToken": "a-bank-reference-token",
                            "mandateType": "ONE_OFF"
                        ]
                    ]
                ]
            ]
        )
        
        let mockTokenizeResponse = BTJSON(
            value: [
                "nonce": "a-fake-payment-method-nonce",
                "details": [
                    "ibanLastChars": "1234",
                    "merchantOrPartnerCustomerId": "a-customer-id",
                    "mandateType": "RECURRENT"
                ]
            ]
        )
        
        mockWebAuthenticationSession.cannedResponseURL = URL(string: "https://example/sepa/success?success=true")
        mockAPIClient.cannedResponseBody = BTJSON(value: mockTokenizeResponse)

        let sepaDirectDebitClient = BTSEPADirectDebitClient(
            apiClient: mockAPIClient,
            webAuthenticationSession: mockWebAuthenticationSession,
            sepaDirectDebitAPI: mockSepaDirectDebitAPI
        )
        
        if #available(iOS 13.0, *) {
            sepaDirectDebitClient.tokenize(request: sepaDirectDebitRequest, context: MockViewController()) { nonce, error in
                if error != nil {
                    XCTFail("This request should be successful.")
                } else if nonce != nil {
                    XCTAssertEqual(nonce?.nonce, "a-fake-payment-method-nonce")
                    XCTAssertEqual(nonce?.ibanLastFour, "1234")
                    XCTAssertEqual(nonce?.customerID, "a-customer-id")
                    XCTAssertEqual(nonce?.mandateType?.description, "RECURRENT")
                    XCTAssertEqual(self.mockAPIClient.postedAnalyticsEvents.last, "ios.sepa-direct-debit.tokenize.success")
                }
            }
        } else {
            XCTFail("This should not get here as we use iOS 13.")
        }
    }
    
    func testTokenize_callsTokenize_returnsSuccess_andSendsAnalytics() {
        let mockWebAuthenticationSession = MockWebAuthenticationSession()
        let mockSepaDirectDebitAPI = SEPADirectDebitAPI(apiClient: mockAPIClient)

        mockAPIClient.cannedResponseBody = BTJSON(
            value: [
                "message": [
                    "body": [
                        "sepaDebitAccount": [
                            "approvalUrl": "https://example-success",
                            "last4": "1234",
                            "merchantOrPartnerCustomerId": "a-customer-id",
                            "bankReferenceToken": "a-bank-reference-token",
                            "mandateType": "ONE_OFF"
                        ]
                    ]
                ]
            ]
        )
        
        let mockTokenizeResponse = BTJSON(
            value: [
                "nonce": "a-fake-payment-method-nonce",
                "details": [
                    "ibanLastChars": "1234",
                    "merchantOrPartnerCustomerId": "a-customer-id",
                    "mandateType": "RECURRENT"
                ]
            ]
        )
        
        mockWebAuthenticationSession.cannedResponseURL = URL(string: "https://example/sepa/success?success=true")
        mockAPIClient.cannedResponseBody = BTJSON(value: mockTokenizeResponse)

        let sepaDirectDebitClient = BTSEPADirectDebitClient(
            apiClient: mockAPIClient,
            webAuthenticationSession: mockWebAuthenticationSession,
            sepaDirectDebitAPI: mockSepaDirectDebitAPI
        )
        
        sepaDirectDebitClient.tokenize(request: sepaDirectDebitRequest) { nonce, error in
            if error != nil {
                XCTFail("This request should be successful.")
            } else if nonce != nil {
                XCTAssertEqual(nonce?.nonce, "a-fake-payment-method-nonce")
                XCTAssertEqual(nonce?.ibanLastFour, "1234")
                XCTAssertEqual(nonce?.customerID, "a-customer-id")
                XCTAssertEqual(nonce?.mandateType?.description, "RECURRENT")
                XCTAssertEqual(self.mockAPIClient.postedAnalyticsEvents.last, "ios.sepa-direct-debit.tokenize.success")
            }
        }
    }
    
    func testTokenizeWithPresentationContext_callsTokenizeWithAlreadyApprovedMandate_returnsError_andSendsAnalytics() {
        let mockWebAuthenticationSession = MockWebAuthenticationSession()
        let mockSepaDirectDebitAPI = SEPADirectDebitAPI(apiClient: mockAPIClient)

        mockAPIClient.cannedResponseBody = BTJSON(
            value: [
                "message": [
                    "body": [
                        "sepaDebitAccount": [
                            "approvalUrl": "null",
                            "last4": "1234",
                            "merchantOrPartnerCustomerId": "a-customer-id",
                            "bankReferenceToken": "a-bank-reference-token",
                            "mandateType": "ONE_OFF"
                        ]
                    ]
                ]
            ]
        )

        mockWebAuthenticationSession.cannedResponseURL = URL(string: "https://example/sepa/success?success=true")
        mockAPIClient.cannedResponseError = NSError(
            domain: "CannedError",
            code: 0,
            userInfo: [NSLocalizedDescriptionKey: "This is a fake tokenize request error"]
        )

        let sepaDirectDebitClient = BTSEPADirectDebitClient(
            apiClient: mockAPIClient,
            webAuthenticationSession: mockWebAuthenticationSession,
            sepaDirectDebitAPI: mockSepaDirectDebitAPI
        )

        if #available(iOS 13.0, *) {
            sepaDirectDebitClient.tokenize(request: sepaDirectDebitRequest, context: MockViewController()) { nonce, error in
                if error != nil, let error = error as NSError? {
                    XCTAssertEqual(error.domain, "CannedError")
                    XCTAssertEqual(error.code, 0)
                    XCTAssertEqual(error.localizedDescription, "This is a fake tokenize request error")
                    XCTAssertEqual(self.mockAPIClient.postedAnalyticsEvents.last, "ios.sepa-direct-debit.create-mandate.failure")
                } else if nonce != nil {
                    XCTFail("This request should be return an error.")
                }
            }
        } else {
            XCTFail("This should not get here as we use iOS 13.")
        }
    }
    
    func testTokenize_callsTokenizeWithAlreadyApprovedMandate_returnsError_andSendsAnalytics() {
        let mockWebAuthenticationSession = MockWebAuthenticationSession()
        let mockSepaDirectDebitAPI = SEPADirectDebitAPI(apiClient: mockAPIClient)

        mockAPIClient.cannedResponseBody = BTJSON(
            value: [
                "message": [
                    "body": [
                        "sepaDebitAccount": [
                            "approvalUrl": "nil",
                            "last4": "1234",
                            "merchantOrPartnerCustomerId": "a-customer-id",
                            "bankReferenceToken": "a-bank-reference-token",
                            "mandateType": "ONE_OFF"
                        ]
                    ]
                ]
            ]
        )

        mockWebAuthenticationSession.cannedResponseURL = URL(string: "https://example/sepa/success?success=true")
        mockAPIClient.cannedResponseError = NSError(
            domain: "CannedError",
            code: 0,
            userInfo: [NSLocalizedDescriptionKey: "This is a fake tokenize request error"]
        )

        let sepaDirectDebitClient = BTSEPADirectDebitClient(
            apiClient: mockAPIClient,
            webAuthenticationSession: mockWebAuthenticationSession,
            sepaDirectDebitAPI: mockSepaDirectDebitAPI
        )

        sepaDirectDebitClient.tokenize(request: sepaDirectDebitRequest) { nonce, error in
            if error != nil, let error = error as NSError? {
                XCTAssertEqual(error.domain, "CannedError")
                XCTAssertEqual(error.code, 0)
                XCTAssertEqual(error.localizedDescription, "This is a fake tokenize request error")
                XCTAssertEqual(self.mockAPIClient.postedAnalyticsEvents.last, "ios.sepa-direct-debit.create-mandate.failure")
            } else if nonce != nil {
                XCTFail("This request should be return an error.")
            }
        }
    }
    
    func testTokenizeWithPresentationContext_callsTokenize_returnsError_andSendsAnalytics() {
        let mockWebAuthenticationSession = MockWebAuthenticationSession()
        let mockSepaDirectDebitAPI = SEPADirectDebitAPI(apiClient: mockAPIClient)

        mockAPIClient.cannedResponseBody = BTJSON(
            value: [
                "message": [
                    "body": [
                        "sepaDebitAccount": [
                            "approvalUrl": "https://example-success",
                            "last4": "1234",
                            "merchantOrPartnerCustomerId": "a-customer-id",
                            "bankReferenceToken": "a-bank-reference-token",
                            "mandateType": "ONE_OFF"
                        ]
                    ]
                ]
            ]
        )

        mockWebAuthenticationSession.cannedResponseURL = URL(string: "https://example/sepa/success?success=true")
        mockAPIClient.cannedResponseError = NSError(
            domain: "CannedError",
            code: 0,
            userInfo: [NSLocalizedDescriptionKey: "This is a fake tokenize request error"]
        )

        let sepaDirectDebitClient = BTSEPADirectDebitClient(
            apiClient: mockAPIClient,
            webAuthenticationSession: mockWebAuthenticationSession,
            sepaDirectDebitAPI: mockSepaDirectDebitAPI
        )

        if #available(iOS 13.0, *) {
            sepaDirectDebitClient.tokenize(request: sepaDirectDebitRequest, context: MockViewController()) { nonce, error in
                if error != nil, let error = error as NSError? {
                    XCTAssertEqual(error.domain, "CannedError")
                    XCTAssertEqual(error.code, 0)
                    XCTAssertEqual(error.localizedDescription, "This is a fake tokenize request error")
                    XCTAssertEqual(self.mockAPIClient.postedAnalyticsEvents.last, "ios.sepa-direct-debit.create-mandate.failure")
                } else if nonce != nil {
                    XCTFail("This request should be return an error.")
                }
            }
        } else {
            XCTFail("This should not get here as we use iOS 13.")
        }
    }
    
    func testTokenize_callsTokenize_returnsError_andSendsAnalytics() {
        let mockWebAuthenticationSession = MockWebAuthenticationSession()
        let mockSepaDirectDebitAPI = SEPADirectDebitAPI(apiClient: mockAPIClient)

        mockAPIClient.cannedResponseBody = BTJSON(
            value: [
                "message": [
                    "body": [
                        "sepaDebitAccount": [
                            "approvalUrl": "https://example-success",
                            "last4": "1234",
                            "merchantOrPartnerCustomerId": "a-customer-id",
                            "bankReferenceToken": "a-bank-reference-token",
                            "mandateType": "ONE_OFF"
                        ]
                    ]
                ]
            ]
        )

        mockWebAuthenticationSession.cannedResponseURL = URL(string: "https://example/sepa/success?success=true")
        mockAPIClient.cannedResponseError = NSError(
            domain: "CannedError",
            code: 0,
            userInfo: [NSLocalizedDescriptionKey: "This is a fake tokenize request error"]
        )

        let sepaDirectDebitClient = BTSEPADirectDebitClient(
            apiClient: mockAPIClient,
            webAuthenticationSession: mockWebAuthenticationSession,
            sepaDirectDebitAPI: mockSepaDirectDebitAPI
        )

        sepaDirectDebitClient.tokenize(request: sepaDirectDebitRequest) { nonce, error in
            if error != nil, let error = error as NSError? {
                XCTAssertEqual(error.domain, "CannedError")
                XCTAssertEqual(error.code, 0)
                XCTAssertEqual(error.localizedDescription, "This is a fake tokenize request error")
                XCTAssertEqual(self.mockAPIClient.postedAnalyticsEvents.last, "ios.sepa-direct-debit.create-mandate.failure")
            } else if nonce != nil {
                XCTFail("This request should be return an error.")
            }
        }
    }
}
