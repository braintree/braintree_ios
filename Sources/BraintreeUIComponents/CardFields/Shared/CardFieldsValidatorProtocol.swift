import Foundation

protocol CardFieldsValidatorProtocol {
    func validate(_ value: String) -> ValidationResult
}
