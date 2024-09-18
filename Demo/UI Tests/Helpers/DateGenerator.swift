import Foundation

class DateGenerator {
    
    static let sharedInstance = DateGenerator()

    let calendar = Calendar.init(identifier: .gregorian)

    private init() {}

    func threeDSecure2TestingDate() -> String {
        let year = calendar.component(.year, from: Date()) + 3
        return "01/\(year)"
    }
}
