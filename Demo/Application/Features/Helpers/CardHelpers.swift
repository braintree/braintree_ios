import Foundation
import BraintreeCard

enum Format {
    case date
    case year
}

enum CardHelpers {

    static func newCard(from cardFormView: BTCardFormView) -> BTCard {
        BTCard(
            number: cardFormView.cardNumber,
            expirationMonth: cardFormView.expirationMonth,
            expirationYear: cardFormView.expirationYear,
            cvv: cardFormView.cvv
        )
    }

    static func generateFuture(_ format: Format) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy"

        let futureYear = Calendar.current.date(byAdding: .year, value: 3, to: Date())

        switch format {
        case .date:
            let monthString = "12"
            let yearString = dateFormatter.string(from: futureYear ?? Date.distantFuture)

            return "\(monthString)/\(yearString)"
        case .year:
            return dateFormatter.string(from: futureYear ?? Date.distantFuture)
        }
    }
}
