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
            connectionStartTime: 123,
            correlationID: "fake-correlation-id-1",
            endpoint: "/v1/paypal_hermes/setup_billing_agreement",
            endTime: 111222333444555,
            errorDescription: "fake-error-description-1",
            eventName: "fake-event-1", 
            isConfigFromCache: false,
            isVaultRequest: false,
            linkType: LinkType.universal.rawValue,
            payPalContextID: "fake-order-id",
            requestStartTime: 456,
            startTime: 999888777666
        ),
        FPTIBatchData.Event(
            connectionStartTime: nil,
            correlationID: nil,
            endpoint: nil,
            endTime: nil,
            errorDescription: nil,
            eventName: "fake-event-2", 
            isConfigFromCache: true,
            isVaultRequest: true,
            linkType: nil,
            payPalContextID: "fake-order-id-2",
            requestStartTime: nil,
            startTime: nil
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
        XCTAssertEqual(batchParams["paypal_installed"] as! Bool, false)
        XCTAssertEqual(batchParams["venmo_installed"] as! Bool, false)

        // Verify event-level parameters
        XCTAssertNotNil(eventParams[0]["t"] as? String)
        XCTAssertNotNil(eventParams[1]["t"] as? String)
        XCTAssertEqual(eventParams[0]["event_name"] as? String, "fake-event-1")
        XCTAssertEqual(eventParams[1]["event_name"] as? String, "fake-event-2")
        XCTAssertEqual(eventParams[0]["tenant_name"] as? String, "Braintree")
        XCTAssertEqual(eventParams[1]["tenant_name"] as? String, "Braintree")
        XCTAssertEqual(eventParams[0]["link_type"] as? String, "universal")
        XCTAssertNil(eventParams[1]["link_type"])
        XCTAssertEqual(eventParams[0]["paypal_context_id"] as! String, "fake-order-id")
        XCTAssertEqual(eventParams[1]["paypal_context_id"] as! String, "fake-order-id-2")
        XCTAssertEqual(eventParams[0]["error_desc"] as? String, "fake-error-description-1")
        XCTAssertNil(eventParams[1]["error_desc"])
        XCTAssertEqual(eventParams[0]["correlation_id"] as? String, "fake-correlation-id-1")
        XCTAssertNil(eventParams[1]["correlation_id"])
        XCTAssertEqual(eventParams[0]["is_vault"] as? Bool, false)
        XCTAssertEqual(eventParams[1]["is_vault"] as? Bool, true)
        XCTAssertEqual(eventParams[0]["config_cached"] as? Bool, false)
        XCTAssertEqual(eventParams[1]["config_cached"] as? Bool, true)
        XCTAssertEqual(eventParams[0]["endpoint"] as? String, "/v1/paypal_hermes/setup_billing_agreement")
        XCTAssertNil(eventParams[1]["endpoint"])
        XCTAssertEqual(eventParams[0]["end_time"] as? Int, 111222333444555)
        XCTAssertNil(eventParams[1]["end_time"])
        XCTAssertEqual(eventParams[0]["start_time"] as? Int, 999888777666)
        XCTAssertNil(eventParams[1]["start_time"])
        XCTAssertEqual(eventParams[0]["connect_start_time"] as? Int, 123)
        XCTAssertNil(eventParams[1]["connect_start_time"])
        XCTAssertEqual(eventParams[0]["request_start_time"] as? Int, 456)
        XCTAssertNil(eventParams[1]["request_start_time"])
    }
}


