import XCTest
@testable import BraintreeCore
@testable import BraintreeDataCollector

class BraintreeDataCollector_IntegrationTests: XCTestCase {

    var dataCollector: BTDataCollector?
    let authorization: String = "sandbox_9dbg82cq_dcpspy2brwdjr3qn"

    override func setUp() {
        super.setUp()
        let apiClient = BTAPIClient(authorization: BTIntegrationTestsConstants.sandboxTokenizationKey)!
        dataCollector = BTDataCollector(authorization: authorization)
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
