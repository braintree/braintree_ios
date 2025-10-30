import XCTest
@testable import BraintreeCore
@testable import BraintreeDataCollector

class BraintreeDataCollector_IntegrationTests: XCTestCase {

    var dataCollector: BTDataCollector?

    override func setUp() {
        super.setUp()
        dataCollector = BTDataCollector(authorization: BTIntegrationTestsConstants.sandboxTokenizationKey)
    }

    override func tearDown() {
        dataCollector = nil
    }

    func testCollectDeviceData_returnsDeviceData() {
        let expectation = expectation(description: "Device data collected")

        dataCollector?.collectDeviceData() { deviceData, error in
            guard let deviceData else {
                XCTFail("Expect device data to be returned")
                return
            }
            XCTAssertTrue(deviceData.contains("correlation_id"))
            XCTAssertNil(error)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 10)
    }
}
