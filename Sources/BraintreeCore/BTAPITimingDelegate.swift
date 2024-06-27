import Foundation

protocol BTHTTPNetworkTiming: AnyObject {
    func fetchAPITiming(path: String, connectionStartTime: Int?, requestStartTime: Int?, startTime: Int, endTime: Int)
}
