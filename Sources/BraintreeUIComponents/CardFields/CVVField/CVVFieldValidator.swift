import Foundation

final class CVVFieldValidator: CardFieldsValidatorProtocol {

    /// The expected CVV length for the detected card brand. If `nil`, both 3 and 4 digits are accepted.
    var expectedLength: Int?

    init(expectedLength: Int? = nil) {
        self.expectedLength = expectedLength
    }

    func validate(_ value: String) -> ValidationResult {
        guard !value.isEmpty else {
            return .invalid("CVV is required")
        }

        guard value.allSatisfy({ $0.isNumber }) else {
            return .invalid("CVV is invalid")
        }

        if let expectedLength {
            guard value.count == expectedLength else {
                return .invalid("CVV is invalid")
            }
        } else {
            guard value.count == 3 || value.count == 4 else {
                return .invalid("CVV is invalid")
            }
        }

        return .valid
    }
}
