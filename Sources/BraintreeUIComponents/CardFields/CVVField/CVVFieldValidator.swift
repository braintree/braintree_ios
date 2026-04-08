import Foundation

final class CVVFieldValidator: CardFieldsValidatorProtocol {
    
    func validate(_ subject: String) -> ValidationResult {
        return .valid
    }
}
