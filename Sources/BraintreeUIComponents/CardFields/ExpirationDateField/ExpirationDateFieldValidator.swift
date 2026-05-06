import Foundation

final class ExpirationDateFieldValidator: CardFieldsValidatorProtocol {

    private static let maxFutureYears = 20

    let currentDate: Date

    init(currentDate: Date = Date()) {
        self.currentDate = currentDate
    }

    func validate(_ value: String) -> ValidationResult {
        guard !value.isEmpty else {
            return .invalid("Expiration date is required")
        }

        guard value.allSatisfy({ $0.isNumber || $0 == "/" }) else {
            return .invalid("Expiration date is invalid")
        }

        let parts = value.split(separator: "/", omittingEmptySubsequences: false).map(String.init)

        guard parts.count == 2,
            let month = Int(parts[0]),
            let year = Int(parts[1]),
            parts[1].count == 2 else {
            return .validating
        }

        guard (1...12).contains(month) else {
            return .invalid("Expiration date is invalid")
        }

        guard isValid(month: month, twoDigitYear: year) else {
            return .invalid("Expiration date is invalid")
        }

        return .valid
    }

    // MARK: - Private

    private func isValid(month: Int, twoDigitYear: Int) -> Bool {
        var components = DateComponents()
        components.year = (twoDigitYear % 100) + 2000
        components.month = month

        let nextMonth = month + 1
        if nextMonth > 12 {
            components.month = 1
            components.year = (components.year ?? 2000) + 1
        } else {
            components.month = nextMonth
        }

        let calendar = Calendar(identifier: .gregorian)
        guard let expiryDate = calendar.date(from: components) else {
            return false
        }

        guard currentDate < expiryDate else {
            return false
        }

        guard let farFuture = calendar.date(byAdding: .year, value: Self.maxFutureYears, to: currentDate) else {
            return false
        }

        return expiryDate <= farFuture
    }
}
