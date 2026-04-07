import Foundation

class CardNumberFieldViewModel: CardFieldsViewModelProtocol {
    
    @Published private(set) var value: String = ""
    @Published private(set) var validationState: ValidationResult = .valid
    @Published var isFocused: Bool = false
    
    private let validator = CardNumberValidator()

    // TODO: Implement auto-advance logic w/ state change
    var shouldAutoAdvance: Bool { false }

    // TODO: Implement validation and formatting w/ state change
    func updateValue(_ newValue: String) {
        value = newValue
    }
}
