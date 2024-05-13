import Foundation

extension Date {
    
    public var utcTimestampMilliseconds: Int {
        Int(round(timeIntervalSince1970 * 1000))
    }
}
