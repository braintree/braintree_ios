import SwiftUI

@MainActor
class CVVFieldViewModel: ObservableObject {

    @Published private(set) var value: String = ""
    @Published private(set) var validationState: ValidationResult = .valid
    @Published var isFocused: Bool = false {
        didSet {
            // Show validation errors only after the user leaves the field
            if !isFocused {
                let result = validator.validate(value)
                validationState = result == .validating ? .invalid("CVV is invalid") : result
            }
        }
    }

    var shouldAutoAdvance: Bool { validationState == .valid && !value.isEmpty }

    var maxLength: Int { validator.expectedLength ?? 4 }

    // MARK: - Internal Properties

    /// Individual characters with their masking state — drives the custom display
    @Published private(set) var characters: [CVVCharacter] = []

    // MARK: - Private Properties

    private let validator: CVVFieldValidator

    init(validator: CVVFieldValidator = CVVFieldValidator()) {
        self.validator = validator
    }

    // MARK: - Internal Methods

    func updateExpectedLength(_ length: Int?) {
        validator.expectedLength = length
    }

    func updateValue(_ newValue: String) {
        let digits = String(newValue.filter { $0.isNumber }.prefix(maxLength))
        value = digits

        let result = validator.validate(digits)
        switch result {
        case .valid:
            validationState = .valid
        case .invalid:
            break // preserve existing state — don't regress from .invalid
        case .validating:
            if case .invalid(_) = validationState { } else {
                validationState = .validating
            }
        }

        let oldCount = characters.count
        let newCount = digits.count

        if newCount > oldCount {
            for i in oldCount..<newCount {
                let index = digits.index(digits.startIndex, offsetBy: i)
                let newCharacter = CVVCharacter(value: digits[index])
                characters.append(newCharacter)
                scheduleMasking(for: newCharacter.id)
            }
        } else if newCount < oldCount {
            characters = Array(characters.prefix(newCount))
        } else {
            // Same length but different digits (e.g. paste over existing value)
            for i in 0..<newCount {
                let index = digits.index(digits.startIndex, offsetBy: i)
                if characters[i].value != digits[index] {
                    let newCharacter = CVVCharacter(value: digits[index])
                    characters[i] = newCharacter
                    scheduleMasking(for: newCharacter.id)
                }
            }
        }
    }

    // MARK: - Private Methods

    private func scheduleMasking(for characterID: UUID) {
        Task {
            try? await Task.sleep(for: .seconds(1))
            guard let index = characters.firstIndex(where: { $0.id == characterID }) else { return }
            withAnimation(.easeInOut(duration: 0.3)) {
                characters[index].isMasked = true
            }
        }
    }
}
