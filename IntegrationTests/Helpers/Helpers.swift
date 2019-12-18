import Foundation

@objc class Helpers : NSObject {

    private static let _sharedInstance = Helpers()

    private override init() {}

    @objc class func sharedInstance() -> Helpers {
        return Helpers._sharedInstance
    }

    @objc func futureYear() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        return dateFormatter.string(from: Date())
    }
}
