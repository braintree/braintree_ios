import XCTest

class BTAPIClient_SwiftTests: XCTestCase {

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

    func testAPIClientInitialization_withValidPayPalUAT_returnsClientWithPayPalUAT() {
        let payPalUAT = "123.ewogICAiaXNzIjoiaHR0cHM6Ly9hcGkucGF5cGFsLmNvbSIsCiAgICJzdWIiOiJQYXlQYWw6ZmFrZS1wcC1tZXJjaGFudCIsCiAgICJhY3IiOlsKICAgICAgImNsaWVudCIKICAgXSwKICAgInNjb3BlcyI6WwogICAgICAiQnJhaW50cmVlOlZhdWx0IgogICBdLAogICAiZXhwIjoxNTcxOTgwNTA2LAogICAiZXh0ZXJuYWxfaWRzIjpbCiAgICAgICJQYXlQYWw6ZmFrZS1wcC1tZXJjaGFudCIsCiAgICAgICJCcmFpbnRyZWU6ZmFrZS1idC1tZXJjaGFudCIKICAgXSwKICAgImp0aSI6ImZha2UtanRpIgp9.456"
        let apiClient = BTAPIClient(authorization: payPalUAT)
        XCTAssertEqual(apiClient?.payPalUAT?.token, payPalUAT)
    }

    func testAPIClientIntialization_withInvalidPayPalUAT_returnsNil() {
        let payPalUAT = "broken.paypal.uat"
        let apiClient = BTAPIClient(authorization: payPalUAT)
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

    func testAPIClientAuthorizationType_forPayPalUAT() {
        let payPalUAT = "1a.2b.3c-_"
        let apiClientAuthType = BTAPIClient.authorizationType(forAuthorization: payPalUAT)
        XCTAssertEqual(apiClientAuthType, .payPalUAT)
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

    // MARK: - fetchPaymentMethods

    func testFetchPaymentMethods_performsGETWithCorrectParameter() {
        let apiClient = BTAPIClient(authorization: BTValidTestClientToken, sendAnalyticsEvent: false)!
        let mockHTTP = BTFakeHTTP()!
        mockHTTP.stubRequest("GET", toEndpoint: "/client_api/v1/payment_methods", respondWith: [], statusCode: 200)
        apiClient.http = mockHTTP

        var expectation = self.expectation(description: "Callback invoked")
        apiClient.fetchPaymentMethodNonces() { _,_  in
            XCTAssertEqual(mockHTTP.lastRequestEndpoint, "v1/payment_methods")
            XCTAssertEqual(mockHTTP.lastRequestParameters!["default_first"] as? String, "false")
            XCTAssertEqual(mockHTTP.lastRequestParameters!["session_id"] as? String, apiClient.metadata.sessionId)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)

        expectation = self.expectation(description: "Callback invoked")
        apiClient.fetchPaymentMethodNonces(true) { _,_  in
            XCTAssertEqual(mockHTTP.lastRequestEndpoint, "v1/payment_methods")
            XCTAssertEqual(mockHTTP.lastRequestParameters!["default_first"] as? String, "true")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)

        expectation = self.expectation(description: "Callback invoked")
        apiClient.fetchPaymentMethodNonces(false) { _,_  in
            XCTAssertEqual(mockHTTP.lastRequestEndpoint, "v1/payment_methods")
            XCTAssertEqual(mockHTTP.lastRequestParameters!["default_first"] as? String, "false")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testFetchPaymentMethods_returnsPaymentMethodNonces() {
        let apiClient = BTAPIClient(authorization: BTValidTestClientToken, sendAnalyticsEvent: false)!
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

    func testFetchPaymentMethods_withTokenizationKey_returnsError() {
        let apiClient = BTAPIClient(authorization: "development_tokenization_key", sendAnalyticsEvent: false)!

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

    // MARK: - V3 Client Token

    func testFetchPaymentMethods_performsGETWithCorrectParameter_withVersionThreeClientToken() {
        let clientToken = BTTestClientTokenFactory.token(withVersion: 3)
        let apiClient = BTAPIClient(authorization: clientToken!, sendAnalyticsEvent: false)!
        let mockHTTP = BTFakeHTTP()!
        mockHTTP.stubRequest("GET", toEndpoint: "/client_api/v1/payment_methods", respondWith: [], statusCode: 200)
        apiClient.http = mockHTTP
        let mockConfigurationHTTP = BTFakeHTTP()!
        mockConfigurationHTTP.stubRequest("GET", toEndpoint: "/client_api/v1/configuration", respondWith: [], statusCode: 200)
        apiClient.configurationHTTP = mockConfigurationHTTP

        XCTAssertEqual((apiClient.clientToken!.json["version"] as! BTJSON).asIntegerOrZero(), 3)

        var expectation = self.expectation(description: "Callback invoked")
        apiClient.fetchPaymentMethodNonces() { _,_  in
            XCTAssertEqual(mockHTTP.lastRequestEndpoint, "v1/payment_methods")
            XCTAssertEqual(mockHTTP.lastRequestParameters!["default_first"] as? String, "false")
            XCTAssertEqual(mockHTTP.lastRequestParameters!["session_id"] as? String, apiClient.metadata.sessionId)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)

        expectation = self.expectation(description: "Callback invoked")
        apiClient.fetchPaymentMethodNonces(true) { _,_  in
            XCTAssertEqual(mockHTTP.lastRequestEndpoint, "v1/payment_methods")
            XCTAssertEqual(mockHTTP.lastRequestParameters!["default_first"] as? String, "true")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)

        expectation = self.expectation(description: "Callback invoked")
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
