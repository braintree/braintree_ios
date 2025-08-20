import UIKit
import XCTest
import AuthenticationServices
@testable import BraintreeLocalPayment
@testable import BraintreeCore
@testable import BraintreeTestShared

class BTLocalPaymentClient_UnitTests: XCTestCase {
    let tempClientToken = "eyJ2ZXJzaW9uIjoyLCJhdXRob3JpemF0aW9uRmluZ2VycHJpbnQiOiI3ODJhZmFlNDJlZTNiNTA4NWUxNmMzYjhkZTY3OGQxNTJhODFlYzk5MTBmZDNhY2YyYWU4MzA2OGI4NzE4YWZhfGNyZWF0ZWRfYXQ9MjAxNS0wOC0yMFQwMjoxMTo1Ni4yMTY1NDEwNjErMDAwMFx1MDAyNmN1c3RvbWVyX2lkPTM3OTU5QTE5LThCMjktNDVBNC1CNTA3LTRFQUNBM0VBOEM4Nlx1MDAyNm1lcmNoYW50X2lkPWRjcHNweTJicndkanIzcW5cdTAwMjZwdWJsaWNfa2V5PTl3d3J6cWszdnIzdDRuYzgiLCJjb25maWdVcmwiOiJodHRwczovL2FwaS5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tOjQ0My9tZXJjaGFudHMvZGNwc3B5MmJyd2RqcjNxbi9jbGllbnRfYXBpL3YxL2NvbmZpZ3VyYXRpb24iLCJjaGFsbGVuZ2VzIjpbXSwiZW52aXJvbm1lbnQiOiJzYW5kYm94IiwiY2xpZW50QXBpVXJsIjoiaHR0cHM6Ly9hcGkuc2FuZGJveC5icmFpbnRyZWVnYXRld2F5LmNvbTo0NDMvbWVyY2hhbnRzL2RjcHNweTJicndkanIzcW4vY2xpZW50X2FwaSIsImFzc2V0c1VybCI6Imh0dHBzOi8vYXNzZXRzLmJyYWludHJlZWdhdGV3YXkuY29tIiwiYXV0aFVybCI6Imh0dHBzOi8vYXV0aC52ZW5tby5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tIiwiYW5hbHl0aWNzIjp7InVybCI6Imh0dHBzOi8vY2xpZW50LWFuYWx5dGljcy5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tIn0sInRocmVlRFNlY3VyZUVuYWJsZWQiOnRydWUsInRocmVlRFNlY3VyZSI6eyJsb29rdXBVcmwiOiJodHRwczovL2FwaS5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tOjQ0My9tZXJjaGFudHMvZGNwc3B5MmJyd2RqcjNxbi90aHJlZV9kX3NlY3VyZS9sb29rdXAifSwicGF5cGFsRW5hYmxlZCI6dHJ1ZSwicGF5cGFsIjp7ImRpc3BsYXlOYW1lIjoiQWNtZSBXaWRnZXRzLCBMdGQuIChTYW5kYm94KSIsImNsaWVudElkIjpudWxsLCJwcml2YWN5VXJsIjoiaHR0cDovL2V4YW1wbGUuY29tL3BwIiwidXNlckFncmVlbWVudFVybCI6Imh0dHA6Ly9leGFtcGxlLmNvbS90b3MiLCJiYXNlVXJsIjoiaHR0cHM6Ly9hc3NldHMuYnJhaW50cmVlZ2F0ZXdheS5jb20iLCJhc3NldHNVcmwiOiJodHRwczovL2NoZWNrb3V0LnBheXBhbC5jb20iLCJkaXJlY3RCYXNlVXJsIjpudWxsLCJhbGxvd0h0dHAiOnRydWUsImVudmlyb25tZW50Tm9OZXR3b3JrIjp0cnVlLCJlbnZpcm9ubWVudCI6Im9mZmxpbmUiLCJ1bnZldHRlZE1lcmNoYW50IjpmYWxzZSwiYnJhaW50cmVlQ2xpZW50SWQiOiJtYXN0ZXJjbGllbnQzIiwiYmlsbGluZ0FncmVlbWVudHNFbmFibGVkIjpmYWxzZSwibWVyY2hhbnRBY2NvdW50SWQiOiJzdGNoMm5mZGZ3c3p5dHc1IiwiY3VycmVuY3lJc29Db2RlIjoiVVNEIn0sImNvaW5iYXNlRW5hYmxlZCI6dHJ1ZSwiY29pbmJhc2UiOnsiY2xpZW50SWQiOiIxMWQyNzIyOWJhNThiNTZkN2UzYzAxYTA1MjdmNGQ1YjQ0NmQ0ZjY4NDgxN2NiNjIzZDI1NWI1NzNhZGRjNTliIiwibWVyY2hhbnRBY2NvdW50IjoiY29pbmJhc2UtZGV2ZWxvcG1lbnQtbWVyY2hhbnRAZ2V0YnJhaW50cmVlLmNvbSIsInNjb3BlcyI6ImF1dGhvcml6YXRpb25zOmJyYWludHJlZSB1c2VyIiwicmVkaXJlY3RVcmwiOiJodHRwczovL2Fzc2V0cy5icmFpbnRyZWVnYXRld2F5LmNvbS9jb2luYmFzZS9vYXV0aC9yZWRpcmVjdC1sYW5kaW5nLmh0bWwiLCJlbnZpcm9ubWVudCI6Im1vY2sifSwibWVyY2hhbnRJZCI6ImRjcHNweTJicndkanIzcW4iLCJ2ZW5tbyI6Im9mZmxpbmUiLCJhcHBsZVBheSI6eyJzdGF0dXMiOiJtb2NrIiwiY291bnRyeUNvZGUiOiJVUyIsImN1cnJlbmN5Q29kZSI6IlVTRCIsIm1lcmNoYW50SWRlbnRpZmllciI6Im1lcmNoYW50LmNvbS5icmFpbnRyZWVwYXltZW50cy5zYW5kYm94LkJyYWludHJlZS1EZW1vIiwic3VwcG9ydGVkTmV0d29ya3MiOlsidmlzYSIsIm1hc3RlcmNhcmQiLCJhbWV4Il19fQ=="
    var mockAPIClient : MockAPIClient!
    var localPaymentRequest : BTLocalPaymentRequest!
    var mockLocalPaymentRequestDelegate = MockLocalPaymentRequestDelegate()

    override func setUp() {
        super.setUp()
        localPaymentRequest = BTLocalPaymentRequest(
            paymentType: "ideal",
            amount: "10",
            currencyCode: "EUR"
        )
        localPaymentRequest.localPaymentFlowDelegate = mockLocalPaymentRequestDelegate
        mockAPIClient = MockAPIClient(authorization: tempClientToken)
    }
    
    func testStartPayment_returnsErrorWhenConfigurationNil() {
        mockAPIClient.cannedConfigurationResponseBody = nil
        let client = BTLocalPaymentClient(authorization: tempClientToken)
        client.apiClient = mockAPIClient
        let expectation = expectation(description: "Start payment fails with error")

        client.startPaymentFlow(localPaymentRequest) { _, error in
            guard let error = error as NSError? else { return }
            XCTAssertEqual(error.domain, BTLocalPaymentError.errorDomain)
            XCTAssertEqual(error.code, BTLocalPaymentError.fetchConfigurationFailed.errorCode)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    func testStartPayment_returnsErrorWhenLocalPaymentsNotEnabled() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [ "paypalEnabled": false ])
        let client = BTLocalPaymentClient(authorization: tempClientToken)
        client.apiClient = mockAPIClient
        let expectation = expectation(description: "Start payment fails with error")

        client.startPaymentFlow(localPaymentRequest) { _, error in
            guard let error = error as NSError? else { return }
            XCTAssertEqual(error.domain, BTLocalPaymentError.errorDomain)
            XCTAssertEqual(error.code, BTLocalPaymentError.disabled.errorCode)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    func testStartPayment_returnsErrorWhenLocalPaymentDelegateIsNil() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: ["paypalEnabled": true])
        let client = BTLocalPaymentClient(authorization: tempClientToken)
        let expectation = expectation(description: "Start payment fails with error")
        localPaymentRequest.localPaymentFlowDelegate = nil

        client.startPaymentFlow(localPaymentRequest) { result, error in
            print("Callback called with result: \(String(describing: result)), error: \(String(describing: error))")
            
            guard let error = error as NSError? else {
                XCTFail("Expected error but got none - delegate should be required")
                expectation.fulfill()
                return
            }
            
            // Debug: Print actual error details
            print("Actual error domain: \(error.domain)")
            print("Actual error code: \(error.code)")
            print("Expected domain: \(BTLocalPaymentError.errorDomain)")
            print("Expected code: \(BTLocalPaymentError.integration.errorCode)")
            
            // Verify error properties
            XCTAssertEqual(error.domain, BTLocalPaymentError.errorDomain,
                          "Error domain mismatch - got \(error.domain), expected \(BTLocalPaymentError.errorDomain)")
            XCTAssertEqual(error.code, BTLocalPaymentError.integration.errorCode,
                          "Error code mismatch - got \(error.code), expected \(BTLocalPaymentError.integration.errorCode)")
            
            expectation.fulfill()
        }

        waitForExpectations(timeout: 10)
    }

    func testStartPayment_postsAllCreationParameters() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [ "paypalEnabled": true ])

        let client = BTLocalPaymentClient(authorization: tempClientToken)
        client.apiClient = mockAPIClient

        mockAPIClient.cannedResponseBody = BTJSON(
            value: [
                "paymentResource": [
                    "redirectUrl": "https://www.somebankurl.com",
                    "paymentToken": "123aaa-123-543-777",
                ]
            ]
        )

        let postalAddress = BTPostalAddress()
        postalAddress.countryCodeAlpha2 = "NL"
        postalAddress.region = "CA"
        postalAddress.postalCode = "2585 GJ"
        postalAddress.streetAddress = "836486 of 22321 Park Lake"
        postalAddress.extendedAddress = "#102"
        postalAddress.locality = "Den Haag"
        
        let paymentRequest = BTLocalPaymentRequest(
            paymentType: "ideal",
            amount: "1.01",
            currencyCode: "EUR",
            paymentTypeCountryCode: "NL",
            merchantAccountID: "customer-nl-merchant-account",
            address: postalAddress,
            displayName: "My Brand!",
            email: "lingo-buyer@paypal.com",
            givenName: "Linh",
            surname: "Ngo",
            phone: "639847934",
            isShippingAddressRequired: true,
            bic: "111222333"
        )
        paymentRequest.localPaymentFlowDelegate = mockLocalPaymentRequestDelegate
        
        client.startPaymentFlow(paymentRequest) { _, _ in }

        XCTAssertEqual(mockAPIClient.lastPOSTParameters!["merchant_account_id"] as? String, "customer-nl-merchant-account")
        XCTAssertEqual(mockAPIClient.lastPOSTParameters!["funding_source"] as? String, "ideal")
        XCTAssertEqual(mockAPIClient.lastPOSTParameters!["payment_type_country_code"] as? String, "NL")
        XCTAssertEqual(mockAPIClient.lastPOSTParameters!["currency_iso_code"] as? String, "EUR")
        XCTAssertEqual(mockAPIClient.lastPOSTParameters!["amount"] as? String, "1.01")
        XCTAssertEqual(mockAPIClient.lastPOSTParameters!["first_name"] as? String, "Linh")
        XCTAssertEqual(mockAPIClient.lastPOSTParameters!["last_name"] as? String, "Ngo")
        XCTAssertEqual(mockAPIClient.lastPOSTParameters!["phone"] as? String, "639847934")
        XCTAssertEqual(mockAPIClient.lastPOSTParameters!["payer_email"] as? String, "lingo-buyer@paypal.com")
        XCTAssertEqual(mockAPIClient.lastPOSTParameters!["intent"] as! String, "sale")
        XCTAssertEqual(mockAPIClient.lastPOSTParameters!["return_url"] as! String, "sdk.ios.braintree://x-callback-url/braintree/local-payment/success")
        XCTAssertEqual(mockAPIClient.lastPOSTParameters!["cancel_url"] as! String, "sdk.ios.braintree://x-callback-url/braintree/local-payment/cancel")
        XCTAssertEqual(mockAPIClient.lastPOSTParameters!["line1"] as? String, "836486 of 22321 Park Lake")
        XCTAssertEqual(mockAPIClient.lastPOSTParameters!["line2"] as? String, "#102")
        XCTAssertEqual(mockAPIClient.lastPOSTParameters!["city"] as? String, "Den Haag")
        XCTAssertEqual(mockAPIClient.lastPOSTParameters!["state"] as? String, "CA")
        XCTAssertEqual(mockAPIClient.lastPOSTParameters!["postal_code"] as? String, "2585 GJ")
        XCTAssertEqual(mockAPIClient.lastPOSTParameters!["country_code"] as? String, "NL")
        XCTAssertEqual(mockAPIClient.lastPOSTParameters!["first_name"] as! String, "Linh")
        XCTAssertEqual(mockAPIClient.lastPOSTParameters!["last_name"] as! String, "Ngo")
        XCTAssertEqual(mockAPIClient.lastPOSTParameters!["payer_email"] as! String, "lingo-buyer@paypal.com")
        XCTAssertEqual(mockAPIClient.lastPOSTParameters!["phone"] as! String, "639847934")
        XCTAssertEqual(mockAPIClient.lastPOSTParameters!["bic"] as! String, "111222333")

        guard let experienceProfile = mockAPIClient.lastPOSTParameters!["experience_profile"] as? [String: Any] else {
            XCTFail()
            return
        }

        XCTAssertFalse(experienceProfile["no_shipping"] as! Bool)
        XCTAssertEqual(experienceProfile["brand_name"] as? String, "My Brand!")
    }

    func testStartPayment_returnsErrorWhenRedirectUrlIsMissing() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [ "paypalEnabled": true ])

        let client = BTLocalPaymentClient(authorization: tempClientToken)
        client.apiClient = mockAPIClient
        mockAPIClient.cannedResponseBody = BTJSON(value: ["paymentResource": ["paymentToken": "123aaa-123-543-777"]])
        let expectation = expectation(description: "Start payment fails with error")

        client.startPaymentFlow(localPaymentRequest) { _, error in
            guard let error = error as NSError? else { return }
            XCTAssertEqual(error.domain, BTLocalPaymentError.errorDomain)
            XCTAssertEqual(error.code, BTLocalPaymentError.appSwitchFailed.errorCode)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 4)
    }

    func testStartPayment_returnsErrorWhenPaymentTokenIsMissing() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [ "paypalEnabled": true ])

        let client = BTLocalPaymentClient(authorization: tempClientToken)
        client.apiClient = mockAPIClient
        mockAPIClient.cannedResponseBody = BTJSON(
            value: [
                "paymentResource": [
                    "redirectUrl": "https://www.somebankurl.com",
                ]
            ]
        )
        let expectation = expectation(description: "Start payment fails with error")

        client.startPaymentFlow(localPaymentRequest) { _, error in
            guard let error = error as NSError? else { return }
            XCTAssertEqual(error.domain, BTLocalPaymentError.errorDomain)
            XCTAssertEqual(error.code, BTLocalPaymentError.appSwitchFailed.errorCode)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 4)
    }

    func testStartPayment_returnsPaymentID_inDelegateCallback() {
        mockLocalPaymentRequestDelegate.idExpectation = expectation(description: "Received payment ID")
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [ "paypalEnabled": true ])

        let client = BTLocalPaymentClient(authorization: tempClientToken)
        client.apiClient = mockAPIClient
        mockAPIClient.cannedResponseBody = BTJSON(
            value: [
                "paymentResource": [
                    "redirectUrl": "https://www.somebankurl.com",
                    "paymentToken": "123aaa-123-543-abv",
                ]
            ]
        )

        client.startPaymentFlow(localPaymentRequest) { _, _ in }

        waitForExpectations(timeout: 4)

        XCTAssertEqual(mockLocalPaymentRequestDelegate.paymentID, "123aaa-123-543-abv")
    }

    func testStartPayment_success_sendsAnalyticsEvents() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [ "paypalEnabled": true ])

        let mockWebAuthenticationSession = MockWebAuthenticationSession()
        mockWebAuthenticationSession.cannedSessionDidDisplay = true
        mockWebAuthenticationSession.cannedResponseURL =  URL(string: "https://example/sepa/success?success=true")
        mockWebAuthenticationSession.cannedErrorResponse = nil

        mockAPIClient.cannedResponseBody = BTJSON(
            value: [
                "paymentResource": [
                    "redirectUrl": "https://www.somebankurl.com",
                    "paymentToken": "123aaa-123-543-777",
                ]
            ]
        )
        
        let client = BTLocalPaymentClient(authorization: tempClientToken)
        client.apiClient = mockAPIClient
        client.webAuthenticationSession = mockWebAuthenticationSession
        client.startPaymentFlow(localPaymentRequest) { _, _ in }

        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains(BTLocalPaymentAnalytics.paymentStarted))
        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains(BTLocalPaymentAnalytics.browserPresentationSucceeded))
    }

    func testStartPayment_browser_cancel_sendsAnalyticEvent() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [ "paypalEnabled": true ])
        let mockWebAuthenticationSession = MockWebAuthenticationSession()
        mockWebAuthenticationSession.cannedSessionDidDisplay = true
        mockWebAuthenticationSession.cannedResponseURL =  nil
        
        mockWebAuthenticationSession.cannedErrorResponse = ASWebAuthenticationSessionError(
            _bridgedNSError: NSError(
                domain: ASWebAuthenticationSessionError.errorDomain,
                code: ASWebAuthenticationSessionError.canceledLogin.rawValue,
                userInfo: ["Description": "Mock cancellation error description."]
            )
        )
        
        let client = BTLocalPaymentClient(authorization: tempClientToken)
        client.apiClient = mockAPIClient
        client.webAuthenticationSession = mockWebAuthenticationSession
        mockAPIClient.cannedResponseBody = BTJSON(
            value: [
                "paymentResource": [
                    "redirectUrl": "https://www.somebankurl.com",
                    "paymentToken": "123aaa-123-543-777",
                ]
            ]
        )

        client.startPaymentFlow(localPaymentRequest) { _, _ in }

        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains(BTLocalPaymentAnalytics.browserLoginAlertCanceled))
    }

    func testStartPayment_failure_sendsAnalyticsEvents() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [ "paypalEnabled": true ])
        let mockWebAuthenticationSession = MockWebAuthenticationSession()
        mockWebAuthenticationSession.cannedSessionDidDisplay = false
        mockWebAuthenticationSession.cannedResponseURL =  nil
        
        mockWebAuthenticationSession.cannedErrorResponse = ASWebAuthenticationSessionError(
            _bridgedNSError: NSError(
                domain: ASWebAuthenticationSessionError.errorDomain,
                code: ASWebAuthenticationSessionError.presentationContextNotProvided.rawValue,
                userInfo: ["Description": "Mock failure to present browser error description."]
            )
        )

        let client = BTLocalPaymentClient(authorization: tempClientToken)
        client.apiClient = mockAPIClient
        client.webAuthenticationSession = mockWebAuthenticationSession
        mockAPIClient.cannedResponseBody = BTJSON(
            value: [
                "paymentResource": [
                    "redirectUrl": "https://www.somebankurl.com",
                    "paymentToken": "123aaa-123-543-777",
                ]
            ]
        )

        client.startPaymentFlow(localPaymentRequest) { _, _ in }
        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains(BTLocalPaymentAnalytics.paymentFailed))
        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains(BTLocalPaymentAnalytics.browserPresentationFailed))
    }

    func testStartPayment_successfulResult_callsCompletionBlock() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [ "paypalEnabled": true ])

        let client = BTLocalPaymentClient(authorization: tempClientToken)
        client.apiClient = mockAPIClient

        mockAPIClient.cannedResponseBody = BTJSON(
            value: [
                "paymentResource": [
                    "redirectUrl": "https://www.somebankurl.com",
                    "paymentToken": "123aaa-123-543-777",
                ]
            ]
        )

        client.startPaymentFlow(localPaymentRequest) { _, _ in }

        client.handleOpen(URL(string: "com.braintreepayments.demo.payments://x-callback-url/braintree/local-payment/success?PayerID=PCKXQCZ6J3YXU&paymentId=PAY-79C90584AX7152104LNY4OCY&token=EC-0A351828G20802249")!)

        let paypalAccount = mockAPIClient.lastPOSTParameters?["paypal_account"] as! [String:Any]
        XCTAssertNotNil(paypalAccount["correlation_id"] as? String)
        XCTAssertEqual(self.mockAPIClient.postedPayPalContextID, "123aaa-123-543-777")
    }

    func testStartPayment_whenPaymentResourcePayPalContextID_sendsPayPalContextIDInAnalytics() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [ "paypalEnabled": true ])

        let client = BTLocalPaymentClient(authorization: tempClientToken)
        client.apiClient = mockAPIClient

        mockAPIClient.cannedResponseBody = BTJSON(
            value: [
                "paymentResource": [
                    "redirectUrl": "https://www.somebankurl.com",
                    "paymentToken": "123aaa-123-543-777"
                ]
            ]
        )

        client.startPaymentFlow(localPaymentRequest) { _, _ in }

        client.handleOpen(URL(string: "com.braintreepayments.demo.payments://x-callback-url/braintree/local-payment/success")!)

        XCTAssertEqual(mockAPIClient.postedPayPalContextID, "123aaa-123-543-777")
    }

    func testStartPayment_whenPaymentResourceDoesNotContainPayPalContextID_doesNotSendPayPalContextIDInAnalytics() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [ "paypalEnabled": true ])

        let client = BTLocalPaymentClient(authorization: tempClientToken)

        mockAPIClient.cannedResponseBody = BTJSON(
            value: [
                "paymentResource": [
                    "redirectUrl": "https://www.somebankurl.com",
                    "paymentToken": ""
                ]
            ]
        )

        client.startPaymentFlow(localPaymentRequest) { _, _ in }

        client.handleOpen(URL(string: "com.braintreepayments.demo.payments://x-callback-url/braintree/local-payment/success")!)

        XCTAssertNil(mockAPIClient.postedPayPalContextID)
    }

    func testStartPayment_cancelResult_callsCompletionBlock() {
        let client = BTLocalPaymentClient(authorization: tempClientToken)

        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [ "paypalEnabled": true ])
        mockAPIClient.cannedResponseBody = BTJSON(
            value: [
                "paymentResource": [
                    "redirectUrl": "https://www.somebankurl.com",
                    "paymentToken": "123aaa-123-543-777",
                ]
            ]
        )
        
        client.startPaymentFlow(localPaymentRequest) { _, error in
            guard let error = error as NSError? else { return }
            XCTAssertEqual(error.domain, BTLocalPaymentError.errorDomain)
            XCTAssertEqual(error.code, BTLocalPaymentError.canceled("flow-type").errorCode)
        }

        client.handleOpen(URL(string: "com.braintreepayments.demo.payments://x-callback-url/braintree/local-payment/cancel?paymentId=PAY-79C90584AX7152104LNY4OCY")!)
    }

    func testStartPayment_callsCompletionBlock_withError_tokenizationFailure() {
        let client = BTLocalPaymentClient(authorization: tempClientToken)
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [ "paypalEnabled": true ])
        mockAPIClient.cannedResponseBody = BTJSON(
            value: [
                "paymentResource": [
                    "redirectUrl": "https://www.somebankurl.com",
                    "paymentToken": "123aaa-123-543-777",
                ]
            ]
        )

        client.startPaymentFlow(localPaymentRequest) { result, error in
            XCTAssertNotNil(error)
            XCTAssertNil(result)
        }
        
        mockAPIClient.cannedResponseBody = nil
    }
    
    func testHandleOpenURL_postAllLocalPaymentPayPalAccountsParameters() {
        let client = BTLocalPaymentClient(authorization: tempClientToken)
        client.apiClient = mockAPIClient
        
        mockAPIClient.cannedResponseBody = BTJSON(
            value: [
                "paymentResource": [
                    "redirectUrl": "https://www.somebankurl.com",
                    "paymentToken": "123aaa-123-543-777",
                ]
            ]
        )
        
        let paymentRequest = BTLocalPaymentRequest(
            paymentType: "ideal",
            amount: "1.01",
            currencyCode: "EUR"
        )
        paymentRequest.localPaymentFlowDelegate = mockLocalPaymentRequestDelegate

        client.startPaymentFlow(paymentRequest) { _, _ in }

        client.handleOpen(
            URL(string: "com.braintreepayments.demo.payments://x-callback-url/braintree/local-payment/success")!
        )

        guard
            let payPalAccount = mockAPIClient.lastPOSTParameters!["paypal_account"] as? [String: Any],
            let meta = mockAPIClient.lastPOSTParameters!["_meta"] as? [String: Any] else {
            XCTFail()
            return
        }

        XCTAssertEqual(payPalAccount["response_type"] as? String, "web")
        XCTAssertEqual(payPalAccount["intent"] as? String, "sale")
        XCTAssertEqual(meta["source"] as? String, "unknown")
        XCTAssertEqual(meta["integration"] as? String, "custom")
        
        guard
            let options = payPalAccount["options"] as? [String: Any],
            let response = payPalAccount["response"] as? [String: Any] else {
            XCTFail()
            return
        }
        
        XCTAssertFalse(options["validate"] as! Bool)
        XCTAssertEqual(response["webURL"] as? String, "com.braintreepayments.demo.payments://x-callback-url/braintree/local-payment/success")
    }
    
    func testHandleOpenURL_whenMissingAccountsResponse_returnsError() {
        let client = BTLocalPaymentClient(authorization: tempClientToken)
        let expectation = self.expectation(description: "Calls onPaymentComplete with result")

        mockAPIClient.cannedResponseBody = nil
        client.apiClient = mockAPIClient
        
        client.merchantCompletion = { _, error in
            guard let error = error as NSError? else { return }
            XCTAssertEqual(error.domain, BTLocalPaymentError.errorDomain)
            XCTAssertEqual(error.code, BTLocalPaymentError.noAccountData.errorCode)
            expectation.fulfill()
        }
        
        client.handleOpen(URL(string: "www.fake.com")!)
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
}
