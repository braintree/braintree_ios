import Foundation
@testable import BraintreeDataCollector

class MockBTDataCollector: BTDataCollector {

    var cannedDeviceData: String?
    var cannedDataCollectorError: Error?

    override func collectDeviceData(riskCorrelationID: String? = nil, completion: @escaping (String?, Error?) -> Void) {
        if let error = cannedDataCollectorError {
            completion(nil, error)
        } else if let riskCorrelationID = riskCorrelationID {
            // When a riskCorrelationID is provided, return it in the device data
            completion("{\"correlation_id\":\"\(riskCorrelationID)\"}", nil)
        } else {
            completion(cannedDeviceData, nil)
        }
    }
}
