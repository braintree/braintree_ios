import UIKit
import XCTest
import BraintreeTestShared

class BTThreeDSecure_UnitTests: XCTestCase {
    let tempClientToken = "eyJ2ZXJzaW9uIjoyLCJhdXRob3JpemF0aW9uRmluZ2VycHJpbnQiOiJmNTI0M2RkZGRmNzlkNGFiYmI5YjYwMDUzN2ZkZjQ0ZDViNDg0ODVkOWU0ZjJmYmI3YWM5ZTU2MGE3ZDVhZmM5fGNyZWF0ZWRfYXQ9MjAxNy0wNC0xM1QyMTozOTo0My40MjM4NzE4MTUrMDAwMFx1MDAyNmN1c3RvbWVyX2lkPTJENzJCNjQ4LUI0RkMtNDQ1My1BOURDLTI2QTYyMEVGNjQwNFx1MDAyNm1lcmNoYW50X2FjY291bnRfaWQ9aWRlYWxfZXVyXHUwMDI2bWVyY2hhbnRfaWQ9ZGNwc3B5MmJyd2RqcjNxblx1MDAyNnB1YmxpY19rZXk9OXd3cnpxazN2cjN0NG5jOCIsImNvbmZpZ1VybCI6Imh0dHBzOi8vYXBpLnNhbmRib3guYnJhaW50cmVlZ2F0ZXdheS5jb206NDQzL21lcmNoYW50cy9kY3BzcHkyYnJ3ZGpyM3FuL2NsaWVudF9hcGkvdjEvY29uZmlndXJhdGlvbiIsImNoYWxsZW5nZXMiOlsiY3Z2IiwicG9zdGFsX2NvZGUiXSwiZW52aXJvbm1lbnQiOiJzYW5kYm94IiwiY2xpZW50QXBpVXJsIjoiaHR0cHM6Ly9hcGkuc2FuZGJveC5icmFpbnRyZWVnYXRld2F5LmNvbTo0NDMvbWVyY2hhbnRzL2RjcHNweTJicndkanIzcW4vY2xpZW50X2FwaSIsImFzc2V0c1VybCI6Imh0dHBzOi8vYXNzZXRzLmJyYWludHJlZWdhdGV3YXkuY29tIiwiYXV0aFVybCI6Imh0dHBzOi8vYXV0aC52ZW5tby5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tIiwiYW5hbHl0aWNzIjp7InVybCI6Imh0dHBzOi8vY2xpZW50LWFuYWx5dGljcy5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tL2RjcHNweTJicndkanIzcW4ifSwidGhyZWVEU2VjdXJlRW5hYmxlZCI6ZmFsc2UsInBheXBhbEVuYWJsZWQiOmZhbHNlLCJjb2luYmFzZUVuYWJsZWQiOnRydWUsImNvaW5iYXNlIjp7ImNsaWVudElkIjoiN2U5NWUwZmRkYTE0ODQ2NjU4YjM4Zjc3MmJhMmQzMGNkNzhhOWYyMTQ0YzUzOTA4NmU1NzkwYmYzNzdmYmVlZCIsIm1lcmNoYW50QWNjb3VudCI6ImNvaW5iYXNlLXNhbmRib3gtc2hhcmVkLW1lcmNoYW50QGdldGJyYWludHJlZS5jb20iLCJzY29wZXMiOiJhdXRob3JpemF0aW9uczpicmFpbnRyZWUgdXNlciIsInJlZGlyZWN0VXJsIjoiaHR0cHM6Ly9hc3NldHMuYnJhaW50cmVlZ2F0ZXdheS5jb20vY29pbmJhc2Uvb2F1dGgvcmVkaXJlY3QtbGFuZGluZy5odG1sIiwiZW52aXJvbm1lbnQiOiJwcm9kdWN0aW9uIn0sImJyYWludHJlZV9hcGkiOnsiYWNjZXNzX3Rva2VuIjoic2FuZGJveF9mN2RyNWNfZHE2c3MyX2prczd4dF80aHNwc2hfcWI3IiwidXJsIjoiaHR0cHM6Ly9wYXltZW50cy5zYW5kYm94LmJyYWludHJlZS1hcGkuY29tIn0sIm1lcmNoYW50SWQiOiJkY3BzcHkyYnJ3ZGpyM3FuIiwidmVubW8iOiJvZmZsaW5lIiwiYXBwbGVQYXkiOnsic3RhdHVzIjoibW9jayIsImNvdW50cnlDb2RlIjoiVVMiLCJjdXJyZW5jeUNvZGUiOiJFVVIiLCJtZXJjaGFudElkZW50aWZpZXIiOiJtZXJjaGFudC5jb20uYnJhaW50cmVlcGF5bWVudHMuc2FuZGJveC5CcmFpbnRyZWUtRGVtbyIsInN1cHBvcnRlZE5ldHdvcmtzIjpbInZpc2EiLCJtYXN0ZXJjYXJkIiwiYW1leCIsImRpc2NvdmVyIl19LCJtZXJjaGFudEFjY291bnRJZCI6ImlkZWFsX2V1ciJ9"
    var mockAPIClient : MockAPIClient!
    var threeDSecureRequest : BTThreeDSecureRequest!
    var mockThreeDSecureRequestDelegate : MockThreeDSecureRequestDelegate!

    override func setUp() {
        super.setUp()
        
        threeDSecureRequest = BTThreeDSecureRequest()
        threeDSecureRequest.amount = 10.0
        threeDSecureRequest.nonce = "fake-card-nonce"
        threeDSecureRequest.versionRequested = .version1
        mockAPIClient = MockAPIClient(authorization: tempClientToken)!
        mockThreeDSecureRequestDelegate = MockThreeDSecureRequestDelegate()
    }

    // MARK: - ThreeDSecure Authentication Tests

    func testStartPayment_displaysSafariViewControllerWhenAvailable_andRequiresAuthentication() {
        BTAppContextSwitcher.setReturnURLScheme("com.braintreepayments.Demo.payments")
        
        let viewControllerPresentingDelegate = MockViewControllerPresentingDelegate()
        
        viewControllerPresentingDelegate.requestsPresentationOfViewControllerExpectation = self.expectation(description: "Delegate received requestsPresentationOfViewController")
        
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "assetsUrl": "http://assets.example.com"
        ])
        let driver = BTPaymentFlowDriver(apiClient: mockAPIClient)
        driver.viewControllerPresentingDelegate = viewControllerPresentingDelegate

        mockAPIClient.cannedResponseBody = BTJSON(value: getAuthRequiredLookupResponse())

        driver.startPaymentFlow(threeDSecureRequest) { (result, error) in
            
        }
        
        waitForExpectations(timeout: 4, handler: nil)
    }

    func testStartPayment_v2_returnsErrorWhenCardinalAuthenticationJWT_isMissing() {
        threeDSecureRequest.versionRequested = .version2
        threeDSecureRequest.threeDSecureRequestDelegate = mockThreeDSecureRequestDelegate

        let expectation = self.expectation(description: "willCallCompletion")

        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "threeDSecure": [],
            "assetsUrl": "http://assets.example.com"
            ])
        let driver = BTPaymentFlowDriver(apiClient: mockAPIClient)

        driver.startPaymentFlow(threeDSecureRequest) { (result, error) in
            XCTAssertNotNil(error)
            XCTAssertNil(result)
            guard let error = error as NSError? else {return}
            XCTAssertEqual(error.domain, BTThreeDSecureFlowErrorDomain)
            XCTAssertEqual(error.code, BTThreeDSecureFlowErrorType.configuration.rawValue)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 4, handler: nil)
    }

    func testStartPayment_returnsError_whenAmountIsMissing() {
        threeDSecureRequest = BTThreeDSecureRequest()
        threeDSecureRequest.nonce = "fake-card-nonce"
        threeDSecureRequest.versionRequested = .version1
        threeDSecureRequest.threeDSecureRequestDelegate = mockThreeDSecureRequestDelegate

        let expectation = self.expectation(description: "willCallCompletion")

        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "threeDSecure": ["cardinalAuthenticationJWT": "FAKE_JWT"],
            "assetsUrl": "http://assets.example.com"
            ])
        let driver = BTPaymentFlowDriver(apiClient: mockAPIClient)

        driver.startPaymentFlow(threeDSecureRequest) { (result, error) in
            XCTAssertNotNil(error)
            XCTAssertNil(result)
            guard let error = error as NSError? else { return }
            XCTAssertEqual(error.domain, BTThreeDSecureFlowErrorDomain)
            XCTAssertEqual(error.code, BTThreeDSecureFlowErrorType.configuration.rawValue)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 4, handler: nil)
    }
    
    func testStartPayment_returnsError_whenAmountIsNotANumber() {
        threeDSecureRequest = BTThreeDSecureRequest()
        threeDSecureRequest.amount = .notANumber
        threeDSecureRequest.nonce = "fake-card-nonce"
        threeDSecureRequest.versionRequested = .version1
        threeDSecureRequest.threeDSecureRequestDelegate = mockThreeDSecureRequestDelegate

        let expectation = self.expectation(description: "willCallCompletion")

        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "threeDSecure": ["cardinalAuthenticationJWT": "FAKE_JWT"],
            "assetsUrl": "http://assets.example.com"
            ])
        let driver = BTPaymentFlowDriver(apiClient: mockAPIClient)

        driver.startPaymentFlow(threeDSecureRequest) { (result, error) in
            XCTAssertNotNil(error)
            XCTAssertNil(result)
            guard let error = error as NSError? else { return }
            XCTAssertEqual(error.domain, BTThreeDSecureFlowErrorDomain)
            XCTAssertEqual(error.code, BTThreeDSecureFlowErrorType.configuration.rawValue)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 4, handler: nil)
    }

    func testStartPayment_v2_doesNotDisplaySafariViewControllerWhenAuthenticationNotRequired() {
        let viewControllerPresentingDelegate = MockViewControllerPresentingDelegate()
        threeDSecureRequest.versionRequested = .version2
        threeDSecureRequest.threeDSecureRequestDelegate = mockThreeDSecureRequestDelegate
        mockThreeDSecureRequestDelegate.lookupCompleteExpectation = self.expectation(description: "onLookupComplete expectation")

        let expectation = self.expectation(description: "willCallCompletion")

        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "threeDSecure": ["cardinalAuthenticationJWT": "FAKE_JWT"],
            "assetsUrl": "http://assets.example.com"
            ])
        let driver = BTPaymentFlowDriver(apiClient: mockAPIClient)
        driver.viewControllerPresentingDelegate = viewControllerPresentingDelegate
        let responseBody = [
            "paymentMethod": [
                "consumed": false,
                "description": "ending in 02",
                "details": [
                    "cardType": "Visa",
                    "lastTwo": "02",
                ],
                "nonce": "f689056d-aee1-421e-9d10-f2c9b34d4d6f",
                "threeDSecureInfo": [
                    "enrolled": "N",
                    "liabilityShiftPossible": false,
                    "liabilityShifted": false,
                    "status": "authenticate_successful_issuer_not_participating",
                ],
                "type": "CreditCard",
            ],
            "success": true,
            "threeDSecureInfo":     [
                "liabilityShiftPossible": false,
                "liabilityShifted": false,
            ]
            ] as [String : Any]
        mockAPIClient.cannedResponseBody = BTJSON(value: responseBody)

        driver.startPaymentFlow(threeDSecureRequest) { (result, error) in
            guard let result = result as? BTThreeDSecureResult else { XCTFail(); return }
            guard let tokenizedCard = result.tokenizedCard else { XCTFail(); return }

            XCTAssertTrue(tokenizedCard.nonce.isANonce())
            XCTAssertNotEqual(tokenizedCard.nonce, self.threeDSecureRequest.nonce);
            XCTAssertFalse(tokenizedCard.threeDSecureInfo.liabilityShifted)
            XCTAssertFalse(tokenizedCard.threeDSecureInfo.liabilityShiftPossible)
            XCTAssertTrue(tokenizedCard.threeDSecureInfo.wasVerified)
            XCTAssertNil(error)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 4, handler: nil)
    }

    func testStartPayment_v2_callsOnLookupCompleteDelegateMethod() {
        let viewControllerPresentingDelegate = MockViewControllerPresentingDelegate()
        threeDSecureRequest.versionRequested = .version2
        threeDSecureRequest.threeDSecureRequestDelegate = mockThreeDSecureRequestDelegate
        mockThreeDSecureRequestDelegate.lookupCompleteExpectation = self.expectation(description: "onLookupComplete expectation")

        let expectation = self.expectation(description: "willCallCompletion")

        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "threeDSecure": ["cardinalAuthenticationJWT": "FAKE_JWT"],
            "assetsUrl": "http://assets.example.com"
            ])
        let driver = BTPaymentFlowDriver(apiClient: mockAPIClient)
        driver.viewControllerPresentingDelegate = viewControllerPresentingDelegate

        driver.startPaymentFlow(threeDSecureRequest) { (result, error) in
            expectation.fulfill()
        }

        waitForExpectations(timeout: 4, handler: nil)
    }

    func testStartPayment_v2_when_threeDSecureRequestDelegate_notSet_returnsError() {
        let viewControllerPresentingDelegate = MockViewControllerPresentingDelegate()
        threeDSecureRequest.versionRequested = .version2

        let expectation = self.expectation(description: "willCallCompletion")

        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "threeDSecure": ["cardinalAuthenticationJWT": "FAKE_JWT"],
            "assetsUrl": "http://assets.example.com"
            ])
        let driver = BTPaymentFlowDriver(apiClient: mockAPIClient)
        driver.viewControllerPresentingDelegate = viewControllerPresentingDelegate

        driver.startPaymentFlow(threeDSecureRequest) { (result, error) in
            XCTAssertNotNil(error)
            XCTAssertNil(result)
            guard let error = error as NSError? else {return}
            XCTAssertEqual(error.domain, BTThreeDSecureFlowErrorDomain)
            XCTAssertEqual(error.code, BTThreeDSecureFlowErrorType.configuration.rawValue)
            XCTAssertEqual(error.localizedDescription, "Configuration Error: threeDSecureRequestDelegate can not be nil when versionRequested is 2.")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testStartPayment_successfulResult_callsCompletionBlock() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "assetsUrl": "http://assets.example.com",
        ])
        
        let viewControllerPresentingDelegate = MockViewControllerPresentingDelegate()
        viewControllerPresentingDelegate.requestsPresentationOfViewControllerExpectation = self.expectation(description: "Delegate received requestsPresentationOfViewController")
        
        let driver = BTPaymentFlowDriver(apiClient: mockAPIClient)
        driver.viewControllerPresentingDelegate = viewControllerPresentingDelegate

        mockAPIClient.cannedResponseBody = BTJSON(value: getAuthRequiredLookupResponse())
        
        var paymentFinishedExpectation: XCTestExpectation? = nil
        driver.startPaymentFlow(threeDSecureRequest) { (result, error) in
            XCTAssertNil(error)
            XCTAssertNotNil(result)
            paymentFinishedExpectation!.fulfill()
        }
        
        waitForExpectations(timeout: 2, handler: nil)
        
        paymentFinishedExpectation = self.expectation(description: "Start payment expectation")
        BTPaymentFlowDriver.handleReturnURL(URL(string: "com.braintreepayments.demo.payments://x-callback-url/braintree/threedsecure?auth_response=%7B%22paymentMethod%22:%7B%22type%22:%22CreditCard%22,%22nonce%22:%220d3e1cc8-50a4-0437-720b-c03c722f0d0a%22,%22description%22:%22ending+in+02%22,%22consumed%22:false,%22threeDSecureInfo%22:%7B%22liabilityShifted%22:true,%22liabilityShiftPossible%22:true,%22status%22:%22authenticate_successful%22,%22enrolled%22:%22Y%22%7D,%22details%22:%7B%22lastTwo%22:%2202%22,%22lastFour%22:%220002%22,%22cardType%22:%22Visa%22%7D,%22bin_data%22:%7B%22prepaid%22:%22Unknown%22,%22healthcare%22:%22Unknown%22,%22debit%22:%22Unknown%22,%22durbin_regulated%22:%22Unknown%22,%22commercial%22:%22Unknown%22,%22payroll%22:%22Unknown%22,%22issuing_bank%22:%22Unknown%22,%22country_of_issuance%22:%22Unknown%22,%22product_id%22:%22Unknown%22%7D%7D,%22threeDSecureInfo%22:%7B%22liabilityShifted%22:true,%22liabilityShiftPossible%22:true%7D,%22success%22:true%7D")!)
        
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testStartPayment_returnsFailedAuthenticationError_whenErrorReturnedInURL() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "assetsUrl": "http://assets.example.com",
            ])
        
        let viewControllerPresentingDelegate = MockViewControllerPresentingDelegate()
        viewControllerPresentingDelegate.requestsPresentationOfViewControllerExpectation = self.expectation(description: "Delegate received requestsPresentationOfViewController")
        
        let driver = BTPaymentFlowDriver(apiClient: mockAPIClient)
        driver.viewControllerPresentingDelegate = viewControllerPresentingDelegate
        
        mockAPIClient.cannedResponseBody = BTJSON(value: getAuthRequiredLookupResponse())
        
        var paymentFinishedExpectation: XCTestExpectation? = nil
        driver.startPaymentFlow(threeDSecureRequest) { (result, error) in
            XCTAssertNotNil(error)
            XCTAssertNil(result)
            guard let error = error as NSError? else {return}
            XCTAssertEqual(error.domain, BTThreeDSecureFlowErrorDomain)
            XCTAssertEqual(error.code, BTThreeDSecureFlowErrorType.failedAuthentication.rawValue)
            paymentFinishedExpectation!.fulfill()
        }
        
        waitForExpectations(timeout: 2, handler: nil)
        
        paymentFinishedExpectation = self.expectation(description: "Start payment expectation")
        BTPaymentFlowDriver.handleReturnURL(URL(string: "com.braintreepayments.demo.payments://x-callback-url/braintree/threedsecure?auth_response=%7B%22threeDSecureInfo%22:%7B%22liabilityShifted%22:false,%22liabilityShiftPossible%22:true%7D,%22error%22:%7B%22message%22:%22Failed+to+authenticate,+please+try+a+different+form+of+payment.%22%7D,%22success%22:false%7D")!)
        
        waitForExpectations(timeout: 2, handler: nil)
    }

    func testStartPayment_missingAuthResponse_callsCompletionBlock_withError_sendsAnalyticsEvent() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "assetsUrl": "http://assets.example.com",
            ])

        let viewControllerPresentingDelegate = MockViewControllerPresentingDelegate()
        viewControllerPresentingDelegate.requestsPresentationOfViewControllerExpectation = self.expectation(description: "Delegate received requestsPresentationOfViewController")

        let driver = BTPaymentFlowDriver(apiClient: mockAPIClient)
        driver.viewControllerPresentingDelegate = viewControllerPresentingDelegate

        mockAPIClient.cannedResponseBody = BTJSON(value: getAuthRequiredLookupResponse())

        var paymentFinishedExpectation: XCTestExpectation? = nil
        driver.startPaymentFlow(threeDSecureRequest) { (result, error) in
            XCTAssertNotNil(error)
            XCTAssertNil(result)
            guard let error = error as NSError? else {return}
            XCTAssertEqual(error.domain, BTThreeDSecureFlowErrorDomain)
            XCTAssertEqual(error.code, BTThreeDSecureFlowErrorType.failedAuthentication.rawValue)
            XCTAssertEqual(error.localizedDescription, "Auth Response missing from URL.")
            paymentFinishedExpectation!.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)

        paymentFinishedExpectation = self.expectation(description: "Start payment expectation")
        BTPaymentFlowDriver.handleReturnURL(URL(string: "com.braintreepayments.demo.payments://x-callback-url/braintree/threedsecure?no-auth=bad-response")!)

        waitForExpectations(timeout: 2, handler: nil)

        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains("ios.three-d-secure.missing-auth-response"))
    }

    func testStartPayment_invalidAuthResponse_callsCompletionBlock_withError_sendsAnalyticsEvent() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "assetsUrl": "http://assets.example.com",
            ])

        let viewControllerPresentingDelegate = MockViewControllerPresentingDelegate()
        viewControllerPresentingDelegate.requestsPresentationOfViewControllerExpectation = self.expectation(description: "Delegate received requestsPresentationOfViewController")

        let driver = BTPaymentFlowDriver(apiClient: mockAPIClient)
        driver.viewControllerPresentingDelegate = viewControllerPresentingDelegate

        mockAPIClient.cannedResponseBody = BTJSON(value: getAuthRequiredLookupResponse())

        var paymentFinishedExpectation: XCTestExpectation? = nil
        driver.startPaymentFlow(threeDSecureRequest) { (result, error) in
            XCTAssertNotNil(error)
            XCTAssertNil(result)
            guard let error = error as NSError? else {return}
            XCTAssertEqual(error.domain, BTThreeDSecureFlowErrorDomain)
            XCTAssertEqual(error.code, BTThreeDSecureFlowErrorType.failedAuthentication.rawValue)
            XCTAssertEqual(error.localizedDescription, "Auth Response JSON parsing error.")
            paymentFinishedExpectation!.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)

        paymentFinishedExpectation = self.expectation(description: "Start payment expectation")
        BTPaymentFlowDriver.handleReturnURL(URL(string: "com.braintreepayments.demo.payments://x-callback-url/braintree/threedsecure?auth_response=%7B%22paymentMethod%22:%7B%22type%22:%22CreditCard%22,%22nonce%22:%220d3e1cc8-50a4-0437-720b-c03c722f0d0a%22,BAD-JSON")!)

        waitForExpectations(timeout: 2, handler: nil)

        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains("ios.three-d-secure.invalid-auth-response"))
    }

    func testStartPayment_unexpectedAuthResponse_callsCompletionBlock_withError_sendsAnalyticsEvent() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "assetsUrl": "http://assets.example.com",
            ])

        let viewControllerPresentingDelegate = MockViewControllerPresentingDelegate()
        viewControllerPresentingDelegate.requestsPresentationOfViewControllerExpectation = self.expectation(description: "Delegate received requestsPresentationOfViewController")

        let driver = BTPaymentFlowDriver(apiClient: mockAPIClient)
        driver.viewControllerPresentingDelegate = viewControllerPresentingDelegate

        mockAPIClient.cannedResponseBody = BTJSON(value: getAuthRequiredLookupResponse())

        var paymentFinishedExpectation: XCTestExpectation? = nil
        driver.startPaymentFlow(threeDSecureRequest) { (result, error) in
            XCTAssertNotNil(error)
            XCTAssertNil(result)
            guard let error = error as NSError? else {return}
            XCTAssertEqual(error.domain, BTThreeDSecureFlowErrorDomain)
            XCTAssertEqual(error.code, BTThreeDSecureFlowErrorType.failedAuthentication.rawValue)
            XCTAssertEqual(error.localizedDescription, "Auth Response JSON parsing error.")
            paymentFinishedExpectation!.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)

        paymentFinishedExpectation = self.expectation(description: "Start payment expectation")
        BTPaymentFlowDriver.handleReturnURL(URL(string: "com.braintreepayments.demo.payments://x-callback-url/braintree/threedsecure?auth_response=%22STRING%22")!)

        waitForExpectations(timeout: 2, handler: nil)

        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains("ios.three-d-secure.invalid-auth-response"))
    }

    func getAuthRequiredLookupResponse() -> [String : Any] {
        return [
            "paymentMethod": [
                "consumed": false,
                "description": "ending in 02",
                "details": [
                    "cardType": "Visa",
                    "lastTwo": "02",
                ],
                "nonce": "f689056d-aee1-421e-9d10-f2c9b34d4d6f",
                "threeDSecureInfo": [
                    "enrolled": "Y",
                    "liabilityShiftPossible": true,
                    "liabilityShifted": true,
                    "status": "authenticate_successful",
                ],
                "type": "CreditCard",
            ],
            "success": true,
            "threeDSecureInfo":     [
                "liabilityShiftPossible": true,
                "liabilityShifted": true,
            ],
            "lookup": [
                "acsUrl": "http://example.com",
                "pareq": "",
                "md": "",
                "termUrl": "http://example.com"
            ]
        ]
    }

    // MARK: - Analytic Event Tests

    func testStartPayment_success_sendsAnalyticsEvents() {
        let viewControllerPresentingDelegate = MockViewControllerPresentingDelegate()

        viewControllerPresentingDelegate.requestsPresentationOfViewControllerExpectation = self.expectation(description: "Delegate received requestsPresentationOfViewController")

        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "assetsUrl": "http://assets.example.com",
            ])
        let driver = BTPaymentFlowDriver(apiClient: mockAPIClient)
        driver.viewControllerPresentingDelegate = viewControllerPresentingDelegate
        let responseBody = [
            "paymentMethod": [
                "consumed": false,
                "description": "ending in 02",
                "details": [
                    "cardType": "Visa",
                    "lastTwo": "02",
                ],
                "nonce": "f689056d-aee1-421e-9d10-f2c9b34d4d6f",
                "threeDSecureInfo": [
                    "enrolled": "Y",
                    "liabilityShiftPossible": true,
                    "liabilityShifted": true,
                    "status": "authenticate_successful",
                ],
                "type": "CreditCard",
            ],
            "success": true,
            "threeDSecureInfo":     [
                "liabilityShiftPossible": true,
                "liabilityShifted": true,
            ],
            "lookup": [
                "acsUrl": "http://example.com",
                "pareq": "",
                "md": "",
                "termUrl": "http://example.com",
                "threeDSecureVersion": "1.0"
            ]
            ] as [String : Any]
        mockAPIClient.cannedResponseBody = BTJSON(value: responseBody)

        driver.startPaymentFlow(threeDSecureRequest) { (result, error) in

        }

        waitForExpectations(timeout: 4, handler: nil)
        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains("ios.three-d-secure.start-payment.selected"))
        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains("ios.three-d-secure.initialized"))
        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains("ios.three-d-secure.verification-flow.started"))
        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains("ios.three-d-secure.verification-flow.3ds-version.1.0"))
        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains("ios.three-d-secure.verification-flow.challenge-presented.true"))
        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains("ios.three-d-secure.webswitch.initiate.succeeded"))
    }

    func testStartPayment_failure_sendsAnalyticsEvents() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "assetsUrl": "http://assets.example.com",
            ])
        let driver = BTPaymentFlowDriver(apiClient: mockAPIClient)
        mockAPIClient.cannedResponseError = NSError(domain:"BTError", code: 500, userInfo: nil)

        let expectation = self.expectation(description: "Start payment expectation")
        driver.startPaymentFlow(threeDSecureRequest) { (result, error) in
            guard (error as NSError?) != nil else {return}
            expectation.fulfill()
        }

        waitForExpectations(timeout: 4, handler: nil)
        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains("ios.three-d-secure.start-payment.selected"))
        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains("ios.three-d-secure.initialized"))
        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains("ios.three-d-secure.verification-flow.started"))
        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains("ios.three-d-secure.verification-flow.failed"))
        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains("ios.three-d-secure.start-payment.failed"))
    }

    // MARK: - ThreeDSecure Prepare Lookup Tests

    func testThreeDSecureRequest_prepareLookup_getsJsonString() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "threeDSecure": ["cardinalAuthenticationJWT": "FAKE_JWT"],
            "assetsUrl": "http://assets.example.com"
            ])
        let driver = BTPaymentFlowDriver(apiClient: mockAPIClient)

        let expectation = self.expectation(description: "willCallCompletion")

        threeDSecureRequest.nonce = "fake-card-nonce"
        threeDSecureRequest.dfReferenceID = "fake-df-reference-id"

        driver.prepareLookup(threeDSecureRequest) { (clientData, error) in
            XCTAssertNil(error)
            XCTAssertNotNil(clientData)
            if let data = clientData!.data(using: .utf8) {
                let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                XCTAssertEqual(json!["dfReferenceId"] as! String, "fake-df-reference-id")
                XCTAssertEqual(json!["nonce"] as! String, "fake-card-nonce")
                XCTAssertNotNil(json!["braintreeLibraryVersion"] as! String)
                XCTAssertNotNil(json!["authorizationFingerprint"] as! String)
                let clientMetadata = json!["clientMetadata"] as! [String: Any]
                XCTAssertEqual(clientMetadata["requestedThreeDSecureVersion"] as! String, "2")
                XCTAssertEqual(clientMetadata["sdkVersion"] as! String, "iOS/\(BRAINTREE_VERSION)")
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 3, handler: nil)
    }
}

