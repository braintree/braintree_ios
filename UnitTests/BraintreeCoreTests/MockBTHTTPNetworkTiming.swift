@testable import BraintreeCore
import Foundation

class MockNetworkTimingDelegate: BTHTTPNetworkTiming {
    var didCallFetchAPITiming = false
    var receivedPath: String?
    var receivedConnectionStartTime: Int?
    var receivedRequestStartTime: Int?
    var receivedStartTime: Int?
    var receivedEndTime: Int?
    
    func fetchAPITiming(path: String, connectionStartTime: Int?, requestStartTime: Int?, startTime: Int, endTime: Int) {
        didCallFetchAPITiming = true
        receivedPath = path
        receivedConnectionStartTime = connectionStartTime
        receivedRequestStartTime = requestStartTime
        receivedStartTime = startTime
        receivedEndTime = endTime
    }
}
