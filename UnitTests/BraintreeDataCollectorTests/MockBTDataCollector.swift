import Foundation
@testable import BraintreeDataCollector

class MockBTDataCollector: BTDataCollector {

    var cannedDeviceData: String?
    var cannedDataCollectorError: Error?

    override func collectDeviceData(_ completion: @escaping (String?, Error?) -> Void) {
        completion(cannedDeviceData, cannedDataCollectorError)
    }

    override func collectDeviceDataOnSuccess(
        riskCorrelationID: String,
        _ completion: @escaping (String?, Error?) -> Void
    ) {
        completion(cannedDeviceData, cannedDataCollectorError)
    }
}
