import Foundation

class Helpers {

    static let sharedInstance = Helpers()

    let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/yy"
            return formatter
    }()

    private init() {}

    @objc func futureDate() -> String {
        let futureDate = Calendar.current.date(byAdding: .year, value: 3, to: Date())!
        return dateFormatter.string(from: futureDate)
    }

    @objc func pastDate() -> String {
        let pastDate = Calendar.current.date(byAdding: .year, value: -3, to: Date())!
        return dateFormatter.string(from: pastDate)
    }

}
