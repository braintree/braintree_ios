import Foundation

@MainActor
class CardNumberFieldViewModel: ObservableObject {

    @Published private(set) var value: String = ""
    @Published private(set) var validationState: ValidationResult = .valid
    @Published private(set) var cardBrand: CardBrand = .unknown
    @Published var isFocused: Bool = false {
        didSet {
            // Show validation errors only after the user leaves the field
            if !isFocused {
                validationState = validator.validate(value)
            }
        }
    }

    var shouldAutoAdvance: Bool { validationState == .valid && !value.isEmpty }
    var maxLength: Int { cardBrand.maxLength }

    // MARK: - Private Properties

    private let validator: CardNumberFieldValidator

    init(validator: CardNumberFieldValidator = CardNumberFieldValidator()) {
        self.validator = validator
    }

    // MARK: - Internal Methods

    func updateValue(_ newValue: String) {
        value = newValue
        cardBrand = validator.detectBrand(from: newValue)

        let result = validator.validate(newValue)
        if result == .valid {
            validationState = .valid
        }
    }
}
