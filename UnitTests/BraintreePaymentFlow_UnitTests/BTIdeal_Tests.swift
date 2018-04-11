import UIKit
import XCTest

class BTIdeal_UnitTests: XCTestCase {
    let tempClientToken = "eyJ2ZXJzaW9uIjoyLCJhdXRob3JpemF0aW9uRmluZ2VycHJpbnQiOiJmNTI0M2RkZGRmNzlkNGFiYmI5YjYwMDUzN2ZkZjQ0ZDViNDg0ODVkOWU0ZjJmYmI3YWM5ZTU2MGE3ZDVhZmM5fGNyZWF0ZWRfYXQ9MjAxNy0wNC0xM1QyMTozOTo0My40MjM4NzE4MTUrMDAwMFx1MDAyNmN1c3RvbWVyX2lkPTJENzJCNjQ4LUI0RkMtNDQ1My1BOURDLTI2QTYyMEVGNjQwNFx1MDAyNm1lcmNoYW50X2FjY291bnRfaWQ9aWRlYWxfZXVyXHUwMDI2bWVyY2hhbnRfaWQ9ZGNwc3B5MmJyd2RqcjNxblx1MDAyNnB1YmxpY19rZXk9OXd3cnpxazN2cjN0NG5jOCIsImNvbmZpZ1VybCI6Imh0dHBzOi8vYXBpLnNhbmRib3guYnJhaW50cmVlZ2F0ZXdheS5jb206NDQzL21lcmNoYW50cy9kY3BzcHkyYnJ3ZGpyM3FuL2NsaWVudF9hcGkvdjEvY29uZmlndXJhdGlvbiIsImNoYWxsZW5nZXMiOlsiY3Z2IiwicG9zdGFsX2NvZGUiXSwiZW52aXJvbm1lbnQiOiJzYW5kYm94IiwiY2xpZW50QXBpVXJsIjoiaHR0cHM6Ly9hcGkuc2FuZGJveC5icmFpbnRyZWVnYXRld2F5LmNvbTo0NDMvbWVyY2hhbnRzL2RjcHNweTJicndkanIzcW4vY2xpZW50X2FwaSIsImFzc2V0c1VybCI6Imh0dHBzOi8vYXNzZXRzLmJyYWludHJlZWdhdGV3YXkuY29tIiwiYXV0aFVybCI6Imh0dHBzOi8vYXV0aC52ZW5tby5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tIiwiYW5hbHl0aWNzIjp7InVybCI6Imh0dHBzOi8vY2xpZW50LWFuYWx5dGljcy5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tL2RjcHNweTJicndkanIzcW4ifSwidGhyZWVEU2VjdXJlRW5hYmxlZCI6ZmFsc2UsInBheXBhbEVuYWJsZWQiOmZhbHNlLCJjb2luYmFzZUVuYWJsZWQiOnRydWUsImNvaW5iYXNlIjp7ImNsaWVudElkIjoiN2U5NWUwZmRkYTE0ODQ2NjU4YjM4Zjc3MmJhMmQzMGNkNzhhOWYyMTQ0YzUzOTA4NmU1NzkwYmYzNzdmYmVlZCIsIm1lcmNoYW50QWNjb3VudCI6ImNvaW5iYXNlLXNhbmRib3gtc2hhcmVkLW1lcmNoYW50QGdldGJyYWludHJlZS5jb20iLCJzY29wZXMiOiJhdXRob3JpemF0aW9uczpicmFpbnRyZWUgdXNlciIsInJlZGlyZWN0VXJsIjoiaHR0cHM6Ly9hc3NldHMuYnJhaW50cmVlZ2F0ZXdheS5jb20vY29pbmJhc2Uvb2F1dGgvcmVkaXJlY3QtbGFuZGluZy5odG1sIiwiZW52aXJvbm1lbnQiOiJwcm9kdWN0aW9uIn0sImJyYWludHJlZV9hcGkiOnsiYWNjZXNzX3Rva2VuIjoic2FuZGJveF9mN2RyNWNfZHE2c3MyX2prczd4dF80aHNwc2hfcWI3IiwidXJsIjoiaHR0cHM6Ly9wYXltZW50cy5zYW5kYm94LmJyYWludHJlZS1hcGkuY29tIn0sIm1lcmNoYW50SWQiOiJkY3BzcHkyYnJ3ZGpyM3FuIiwidmVubW8iOiJvZmZsaW5lIiwiYXBwbGVQYXkiOnsic3RhdHVzIjoibW9jayIsImNvdW50cnlDb2RlIjoiVVMiLCJjdXJyZW5jeUNvZGUiOiJFVVIiLCJtZXJjaGFudElkZW50aWZpZXIiOiJtZXJjaGFudC5jb20uYnJhaW50cmVlcGF5bWVudHMuc2FuZGJveC5CcmFpbnRyZWUtRGVtbyIsInN1cHBvcnRlZE5ldHdvcmtzIjpbInZpc2EiLCJtYXN0ZXJjYXJkIiwiYW1leCIsImRpc2NvdmVyIl19LCJtZXJjaGFudEFjY291bnRJZCI6ImlkZWFsX2V1ciJ9"
    var mockAPIClient : MockAPIClient!
    var observers : [NSObjectProtocol] = []
    var idealRequest : BTIdealRequest!
    
    override func setUp() {
        super.setUp()
        
        idealRequest = BTIdealRequest()
        idealRequest.amount = "10"
        idealRequest.currency = "EUR"
        idealRequest.issuer = "some-issuer"
        idealRequest.orderId = NSUUID().uuidString
        mockAPIClient = MockAPIClient(authorization: tempClientToken)!
    }
    
    override func tearDown() {
        for observer in observers { NotificationCenter.default.removeObserver(observer) }
        super.tearDown()
    }
    
    func testFetchIssuingBanks_returnsErrorWhenIdealNotEnabled() {
        mockAPIClient = MockAPIClient(authorization: "development_tokenization_key")!
        let idealDriver = BTPaymentFlowDriver(apiClient: mockAPIClient)
        
        let expectation = self.expectation(description: "Fetch banks expectation")
        idealDriver.fetchIssuingBanks { (banks, error) in
            XCTAssertNil(banks)
            guard let error = error as NSError? else {return}
            XCTAssertEqual(error.domain, BTPaymentFlowDriverErrorDomain)
            XCTAssertEqual(error.code, BTPaymentFlowDriverErrorType.disabled.rawValue)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testFetchIssuingBanks_returnsBanks() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "assetsUrl": "http://assets.example.com",
            "ideal": [
                "routeId": "123123-12342423-12312312"
            ] ])
        let idealDriver = BTPaymentFlowDriver(apiClient: mockAPIClient)
        let expectation = self.expectation(description: "Fetch banks expectation")
        mockAPIClient.cannedResponseBody = BTJSON(value: ["data": [
            ["country_code": "NL",
             "issuers" : [
                ["id":"ASNBNL21", "name":"ASN Bank", "image_file_name":"ASNBNL21.png"],
                ["id":"bunq123", "name":"bunq", "image_file_name":"bunq123.png"]
                ]
            ] ] ])

        idealDriver.fetchIssuingBanks { (banks, err) in
            XCTAssertNil(err)
            XCTAssertEqual(2, banks!.count)
            XCTAssertEqual("ASNBNL21", banks![0].issuerId)
            XCTAssertEqual("ASN Bank", banks![0].name)
            XCTAssertEqual("http://assets.example.com/web/static/images/ideal_issuer-logo_ASNBNL21.png", banks![0].imageUrl)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testFetchIssuingBanks_success_sendsAnalyticsEvents() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "assetsUrl": "http://assets.example.com",
            "ideal": [
                "routeId": "123123-12342423-12312312"
            ] ])
        let idealDriver = BTPaymentFlowDriver(apiClient: mockAPIClient)
        let expectation = self.expectation(description: "Fetch banks expectation")
        mockAPIClient.cannedResponseBody = BTJSON(value: ["data": [
            ["country_code": "NL",
             "issuers" : [
                ["id":"ASNBNL21", "name":"ASN Bank", "image_file_name":"ASNBNL21.png"],
                ["id":"bunq123", "name":"bunq", "image_file_name":"bunq123.png"]
                ]
            ] ] ])
        
        idealDriver.fetchIssuingBanks { (banks, err) in
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 2, handler: nil)
        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains("ios.ideal.load.succeeded"))
    }

    func testFetchIssuingBanks_failure_sendsAnalyticsEvents() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "assetsUrl": "http://assets.example.com",
            "ideal": [
                "routeId": "123123-12342423-12312312"
            ] ])
        let idealDriver = BTPaymentFlowDriver(apiClient: mockAPIClient)
        let expectation = self.expectation(description: "Fetch banks expectation")
        mockAPIClient.cannedResponseError = NSError(domain:"BTError", code: 500, userInfo: nil)

        idealDriver.fetchIssuingBanks { (banks, err) in
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains("ios.ideal.load.failed"))
    }

    func testStartPayment_returnsErrorWhenIdealNotEnabled() {
        mockAPIClient = MockAPIClient(authorization: "development_tokenization_key")!
        let idealDriver = BTPaymentFlowDriver(apiClient: mockAPIClient)
        let expectation = self.expectation(description: "Start payment fails with error")

        idealDriver.startPaymentFlow(idealRequest) { (result, error) in
            guard let error = error as NSError? else {return}
            XCTAssertEqual(error.domain, BTPaymentFlowDriverErrorDomain)
            XCTAssertEqual(error.code, BTPaymentFlowDriverErrorType.disabled.rawValue)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testStartPayment_returnsError_whenIdealRequestAmount_isNil() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "assetsUrl": "http://assets.example.com",
            "ideal": [
                "routeId": "123123-12342423-12312312"
            ] ])
        let idealDriver = BTPaymentFlowDriver(apiClient: mockAPIClient)
        let expectation = self.expectation(description: "Start payment flow fails with error")

        idealRequest = BTIdealRequest()
        idealRequest.currency = "EUR"
        idealRequest.issuer = "some-issuer"
        idealRequest.orderId = NSUUID().uuidString

        idealDriver.startPaymentFlow(idealRequest) { (result, error) in
            guard let error = error as NSError? else {return}
            XCTAssertEqual(error.domain, BTPaymentFlowDriverErrorDomain)
            XCTAssertEqual(error.code, BTPaymentFlowDriverErrorType.integration.rawValue)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testStartPayment_returnsError_whenIdealRequestCurrency_isNil() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "assetsUrl": "http://assets.example.com",
            "ideal": [
                "routeId": "123123-12342423-12312312"
            ] ])
        let idealDriver = BTPaymentFlowDriver(apiClient: mockAPIClient)
        let expectation = self.expectation(description: "Start payment flow fails with error")

        idealRequest = BTIdealRequest()
        idealRequest.amount = "10"
        idealRequest.issuer = "some-issuer"
        idealRequest.orderId = NSUUID().uuidString

        idealDriver.startPaymentFlow(idealRequest) { (result, error) in
            guard let error = error as NSError? else {return}
            XCTAssertEqual(error.domain, BTPaymentFlowDriverErrorDomain)
            XCTAssertEqual(error.code, BTPaymentFlowDriverErrorType.integration.rawValue)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testStartPayment_returnsError_whenIdealRequestIssuer_isNil() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "assetsUrl": "http://assets.example.com",
            "ideal": [
                "routeId": "123123-12342423-12312312"
            ] ])
        let idealDriver = BTPaymentFlowDriver(apiClient: mockAPIClient)
        let expectation = self.expectation(description: "Start payment flow fails with error")

        idealRequest = BTIdealRequest()
        idealRequest.amount = "10"
        idealRequest.currency = "EUR"
        idealRequest.orderId = NSUUID().uuidString

        idealDriver.startPaymentFlow(idealRequest) { (result, error) in
            guard let error = error as NSError? else {return}
            XCTAssertEqual(error.domain, BTPaymentFlowDriverErrorDomain)
            XCTAssertEqual(error.code, BTPaymentFlowDriverErrorType.integration.rawValue)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testStartPayment_returnsError_whenIdealRequestOrderId_isNil() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "assetsUrl": "http://assets.example.com",
            "ideal": [
                "routeId": "123123-12342423-12312312"
            ] ])
        let idealDriver = BTPaymentFlowDriver(apiClient: mockAPIClient)
        let expectation = self.expectation(description: "Start payment flow fails with error")

        idealRequest = BTIdealRequest()
        idealRequest.amount = "10"
        idealRequest.currency = "EUR"
        idealRequest.issuer = "some-issuer"

        idealDriver.startPaymentFlow(idealRequest) { (result, error) in
            guard let error = error as NSError? else {return}
            XCTAssertEqual(error.domain, BTPaymentFlowDriverErrorDomain)
            XCTAssertEqual(error.code, BTPaymentFlowDriverErrorType.integration.rawValue)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testStartPayment_displaysSafariViewControllerWhenAvailable() {
        let viewControllerPresentingDelegate = MockViewControllerPresentationDelegate()
        
        viewControllerPresentingDelegate.requestsPresentationOfViewControllerExpectation = self.expectation(description: "Delegate received requestsPresentationOfViewController")

        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "assetsUrl": "http://assets.example.com",
            "ideal": [
                "routeId": "123123-12342423-12312312"
            ] ])
        let idealDriver = BTPaymentFlowDriver(apiClient: mockAPIClient)
        idealDriver.viewControllerPresentingDelegate = viewControllerPresentingDelegate
        mockAPIClient.cannedResponseBody = BTJSON(value: ["data": [
            "approval_url": "https://www.somebankurl.com",
            "status": "PENDING",
            "id": "123aaa-123-543-777",
            "short_id": "123aaa",
            ] ])
        
        idealDriver.startPaymentFlow(idealRequest) { (result, error) in
            
        }
        
        waitForExpectations(timeout: 4, handler: nil)
    }

    func testStartPayment_returnsPaymentIDViaDelegate() {
        let idealRequestDelegate = MockIdealPaymentRequestDelegate()
        idealRequest.idealPaymentFlowDelegate = idealRequestDelegate
        idealRequestDelegate.idExpectation = self.expectation(description: "Received iDEAL payment ID")

        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "assetsUrl": "http://assets.example.com",
            "ideal": [
                "routeId": "123123-12342423-12312312"
            ] ])
        let idealDriver = BTPaymentFlowDriver(apiClient: mockAPIClient)
        mockAPIClient.cannedResponseBody = BTJSON(value: ["data": [
            "approval_url": "https://www.somebankurl.com",
            "status": "PENDING",
            "id": "123aaa-123-543-777",
            "short_id": "123aaa",
            ] ])

        idealDriver.startPaymentFlow(idealRequest) { (_, _) in
        }

        waitForExpectations(timeout: 4, handler: nil)

        XCTAssertEqual(idealRequestDelegate.id, "123aaa-123-543-777")
    }
    
    func testStartPayment_success_sendsAnalyticsEvents() {
        let viewControllerPresentingDelegate = MockViewControllerPresentationDelegate()
        
        viewControllerPresentingDelegate.requestsPresentationOfViewControllerExpectation = self.expectation(description: "Delegate received requestsPresentationOfViewController")
        
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "assetsUrl": "http://assets.example.com",
            "ideal": [
                "routeId": "123123-12342423-12312312"
            ] ])
        let idealDriver = BTPaymentFlowDriver(apiClient: mockAPIClient)
        idealDriver.viewControllerPresentingDelegate = viewControllerPresentingDelegate
        mockAPIClient.cannedResponseBody = BTJSON(value: ["data": [
            "approval_url": "https://www.somebankurl.com",
            "status": "PENDING",
            "id": "123aaa-123-543-777",
            "short_id": "123aaa",
            ] ])
        
        idealDriver.startPaymentFlow(idealRequest) { (result, error) in
            
        }
        
        waitForExpectations(timeout: 4, handler: nil)
        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains("ios.ideal.start-payment.selected"))
        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains("ios.ideal.webswitch.initiate.succeeded"))
    }
    
    func testStartPayment_failure_sendsAnalyticsEvents() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "assetsUrl": "http://assets.example.com",
            "ideal": [
                "routeId": "123123-12342423-12312312"
            ] ])
        let idealDriver = BTPaymentFlowDriver(apiClient: mockAPIClient)
        mockAPIClient.cannedResponseError = NSError(domain:"BTError", code: 500, userInfo: nil)
        
        let expectation = self.expectation(description: "Start payment expectation")
        idealDriver.startPaymentFlow(idealRequest) { (result, error) in
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 4, handler: nil)
        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains("ios.ideal.start-payment.selected"))
        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains("ios.ideal.start-payment.failed"))
    }
    
    func testStartPayment_successfulResult_callsCompletionBlock() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "assetsUrl": "http://assets.example.com",
            "ideal": [
                "routeId": "123123-12342423-12312312"
            ] ])
        
        let viewControllerPresentingDelegate = MockViewControllerPresentationDelegate()
        viewControllerPresentingDelegate.requestsPresentationOfViewControllerExpectation = self.expectation(description: "Delegate received requestsPresentationOfViewController")
        
        let idealDriver = BTPaymentFlowDriver(apiClient: mockAPIClient)
        idealDriver.viewControllerPresentingDelegate = viewControllerPresentingDelegate
        
        mockAPIClient.cannedResponseBody = BTJSON(value: ["data": [
            "approval_url": "https://www.somebankurl.com",
            "status": "PENDING",
            "id": "123aaa-123-543-777",
            "short_id": "123aaa",
            ] ])
        
        var paymentFinishedExpectation: XCTestExpectation? = nil
        idealDriver.startPaymentFlow(idealRequest) { (result, error) in
            XCTAssertNil(error)
            XCTAssertNotNil(result)
            paymentFinishedExpectation!.fulfill()
        }
        
        waitForExpectations(timeout: 2, handler: nil)
        
        paymentFinishedExpectation = self.expectation(description: "Start payment expectation")
        BTPaymentFlowDriver.handleAppSwitchReturn(URL(string: "http://unused.example.com")!)
        
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testPollForCompletion_pollsUntilRetryCountExceeded() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "assetsUrl": "http://assets.example.com",
            "ideal": [
                "routeId": "123123-12342423-12312312"
            ] ])
        
        let idealDriver = BTPaymentFlowDriver(apiClient: mockAPIClient)
        mockAPIClient.cannedResponseBody = BTJSON(value: ["data": [
            "approval_url": "https://www.somebankurl.com",
            "status": "PENDING",
            "id": "123aaa-123-543-777",
            "short_id": "123aaa",
            ] ])
        
        let start = Date().timeIntervalSince1970
        let retries: Int32 = 3
        let delay: Int32 = 1000
        let expectation = self.expectation(description: "Correct number of polls are executed")
        idealDriver.pollForCompletion(withId: "123aaa-123-543-777", retries: retries, delay: delay) { (result, error) in
            XCTAssertNotNil(result)
            XCTAssertNil(error)
            expectation.fulfill()
        }
        
        // No delay for first call
        let minimumTime = (retries) * delay
        waitForExpectations(timeout: Double(minimumTime * 2), handler: nil)
        
        let finish = Date().timeIntervalSince1970

        XCTAssertTrue((finish - start) * 1000 >= Double(minimumTime))
    }

    func testPollForCompletion_failsToPoll_whenRetriesIsInvalid() {
        let idealDriver = BTPaymentFlowDriver(apiClient: mockAPIClient)

        let expectation = self.expectation(description: "Error returned for invalid retries")
        idealDriver.pollForCompletion(withId: "123aaa-123-543-777", retries: 11, delay: 5000) { (result, error) in
            guard let error = error as NSError? else {return}
            XCTAssertEqual(error.domain, BTPaymentFlowDriverErrorDomain)
            XCTAssertEqual(error.code, BTPaymentFlowDriverErrorType.integration.rawValue)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testPollForCompletion_failsToPoll_whenDelayIsInvalid() {
        let idealDriver = BTPaymentFlowDriver(apiClient: mockAPIClient)

        let expectation = self.expectation(description: "Error returned for invalid retries")
        idealDriver.pollForCompletion(withId: "123aaa-123-543-777", retries: 5, delay: 1) { (result, error) in
            guard let error = error as NSError? else {return}
            XCTAssertEqual(error.domain, BTPaymentFlowDriverErrorDomain)
            XCTAssertEqual(error.code, BTPaymentFlowDriverErrorType.integration.rawValue)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testStartPayment_makesDelegateCallbacks_forContextSwitchEvents() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "assetsUrl": "http://assets.example.com",
            "ideal": [
                "routeId": "123123-12342423-12312312"
            ] ])

        let viewControllerPresentingDelegate = MockViewControllerPresentationDelegate()
        viewControllerPresentingDelegate.requestsPresentationOfViewControllerExpectation = self.expectation(description: "Delegate received requestsPresentationOfViewController")

        let idealDriver = BTPaymentFlowDriver(apiClient: mockAPIClient)
        idealDriver.viewControllerPresentingDelegate = viewControllerPresentingDelegate
        let appSwitchDelegate = MockAppSwitchDelegate()
        idealDriver.appSwitchDelegate = appSwitchDelegate

        mockAPIClient.cannedResponseBody = BTJSON(value: ["data": [
            "approval_url": "https://www.somebankurl.com",
            "status": "PENDING",
            "id": "123aaa-123-543-777",
            "short_id": "123aaa",
            ] ])

        var paymentFinishedExpectation: XCTestExpectation? = nil
        idealDriver.startPaymentFlow(idealRequest) { (result, error) in
            paymentFinishedExpectation!.fulfill()
        }

        paymentFinishedExpectation = self.expectation(description: "Payment finished expectation")
        BTPaymentFlowDriver.handleAppSwitchReturn(URL(string: "http://unused.example.com")!)

        waitForExpectations(timeout: 2, handler: nil)

        XCTAssertTrue(appSwitchDelegate.appContextWillSwitchCalled)
        XCTAssertTrue(appSwitchDelegate.appContextDidReturnCalled)
    }
}

