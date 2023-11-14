import Foundation

class Helpers: NSObject {

    static let shared = Helpers()

    func futureYear() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        return dateFormatter.string(from: Date())
    }
}
