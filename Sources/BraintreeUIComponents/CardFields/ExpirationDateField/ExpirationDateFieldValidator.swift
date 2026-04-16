import Foundation

final class ExpirationDateFieldValidator: CardFieldsValidatorProtocol {
    
    func validate(_ subject: String) -> ValidationResult {
        return .valid
    }
}
