import XCTest
import BraintreePayPal
import BraintreeTestShared
import SafariServices

class BTPayPalDriver_BillingAgreements_Tests: XCTestCase {
    var mockAPIClient: MockAPIClient!
    var payPalDriver: BTPayPalDriver!

    override func setUp() {
        super.setUp()

        mockAPIClient = MockAPIClient(authorization: "development_tokenization_key")!
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "paypalEnabled": true,
            "paypal": [
                "environment": "offline"
            ] ])
        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "paymentResource": [
                "redirectUrl": "http://fakeURL.com"
            ] ])
        payPalDriver = BTPayPalDriver(apiClient: mockAPIClient)
    }

    func testBillingAgreement_whenAPIClientIsNil_callsBackWithError() {
        payPalDriver.apiClient = nil

        let request = BTPayPalVaultRequest()
        let expectation = self.expectation(description: "Billing Agreement fails with error")
        payPalDriver.requestBillingAgreement(request) { (tokenizedPayPalAccount, error) -> Void in
            XCTAssertNil(tokenizedPayPalAccount)
            guard let error = error as NSError? else {return}
            XCTAssertEqual(error.domain, BTPayPalDriverErrorDomain)
            XCTAssertEqual(error.code, BTPayPalDriverErrorType.integration.rawValue)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testBillingAgreement_whenRemoteConfigurationFetchFails_callsBackWithConfigurationError() {
        mockAPIClient.cannedConfigurationResponseBody = nil
        mockAPIClient.cannedConfigurationResponseError = NSError(domain: "", code: 0, userInfo: nil)

        let request = BTPayPalVaultRequest()
        let expectation = self.expectation(description: "Checkout fails with error")
        payPalDriver.requestBillingAgreement(request) { (_, error) -> Void in
            XCTAssertEqual(error! as NSError, self.mockAPIClient.cannedConfigurationResponseError!)
            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 1)
    }

    func testBillingAgreement_whenRemoteConfigurationFetchSucceeds_postsToCorrectEndpoint() {
        let request = BTPayPalVaultRequest()
        request.billingAgreementDescription = "description"

        payPalDriver.requestBillingAgreement(request) { _,_  -> Void in }

        XCTAssertEqual("v1/paypal_hermes/setup_billing_agreement", mockAPIClient.lastPOSTPath)
        guard let lastPostParameters = mockAPIClient.lastPOSTParameters else { XCTFail(); return }

        XCTAssertEqual(lastPostParameters["description"] as? String, "description")
        XCTAssertEqual(lastPostParameters["return_url"] as? String, "sdk.ios.braintree://onetouch/v1/success")
        XCTAssertEqual(lastPostParameters["cancel_url"] as? String, "sdk.ios.braintree://onetouch/v1/cancel")
    }

    func testBillingAgreement_whenPayPalCreditOffered_performsSwitchCorrectly() {
        let request = BTPayPalVaultRequest()
        request.offerCredit = true

        payPalDriver.requestBillingAgreement(request) { _,_  in }

        XCTAssertNotNil(payPalDriver.authenticationSession)
        XCTAssertTrue(payPalDriver.isAuthenticationSessionStarted)

        // Ensure the payment resource had the correct parameters
        XCTAssertEqual("v1/paypal_hermes/setup_billing_agreement", mockAPIClient.lastPOSTPath)
        guard let lastPostParameters = mockAPIClient.lastPOSTParameters else {
            XCTFail()
            return
        }
        XCTAssertEqual(lastPostParameters["offer_paypal_credit"] as? Bool, true)

        // Make sure analytics event was sent when switch occurred
        let postedAnalyticsEvents = mockAPIClient.postedAnalyticsEvents

        XCTAssertTrue(postedAnalyticsEvents.contains("ios.paypal-ba.webswitch.credit.offered.started"))
    }

    func testBillingAgreement_whenBrowserSwitchSucceeds_tokenizesPayPalAccount() {
        let returnURL = URL(string: "bar://onetouch/v1/success?token=hermes_token")!
        payPalDriver.handleBrowserSwitchReturn(returnURL, paymentType: .vault) { (_, _) in }

        XCTAssertEqual(mockAPIClient.lastPOSTPath, "/v1/payment_methods/paypal_accounts")
        guard let lastPostParameters = mockAPIClient.lastPOSTParameters else {
            XCTFail()
            return
        }
        guard let paypalAccount = lastPostParameters["paypal_account"] as? [String:Any] else {
            XCTFail()
            return
        }

        let client = paypalAccount["client"] as? [String:String]
        XCTAssertEqual(client?["paypal_sdk_version"], "version")
        XCTAssertEqual(client?["platform"], "iOS")
        XCTAssertEqual(client?["product_name"], "PayPal")

        let response = paypalAccount["response"] as? [String:String]
        XCTAssertEqual(response?["webURL"], "bar://onetouch/v1/success?token=hermes_token")

        XCTAssertEqual(paypalAccount["response_type"] as? String, "web")
    }

    func testBillingAgreement_whenBrowserSwitchCancels_callsBackWithNoResultAndError() {
        let returnURL = URL(string: "bar://onetouch/v1/cancel?token=hermes_token")!

        let expectation = self.expectation(description: "completion block called")
        
        payPalDriver.handleBrowserSwitchReturn(returnURL, paymentType: .vault) { (nonce, error) in
            XCTAssertNil(nonce)
            XCTAssertEqual((error! as NSError).domain, BTPayPalDriverErrorDomain)
            XCTAssertEqual((error! as NSError).code, BTPayPalDriverErrorType.canceled.rawValue)
            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 1)
    }

    func testBillingAgreement_whenSetupBillingAgreementCreationSuccessful_performsPayPalRequestAppSwitch() {
        payPalDriver.requestBillingAgreement(BTPayPalVaultRequest()) { _,_  -> Void in }

        XCTAssertNotNil(payPalDriver.authenticationSession)
        XCTAssertTrue(payPalDriver.isAuthenticationSessionStarted)
    }

    func testBillingAgreement_whenSetupBillingAgreementCreationFails_callsBackWithError() {
        mockAPIClient.cannedResponseError = NSError(domain: "", code: 0, userInfo: nil)

        let expectation = self.expectation(description: "Checkout fails with error")

        payPalDriver.requestBillingAgreement(BTPayPalVaultRequest()) { (_, error) -> Void in
            XCTAssertEqual(error! as NSError, self.mockAPIClient.cannedResponseError!)
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 1)
    }

    func testBillingAgreement_whenCreditFinancingNotReturned_shouldNotSendCreditAcceptedAnalyticsEvent() {
        mockAPIClient.cannedResponseBody = BTJSON(value: [ "paypalAccounts":
            [
                [
                    "description": "jane.doe@example.com",
                    "details": [
                        "email": "jane.doe@example.com",
                    ],
                    "nonce": "a-nonce",
                    "type": "PayPalAccount",
                    ]
            ]
            ])
        payPalDriver.payPalRequest = BTPayPalVaultRequest()

        let returnURL = URL(string: "bar://hello/world")!
        payPalDriver.handleBrowserSwitchReturn(returnURL, paymentType: .vault) { (_, _) in }

        XCTAssertFalse(mockAPIClient.postedAnalyticsEvents.contains("ios.paypal-ba.credit.accepted"))
    }

    func testBillingAgreement_whenCreditFinancingReturned_shouldSendCreditAcceptedAnalyticsEvent() {
        mockAPIClient.cannedResponseBody = BTJSON(
            value: [ "paypalAccounts": [
                [
                    "description": "jane.doe@example.com",
                    "details": [
                        "email": "jane.doe@example.com",
                        "creditFinancingOffered": [
                            "cardAmountImmutable": true,
                            "monthlyPayment": [
                                "currency": "USD",
                                "value": "13.88",
                            ],
                            "payerAcceptance": true,
                            "term": 18,
                            "totalCost": [
                                "currency": "USD",
                                "value": "250.00",
                            ],
                            "totalInterest": [
                                "currency": "USD",
                                "value": "0.00",
                            ],
                        ],
                    ],
                    "nonce": "a-nonce",
                    "type": "PayPalAccount",
                ]
            ]
            ])

        payPalDriver.payPalRequest = BTPayPalVaultRequest()

        let returnURL = URL(string: "bar://onetouch/v1/success?token=hermes_token")!
        payPalDriver.handleBrowserSwitchReturn(returnURL, paymentType: .vault) { (_, _) in }

        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains("ios.paypal-ba.credit.accepted"))
    }
}
