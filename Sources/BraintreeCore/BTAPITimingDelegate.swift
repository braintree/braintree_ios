import Foundation

protocol BTHTTPNetworkTiming: AnyObject {
    func fetchAPITiming(path: String, startTime: Int, endTime: Int)
}
