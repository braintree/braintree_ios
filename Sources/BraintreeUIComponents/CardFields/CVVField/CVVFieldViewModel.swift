import SwiftUI

@MainActor
class CVVFieldViewModel: ObservableObject {

    @Published private(set) var value: String = ""
    @Published private(set) var validationState: ValidationResult = .valid
    @Published var isFocused: Bool = false {
        didSet {
            // Show validation errors only after the user leaves the field
            if !isFocused {
                validationState = validator.validate(rawValue)
            }
        }
    }

    var shouldAutoAdvance: Bool { validationState == .valid && !rawValue.isEmpty }

    var maxLength: Int { validator.expectedLength ?? 4 }

    // MARK: - Internal Properties

    /// Individual characters with their masking state — drives the custom display
    @Published private(set) var characters: [CVVCharacter] = []

    /// Raw digits only — no masking, used for tokenization
    @Published private(set) var rawValue: String = ""

    // MARK: - Private Properties

    private let validator: CVVFieldValidator

    init(validator: CVVFieldValidator = CVVFieldValidator()) {
        self.validator = validator
    }

    // MARK: - Internal Methods

    func updateValue(_ newValue: String) {
        let digits = String(newValue.filter { $0.isNumber }.prefix(4))
        rawValue = digits
        value = digits

        let result = validator.validate(digits)
        if result == .valid {
            validationState = .valid
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
