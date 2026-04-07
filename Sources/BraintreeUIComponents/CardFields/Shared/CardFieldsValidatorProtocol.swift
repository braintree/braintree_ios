import Foundation

protocol CardFieldsValidatorProtocol {
    func isValid(_ subject: String) -> ValidationResult
}
