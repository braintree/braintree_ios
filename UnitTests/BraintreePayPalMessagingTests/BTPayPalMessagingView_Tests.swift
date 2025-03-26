import XCTest
@testable import BraintreeCore
@testable import BraintreeTestShared
@testable import BraintreePayPalMessaging

final class BTPayPalMessagingView_Tests: XCTestCase {

    var mockAPIClient = MockAPIClient(authorization: "development_tokenization_key")!
    var mockDelegate = MockBTPayPalMessagingDelegate()
    let mockTokenizationKey = "development_tokenization_key"

    func testStart_withConfigurationError_callsDelegateWithError() {
        mockAPIClient.cannedConfigurationResponseError = NSError(domain: "SomeError", code: 999)

        let payPalMessageView = BTPayPalMessagingView(authorization: mockTokenizationKey)
        payPalMessageView.delegate = mockDelegate
        payPalMessageView.start()

        XCTAssertEqual((mockDelegate.error as? NSError)?.domain, "SomeError")
        XCTAssertEqual((mockDelegate.error as? NSError)?.code, 999)
    }

    func testStart_withNilConfiguration_callsDelegateWithErrorAndSendsAnalytics() {
        let payPalMessageView = BTPayPalMessagingView(authorization: mockTokenizationKey)
        payPalMessageView.delegate = mockDelegate
        payPalMessageView.start()

        XCTAssertEqual(mockDelegate.error as? BTPayPalMessagingError, BTPayPalMessagingError.fetchConfigurationFailed)
        XCTAssertEqual((mockDelegate.error as? BTPayPalMessagingError)?.errorCode, 0)
        XCTAssertEqual((mockDelegate.error as? BTPayPalMessagingError)?.errorDescription, "Failed to fetch Braintree configuration.")
        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains(BTPayPalMessagingAnalytics.started))
        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains(BTPayPalMessagingAnalytics.failed))
    }

    func testStart_withNoClientID_callsDelegateWithError() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(
            value: [
                "paypal": ["clientId": nil]
            ] as [String: Any?]
        )

        let payPalMessageView = BTPayPalMessagingView(authorization: mockTokenizationKey)
        payPalMessageView.delegate = mockDelegate
        payPalMessageView.start()

        XCTAssertEqual(mockDelegate.error as? BTPayPalMessagingError, BTPayPalMessagingError.payPalClientIDNotFound)
        XCTAssertEqual((mockDelegate.error as? NSError)?.domain, "com.braintreepayments.BTPayPalMessagingErrorDomain")
        XCTAssertEqual((mockDelegate.error as? BTPayPalMessagingError)?.errorCode, 1)
        XCTAssertEqual((mockDelegate.error as? BTPayPalMessagingError)?.errorDescription, "Could not find PayPal client ID in Braintree configuration.")
    }

    func testStart_withClientID_firesWillAppearAndSendsAnalytics() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(
            value: [
                "paypal": ["clientId": "a-fake-client-id"]
            ] as [String: Any?]
        )

        let payPalMessageView = BTPayPalMessagingView(authorization: mockTokenizationKey)
        payPalMessageView.delegate = mockDelegate
        payPalMessageView.start()

        XCTAssertTrue(mockDelegate.willAppear)
        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains(BTPayPalMessagingAnalytics.started))
    }
    
    func testStart_withClientID_callingMultipleTimes_doesNotIncreaseNumberOfSubviews() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(
            value: [
                "paypal": ["clientId": "a-fake-client-id"]
            ] as [String: Any?]
        )
        
        let payPalMessageView = BTPayPalMessagingView(authorization: mockTokenizationKey)
        payPalMessageView.delegate = mockDelegate
        XCTAssertEqual(payPalMessageView.subviews.count, 0)
        
        payPalMessageView.start()
        
        XCTAssertTrue(mockDelegate.willAppear)
        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains(BTPayPalMessagingAnalytics.started))
        XCTAssertEqual(payPalMessageView.subviews.count, 1)

        payPalMessageView.start()
        
        XCTAssertTrue(mockDelegate.willAppear)
        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains(BTPayPalMessagingAnalytics.started))
        XCTAssertEqual(payPalMessageView.subviews.count, 1)
    }
}
