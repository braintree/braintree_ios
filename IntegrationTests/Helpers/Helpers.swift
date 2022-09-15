import Foundation

@objcMembers public class Helpers: NSObject {

    public static let _sharedInstance = Helpers()

    private override init() {}

    public class func sharedInstance() -> Helpers {
        Self._sharedInstance
    }

    public func futureYear() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        return dateFormatter.string(from: Date())
    }
}
