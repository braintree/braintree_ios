import Foundation
@testable import BraintreeDataCollector

class MockBTDataCollector: BTDataCollector {

    var cannedDeviceData: String?
    var cannedDataCollectorError: Error?
    
    override func collectDeviceData(riskCorrelationID: String? = nil, completion: @escaping (String?, Error?) -> Void) {
        completion(cannedDeviceData, cannedDataCollectorError)
    }
}
