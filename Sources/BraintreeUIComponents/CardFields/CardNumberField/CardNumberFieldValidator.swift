import Foundation

final class CardNumberFieldValidator: CardFieldsValidatorProtocol {

    func validate(_ value: String) -> ValidationResult {
        // TODO: Implement Luhn check and card brand detection
        return .valid
    }
}
