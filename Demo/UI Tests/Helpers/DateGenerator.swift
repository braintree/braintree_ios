import Foundation

class UITestDateGenerator {

    static let sharedInstance = UITestDateGenerator()

    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/yy"
        return formatter
    }()

    let calendar = Calendar.init(identifier: .gregorian)

    private init() {}

    func threeDSecure2TestingDate() -> String {
        let year = calendar.component(.year, from: Date()) + 3
        return "01/\(year)"
    }

    func futureDate() -> String {
        let futureDate = calendar.date(byAdding: .year, value: 3, to: Date())!
        return dateFormatter.string(from: futureDate)
    }
}
