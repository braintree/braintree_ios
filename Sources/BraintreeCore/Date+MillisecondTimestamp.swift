import Foundation

extension Date {
    
    var utcTimestampMilliseconds: Int {
        Int(round(Date().timeIntervalSince1970 * 1000))
    }
}
