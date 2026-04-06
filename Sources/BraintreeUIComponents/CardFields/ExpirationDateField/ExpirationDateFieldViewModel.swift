import Foundation

class ExpirationDateFieldViewModel: CardFieldsViewModelProtocol {
    
    @Published private(set) var value: String = ""
    @Published private(set) var validationState: ValidationResult = .valid
    @Published var isFocused: Bool = false
    
    // TODO: Update auto-advance logic
    var shouldAutoAdvance: Bool { false }
    
    // TODO: Implement expiration fiel validation and formatting checks
    func updateValue(_ newValue: String) {
        value = newValue
    }
}
