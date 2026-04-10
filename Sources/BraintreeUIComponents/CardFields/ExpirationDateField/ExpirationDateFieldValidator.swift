import Foundation

final class ExpirationDateFieldValidator: CardFieldsValidatorProtocol {

    func validate(_ value: String) -> ValidationResult {
        // TODO: Implement MM/YY format and expiration date validation
        return .valid
    }
}
