import Foundation

extension Date {
    
    var utcTimpestampMilliseconds: Int {
        Int(round(Date().timeIntervalSince1970 * 1000))
    }
}
