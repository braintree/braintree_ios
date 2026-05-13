import Foundation

@MainActor
class ExpirationDateFieldViewModel: ObservableObject {

    @Published private(set) var value: String = ""
    @Published private(set) var validationState: ValidationResult = .valid
    @Published var isFocused: Bool = false {
        didSet {
            // Show validation errors only after the user leaves the field
            if !isFocused {
                validationState = validator.validate(value)
            }
        }
    }

    var shouldAutoAdvance: Bool { validationState == .valid && !value.isEmpty }
    let maxLength = 4

    // MARK: - Private Properties

    private let validator: ExpirationDateFieldValidator

    init(validator: ExpirationDateFieldValidator = ExpirationDateFieldValidator()) {
        self.validator = validator
    }

    // MARK: - Internal Methods

    func updateValue(_ newValue: String) {
        value = newValue

        let result = validator.validate(newValue)
        if result == .valid {
            validationState = .valid
        }
    }
}
