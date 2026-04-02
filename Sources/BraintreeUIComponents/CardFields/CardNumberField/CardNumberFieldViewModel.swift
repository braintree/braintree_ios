import Foundation

class CardNumberFieldViewModel: CardFieldsViewModelProtocol {
    
    @Published private(set) var value: String = ""
    @Published private(set) var validationState: ValidationResult = .valid
    @Published var isFocused: Bool = false

    // TODO: Implement auto-advance logic w/ state change
    var shouldAutoAdvance: Bool { false }

    // TODO: Implement validation and formatting
    func updateValue(_ newValue: String) {
        value = newValue
    }
}
