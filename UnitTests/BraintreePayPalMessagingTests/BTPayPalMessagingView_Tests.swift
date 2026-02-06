import XCTest
@testable import BraintreeCore
@testable import BraintreeTestShared
@testable import BraintreePayPalMessaging

final class BTPayPalMessagingView_Tests: XCTestCase {

    var mockAPIClient = MockAPIClient(authorization: "development_tokenization_key")
    var mockDelegate = MockBTPayPalMessagingDelegate()
    let mockTokenizationKey = "development_tokenization_key"

    @MainActor
    func testStart_withConfigurationError_callsDelegateWithError() async {
        mockAPIClient.cannedConfigurationResponseError = NSError(domain: "SomeError", code: 999)

        let payPalMessageView = BTPayPalMessagingView(authorization: mockTokenizationKey)
        payPalMessageView.apiClient = mockAPIClient
        payPalMessageView.delegate = mockDelegate

        let expectation = expectation(description: "Delegate receives error")
        mockDelegate.didReceiveErrorExpectation = expectation

        payPalMessageView.start()

        await fulfillment(of: [expectation], timeout: 2)

        XCTAssertEqual((mockDelegate.error as? NSError)?.domain, "SomeError")
        XCTAssertEqual((mockDelegate.error as? NSError)?.code, 999)
    }

    @MainActor
    func testStart_withNilConfiguration_callsDelegateWithErrorAndSendsAnalytics() async {
        let payPalMessageView = BTPayPalMessagingView(authorization: mockTokenizationKey)
        payPalMessageView.delegate = mockDelegate
        payPalMessageView.apiClient = mockAPIClient

        let expectation = expectation(description: "Delegate receives error")
        mockDelegate.didReceiveErrorExpectation = expectation

        payPalMessageView.start()

        await fulfillment(of: [expectation], timeout: 2)

        XCTAssertNotNil(mockDelegate.error)
        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains(BTPayPalMessagingAnalytics.started))
        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains(BTPayPalMessagingAnalytics.failed))
    }

    @MainActor
    func testStart_withNoClientID_callsDelegateWithError() async {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(
            value: [
                "paypal": ["clientId": nil]
            ] as [String: Any?]
        )

        let payPalMessageView = BTPayPalMessagingView(authorization: mockTokenizationKey)
        payPalMessageView.delegate = mockDelegate
        payPalMessageView.apiClient = mockAPIClient

        let expectation = expectation(description: "Delegate receives error")
        mockDelegate.didReceiveErrorExpectation = expectation

        payPalMessageView.start()

        await fulfillment(of: [expectation], timeout: 2)

        XCTAssertEqual(mockDelegate.error as? BTPayPalMessagingError, BTPayPalMessagingError.payPalClientIDNotFound)
        XCTAssertEqual((mockDelegate.error as? NSError)?.domain, "com.braintreepayments.BTPayPalMessagingErrorDomain")
        XCTAssertEqual((mockDelegate.error as? BTPayPalMessagingError)?.errorCode, 1)
        XCTAssertEqual((mockDelegate.error as? BTPayPalMessagingError)?.errorDescription, "Could not find PayPal client ID in Braintree configuration.")
    }

    @MainActor
    func testStart_withClientID_firesWillAppearAndSendsAnalytics() async {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(
            value: [
                "paypal": ["clientId": "a-fake-client-id"]
            ] as [String: Any?]
        )

        let payPalMessageView = BTPayPalMessagingView(authorization: mockTokenizationKey)
        payPalMessageView.delegate = mockDelegate
        payPalMessageView.apiClient = mockAPIClient

        let expectation = expectation(description: "Delegate will appear")
        mockDelegate.willAppearExpectation = expectation

        payPalMessageView.start()

        await fulfillment(of: [expectation], timeout: 2)

        XCTAssertTrue(mockDelegate.willAppear)
        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains(BTPayPalMessagingAnalytics.started))
    }
    
    @MainActor
    func testStart_withClientID_callingMultipleTimes_doesNotIncreaseNumberOfSubviews() async {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(
            value: [
                "paypal": ["clientId": "a-fake-client-id"]
            ] as [String: Any?]
        )

        let payPalMessageView = BTPayPalMessagingView(authorization: mockTokenizationKey)
        payPalMessageView.delegate = mockDelegate
        payPalMessageView.apiClient = mockAPIClient
        XCTAssertEqual(payPalMessageView.subviews.count, 0)

        let expectation = expectation(description: "First delegate will appear")
        mockDelegate.willAppearExpectation = expectation

        payPalMessageView.start()

        await fulfillment(of: [expectation], timeout: 2)

        XCTAssertTrue(mockDelegate.willAppear)
        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains(BTPayPalMessagingAnalytics.started))
        XCTAssertEqual(payPalMessageView.subviews.count, 1)

        payPalMessageView.start()

        XCTAssertTrue(mockDelegate.willAppear)
        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains(BTPayPalMessagingAnalytics.started))
        XCTAssertEqual(payPalMessageView.subviews.count, 1)
    }
}
