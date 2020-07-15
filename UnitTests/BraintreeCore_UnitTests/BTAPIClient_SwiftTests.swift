import XCTest

class BTAPIClient_SwiftTests: XCTestCase {

    private let mockConfigurationHTTP = BTFakeHTTP()!

    override func setUp() {
        super.setUp()
        mockConfigurationHTTP.stubRequest("GET", toEndpoint: "/client_api/v1/configuration", respondWith: [], statusCode: 200)
    }

    // MARK: - Initialization

    func testAPIClientInitialization_withValidTokenizationKey_returnsClientWithTokenizationKey() {
        let apiClient = BTAPIClient(authorization: "development_testing_integration_merchant_id")!
        XCTAssertEqual(apiClient.tokenizationKey, "development_testing_integration_merchant_id")
    }

    func testAPIClientInitialization_withInvalidAuthorization_returnsNil() {
        XCTAssertNil(BTAPIClient(authorization: "invalid"))
    }

    func testAPIClientInitialization_withEmptyAuthorization_returnsNil() {
        XCTAssertNil(BTAPIClient(authorization: ""))
    }

    func testAPIClientInitialization_withValidClientToken_returnsClientWithClientToken() {
        let clientToken = BTTestClientTokenFactory.token(withVersion: 2)
        let apiClient = BTAPIClient(authorization: clientToken!)
        XCTAssertEqual(apiClient?.clientToken?.originalValue, clientToken)
    }

    func testAPIClientInitialization_withVersionThreeClientToken_returnsClientWithClientToken() {
        let clientToken = BTTestClientTokenFactory.token(withVersion: 3)
        let apiClient = BTAPIClient(authorization: clientToken!)
        XCTAssertEqual(apiClient?.clientToken?.originalValue, clientToken)
    }

    func testAPIClientInitialization_withValidClientToken_performanceMeetsExpectations() {
        let clientToken = BTTestClientTokenFactory.token(withVersion: 2)
        self.measure() {
            _ = BTAPIClient(authorization: clientToken!)
        }
    }

    func testAPIClientInitialization_withValidPayPalIDToken_returnsClientWithPayPalIDToken() {
        let payPalIDToken = "123.eyJpc3MiOiJodHRwczovL2FwaS5zYW5kYm94LnBheXBhbC5jb20iLCJzdWIiOiJNSkZQMzlWNE1RUkFFIiwiYWNyIjpbImNsaWVudCJdLCJzY29wZSI6WyJCcmFpbnRyZWU6VmF1bHQiXSwib3B0aW9ucyI6e30sImF6Ijoic2Iuc2xjIiwiZXh0ZXJuYWxfaWQiOlsiUGF5UGFsOk1KRlAzOVY0TVFSQUUiLCJCcmFpbnRyZWU6Y2Z4czNnaHp3ZmsycmhxbSJdLCJleHAiOjE1OTMwODgxMTMsImp0aSI6IlUyQUFIckM2Vjdpc2tqa0J6Z2ZORkhSeXNuekJIUUVacWdVMVl4ZG0xaWl1a1poQ2RQQXRjQnhhdGtzNVpzeHlZN1hZbkNST0cydzFfLTFPV2R1LVJDeEMtMVlCYXdJWUotT1FQRUdEYVhNWnhUMExWUjBDOWVnQ3BIdUItZllnIn0.456"
        let apiClient = BTAPIClient(authorization: payPalIDToken)
        XCTAssertEqual(apiClient?.payPalIDToken?.token, payPalIDToken)
    }

    func testAPIClientIntialization_withInvalidPayPalIDToken_returnsNil() {
        let payPalIDToken = "broken.paypal.idToken"
        let apiClient = BTAPIClient(authorization: payPalIDToken)
        XCTAssertNil(apiClient)
    }

    // MARK: - authorizationType
    
    func testAPIClientAuthorizationType_forTokenizationKey() {
        let tokenizationKey = "sandbox_test1xxx_123xx2swdz6nxxx7"
        let apiClientAuthType = BTAPIClient.authorizationType(forAuthorization: tokenizationKey)
        XCTAssertEqual(apiClientAuthType, .tokenizationKey)
    }

    func testAPIClientAuthorizationType_forClientToken() {
        let clientToken = "1234abc=="
        let apiClientAuthType = BTAPIClient.authorizationType(forAuthorization: clientToken)
        XCTAssertEqual(apiClientAuthType, .clientToken)
    }

    func testAPIClientAuthorizationType_forPayPalIDToken() {
        let payPalIDToken = "1a.2b.3c-_"
        let apiClientAuthType = BTAPIClient.authorizationType(forAuthorization: payPalIDToken)
        XCTAssertEqual(apiClientAuthType, .payPalIDToken)
    }

    // MARK: - Copy

    func testCopyWithSource_whenUsingClientToken_usesSameClientToken() {
        let clientToken = BTTestClientTokenFactory.token(withVersion: 2)
        let apiClient = BTAPIClient(authorization: clientToken!)

        let copiedApiClient = apiClient?.copy(with: .unknown, integration: .unknown)

        XCTAssertEqual(copiedApiClient?.clientToken?.originalValue, clientToken)
    }

    func testCopyWithSource_whenUsingTokenizationKey_usesSameTokenizationKey() {
        let apiClient = BTAPIClient(authorization: "development_testing_integration_merchant_id")
        let copiedApiClient = apiClient?.copy(with: .unknown, integration: .unknown)
        XCTAssertEqual(copiedApiClient?.tokenizationKey, "development_testing_integration_merchant_id")
    }

    func testCopyWithSource_setsMetadataSourceAndIntegration() {
        let apiClient = BTAPIClient(authorization: "development_testing_integration_merchant_id")
        let copiedApiClient = apiClient?.copy(with: .payPalBrowser, integration: .dropIn)
        XCTAssertEqual(copiedApiClient?.metadata.source, .payPalBrowser)
        XCTAssertEqual(copiedApiClient?.metadata.integration, .dropIn)
    }

    func testCopyWithSource_copiesHTTP() {
        let apiClient = BTAPIClient(authorization: "development_testing_integration_merchant_id")
        let copiedApiClient = apiClient?.copy(with: .payPalBrowser, integration: .dropIn)
        XCTAssertTrue(copiedApiClient !== apiClient)
    }

    // MARK: - fetchOrReturnRemoteConfiguration

    func testFetchOrReturnRemoteConfiguration_performsGETWithCorrectPayload() {
        let apiClient = BTAPIClient(authorization: "development_testing_integration_merchant_id", sendAnalyticsEvent: false)!
        let mockHTTP = BTFakeHTTP()!
        mockHTTP.stubRequest("GET", toEndpoint: "/v1/configuration", respondWith: [], statusCode: 200)
        apiClient.configurationHTTP = mockHTTP

        let expectation = self.expectation(description: "Callback invoked")
        apiClient.fetchOrReturnRemoteConfiguration() { _,_  in
            XCTAssertEqual(mockHTTP.lastRequestEndpoint, "v1/configuration")
            XCTAssertEqual(mockHTTP.lastRequestParameters?["configVersion"] as? String, "3")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }

    // MARK: - fetchPaymentMethodNonces with v2 client token

    func testFetchPaymentMethodNonces_performsGETWithCorrectParameter() {
        let apiClient = BTAPIClient(authorization: BTValidTestClientToken, sendAnalyticsEvent: false)!
        apiClient.configurationHTTP = mockConfigurationHTTP
        let mockHTTP = BTFakeHTTP()!
        mockHTTP.stubRequest("GET", toEndpoint: "/client_api/v1/payment_methods", respondWith: [], statusCode: 200)
        apiClient.http = mockHTTP

        let expectation = self.expectation(description: "Callback invoked")
        apiClient.fetchPaymentMethodNonces() { _,_  in
            XCTAssertEqual(mockHTTP.lastRequestEndpoint, "v1/payment_methods")
            XCTAssertEqual(mockHTTP.lastRequestParameters!["default_first"] as? String, "false")
            XCTAssertEqual(mockHTTP.lastRequestParameters!["session_id"] as? String, apiClient.metadata.sessionId)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testFetchPaymentMethodNonces_whenDefaultFirstIsTrue_performsGETWithCorrectParameters() {
        let apiClient = BTAPIClient(authorization: BTValidTestClientToken, sendAnalyticsEvent: false)!
        apiClient.configurationHTTP = mockConfigurationHTTP
        let mockHTTP = BTFakeHTTP()!
        mockHTTP.stubRequest("GET", toEndpoint: "/client_api/v1/payment_methods", respondWith: [], statusCode: 200)
        apiClient.http = mockHTTP

        let expectation = self.expectation(description: "Callback invoked")
        apiClient.fetchPaymentMethodNonces(true) { _,_  in
            XCTAssertEqual(mockHTTP.lastRequestEndpoint, "v1/payment_methods")
            XCTAssertEqual(mockHTTP.lastRequestParameters!["default_first"] as? String, "true")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testFetchPaymentMethodNonces_whenDefaultFirstIsFalse_performsGETWithCorrectParameters() {
        let apiClient = BTAPIClient(authorization: BTValidTestClientToken, sendAnalyticsEvent: false)!
        apiClient.configurationHTTP = mockConfigurationHTTP
        let mockHTTP = BTFakeHTTP()!
        mockHTTP.stubRequest("GET", toEndpoint: "/client_api/v1/payment_methods", respondWith: [], statusCode: 200)
        apiClient.http = mockHTTP

        let expectation = self.expectation(description: "Callback invoked")
        apiClient.fetchPaymentMethodNonces(false) { _,_  in
            XCTAssertEqual(mockHTTP.lastRequestEndpoint, "v1/payment_methods")
            XCTAssertEqual(mockHTTP.lastRequestParameters!["default_first"] as? String, "false")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testFetchPaymentMethodNonces_returnsPaymentMethodNonces() {
        let apiClient = BTAPIClient(authorization: BTValidTestClientToken, sendAnalyticsEvent: false)!
        apiClient.configurationHTTP = mockConfigurationHTTP
        let stubHTTP = BTFakeHTTP()!
        let stubbedResponse = [
            "paymentMethods": [
                [
                    "default" : true,
                    "description": "ending in 05",
                    "details": [
                        "cardType": "American Express",
                        "lastTwo": "05"
                    ],
                    "nonce": "fake-nonce",
                    "type": "CreditCard"
                ],
                [
                    "default" : false,
                    "description": "jane.doe@example.com",
                    "details": [],
                    "nonce": "fake-nonce",
                    "type": "PayPalAccount"
                ]
            ] ]
        stubHTTP.stubRequest("GET", toEndpoint: "/client_api/v1/payment_methods", respondWith: stubbedResponse, statusCode: 200)
        apiClient.http = stubHTTP

        let expectation = self.expectation(description: "Callback invoked")
        apiClient.fetchPaymentMethodNonces() { (paymentMethodNonces, error) in
            guard let paymentMethodNonces = paymentMethodNonces else {
                XCTFail()
                return
            }

            XCTAssertNil(error)
            XCTAssertEqual(paymentMethodNonces.count, 2)

            guard let cardNonce = paymentMethodNonces[0] as? BTCardNonce else {
                XCTFail()
                return
            }
            guard let paypalNonce = paymentMethodNonces[1] as? BTPayPalAccountNonce else {
                XCTFail()
                return
            }

            XCTAssertEqual(cardNonce.nonce, "fake-nonce")
            XCTAssertEqual(cardNonce.localizedDescription, "ending in 05")
            XCTAssertEqual(cardNonce.lastTwo, "05")
            XCTAssertTrue(cardNonce.cardNetwork == BTCardNetwork.AMEX)
            XCTAssertTrue(cardNonce.isDefault)

            XCTAssertEqual(paypalNonce.nonce, "fake-nonce")
            XCTAssertEqual(paypalNonce.localizedDescription, "jane.doe@example.com")
            XCTAssertFalse(paypalNonce.isDefault)

            expectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }

    // MARK: - fetchPaymentMethodNonces with tokenization key

    func testFetchPaymentMethodNonces_withTokenizationKey_returnsError() {
        let apiClient = BTAPIClient(authorization: "development_tokenization_key", sendAnalyticsEvent: false)!
        apiClient.configurationHTTP = mockConfigurationHTTP

        let expectation = self.expectation(description: "Error returned")
        apiClient.fetchPaymentMethodNonces() { (paymentMethodNonces, error) -> Void in
            XCTAssertNil(paymentMethodNonces);
            guard let error = error as NSError? else {return}
            XCTAssertEqual(error._domain, BTAPIClientErrorDomain);
            XCTAssertEqual(error._code, BTAPIClientErrorType.notAuthorized.rawValue);
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }

    // MARK: - fetchPaymentMethodNonces with v3 client token

    func testFetchPaymentMethodNonces_performsGETWithCorrectParameter_withV3ClientToken() {
        let clientToken = BTTestClientTokenFactory.token(withVersion: 3)
        let apiClient = BTAPIClient(authorization: clientToken!, sendAnalyticsEvent: false)!
        let mockHTTP = BTFakeHTTP()!
        mockHTTP.stubRequest("GET", toEndpoint: "/client_api/v1/payment_methods", respondWith: [], statusCode: 200)
        apiClient.http = mockHTTP
        apiClient.configurationHTTP = mockConfigurationHTTP

        XCTAssertEqual((apiClient.clientToken!.json["version"] as! BTJSON).asIntegerOrZero(), 3)

        let expectation = self.expectation(description: "Callback invoked")
        apiClient.fetchPaymentMethodNonces() { _,_  in
            XCTAssertEqual(mockHTTP.lastRequestEndpoint, "v1/payment_methods")
            XCTAssertEqual(mockHTTP.lastRequestParameters!["default_first"] as? String, "false")
            XCTAssertEqual(mockHTTP.lastRequestParameters!["session_id"] as? String, apiClient.metadata.sessionId)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testFetchPaymentMethodNonces_whenDefaultFirstIsTrue_performsGETWithCorrectParameter_withV3ClientToken() {
        let clientToken = BTTestClientTokenFactory.token(withVersion: 3)
        let apiClient = BTAPIClient(authorization: clientToken!, sendAnalyticsEvent: false)!
        let mockHTTP = BTFakeHTTP()!
        mockHTTP.stubRequest("GET", toEndpoint: "/client_api/v1/payment_methods", respondWith: [], statusCode: 200)
        apiClient.http = mockHTTP
        apiClient.configurationHTTP = mockConfigurationHTTP

        let expectation = self.expectation(description: "Callback invoked")
        apiClient.fetchPaymentMethodNonces(true) { _,_  in
            XCTAssertEqual(mockHTTP.lastRequestEndpoint, "v1/payment_methods")
            XCTAssertEqual(mockHTTP.lastRequestParameters!["default_first"] as? String, "true")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testFetchPaymentMethodNonces_whenDefaultFirstIsFalse_performsGETWithCorrectParameter_withV3ClientToken() {
        let clientToken = BTTestClientTokenFactory.token(withVersion: 3)
        let apiClient = BTAPIClient(authorization: clientToken!, sendAnalyticsEvent: false)!
        let mockHTTP = BTFakeHTTP()!
        mockHTTP.stubRequest("GET", toEndpoint: "/client_api/v1/payment_methods", respondWith: [], statusCode: 200)
        apiClient.http = mockHTTP
        apiClient.configurationHTTP = mockConfigurationHTTP

        let expectation = self.expectation(description: "Callback invoked")
        apiClient.fetchPaymentMethodNonces(false) { _,_  in
            XCTAssertEqual(mockHTTP.lastRequestEndpoint, "v1/payment_methods")
            XCTAssertEqual(mockHTTP.lastRequestParameters!["default_first"] as? String, "false")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }

    // MARK: - Analytics

    func testAnalyticsService_byDefault_isASingleton() {
        let firstAPIClient = BTAPIClient(authorization: "development_testing_integration_merchant_id")!
        let secondAPIClient = BTAPIClient(authorization: "development_testing_integration_merchant_id")!
        XCTAssertTrue(firstAPIClient.analyticsService === secondAPIClient.analyticsService)
    }

}
