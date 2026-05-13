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

        if case .valid = validator.validate(newValue) {
            validationState = .valid
        }
    }
}
