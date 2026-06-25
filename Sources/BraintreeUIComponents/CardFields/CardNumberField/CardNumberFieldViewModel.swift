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
                let result = validator.validate(value)
                validationState = result == .validating ? .invalid("Card number is invalid") : result
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

    func formatted(digits: String) -> String {
        var result = ""
        var index = digits.startIndex
        for (groupIndex, groupSize) in cardBrand.digitGroups.enumerated() {
            guard index < digits.endIndex else { break }
            if groupIndex > 0 { result += " " }
            let end = digits.index(index, offsetBy: groupSize, limitedBy: digits.endIndex) ?? digits.endIndex
            result += digits[index..<end]
            index = end
        }
        return result
    }

    func updateValue(_ newValue: String) {
        value = newValue
        cardBrand = validator.detectBrand(from: newValue)

        let result = validator.validate(newValue)
        if case .valid = result {
            validationState = .valid
        } else if validationState == .valid {
            validationState = .validating
        }
    }
}
