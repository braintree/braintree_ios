import UIKit
import XCTest
@testable import BraintreeCore

final class FPTIBatchData_Tests: XCTestCase {
    
    var sut: FPTIBatchData!
    
    let batchMetadata = FPTIBatchData.Metadata(
        authorizationFingerprint: "fake-auth",
        environment: "fake-env",
        integrationType: "fake-integration-type",
        merchantID: "fake-merchant-id",
        sessionID: "fake-session",
        tokenizationKey: "fake-auth"
    )
    
    let eventParams = [
        FPTIBatchData.Event(
            correlationID: "fake-correlation-id-1",
            errorDescription: "fake-error-description-1",
            eventName: "fake-event-1",
            timestamp: "fake-time-1"
        ),
        FPTIBatchData.Event(
            correlationID: nil,
            errorDescription: nil,
            eventName: "fake-event-2",
            timestamp: "fake-time-2"
        )
    ]
    
    override func setUp() {
        super.setUp()
        
        sut = FPTIBatchData(metadata: batchMetadata, events: eventParams)
    }
    
    func testInit_formatsJSONBody() throws {
        let jsonBody = try sut.toDictionary()
        
        guard let events = jsonBody["events"] as? [[String: Any]] else {
            XCTFail("JSON body missing top level `events` key.")
            return
        }
        
        guard let eventParams = events[0]["event_params"] as? [[String: Any]] else {
            XCTFail("JSON body missing `event_params` key.")
            return
        }
        
        guard let batchParams = events[0]["batch_params"] as? [String: Any]  else {
            XCTFail("JSON body missing `batch_params` key.")
            return
        }

        // Verify batch parameters
        XCTAssertEqual(batchParams["app_id"] as? String, "com.apple.dt.xctest.tool")
        XCTAssertEqual(batchParams["app_name"] as? String, "xctest")
        XCTAssertEqual(batchParams["auth_fingerprint"] as! String, "fake-auth")
        XCTAssertTrue((batchParams["c_sdk_ver"] as! String).matches("^\\d+\\.\\d+\\.\\d+(-[0-9a-zA-Z-]+)?$"))
        XCTAssertTrue((batchParams["client_os"] as! String).matches("iOS \\d+\\.\\d+|iPadOS \\d+\\.\\d+"))
        XCTAssertEqual(batchParams["comp"] as? String, "braintreeclientsdk")
        XCTAssertEqual(batchParams["device_manufacturer"] as? String, "Apple")
        XCTAssertEqual(batchParams["merchant_sdk_env"] as? String, "fake-env")
        XCTAssertEqual(batchParams["event_source"] as? String, "mobile-native")
        XCTAssertTrue((batchParams["ios_package_manager"] as! String).matches("Carthage or Other|CocoaPods|Swift Package Manager"))
        XCTAssertEqual(batchParams["api_integration_type"] as? String, "fake-integration-type")
        XCTAssertEqual(batchParams["is_simulator"] as? Bool, true)
        XCTAssertNotNil(batchParams["mapv"] as? String) // Unable to specify bundle version number within test targets
        XCTAssertTrue((batchParams["mobile_device_model"] as! String).matches("iPhone\\d,\\d|x86_64|arm64"))
        XCTAssertEqual(batchParams["merchant_id"] as! String, "fake-merchant-id")
        XCTAssertEqual(batchParams["platform"] as? String, "iOS")
        XCTAssertEqual(batchParams["session_id"] as? String, "fake-session")
        XCTAssertEqual(batchParams["tokenization_key"] as! String, "fake-auth")

        // Verify event-level parameters
        XCTAssertEqual(eventParams[0]["t"] as? String, "fake-time-1")
        XCTAssertEqual(eventParams[1]["t"] as? String, "fake-time-2")
        XCTAssertEqual(eventParams[0]["event_name"] as? String, "fake-event-1")
        XCTAssertEqual(eventParams[1]["event_name"] as? String, "fake-event-2")
        XCTAssertEqual(eventParams[0]["tenant_name"] as? String, "Braintree")
        XCTAssertEqual(eventParams[1]["tenant_name"] as? String, "Braintree")
        XCTAssertEqual(eventParams[0]["error_desc"] as? String, "fake-error-description-1")
        XCTAssertNil(eventParams[1]["error_desc"])
        XCTAssertEqual(eventParams[0]["correlation_id"] as? String, "fake-correlation-id-1")
        XCTAssertNil(eventParams[1]["correlation_id"])
    }
}
