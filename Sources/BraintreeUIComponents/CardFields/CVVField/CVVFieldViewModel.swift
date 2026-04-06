import SwiftUI

class CVVFieldViewModel: CardFieldsViewModelProtocol {

    // MARK: - CardFieldViewModelProtocol

    @Published private(set) var value: String = ""
    @Published private(set) var validationState: ValidationResult = .valid
    @Published var isFocused: Bool = false

    // TODO: Implement auto-advance logic with state changes
    var shouldAutoAdvance: Bool { false }

    // MARK: - Internal Properties

    /// Individual characters with their masking state — drives the custom display
    @Published private(set) var characters: [CVVCharacter] = []

    /// Raw digits only — no masking, used for tokenization
    private(set) var rawValue: String = ""

    // MARK: - CardFieldViewModelProtocol

    func updateValue(_ newValue: String) {
        let digits = String(newValue.filter { $0.isNumber }.prefix(4))
        rawValue = digits
        value = digits

        let oldCount = characters.count
        let newCount = digits.count

        if newCount > oldCount {
            // fade transition animation for masking new characters
            for i in oldCount..<newCount {
                let index = digits.index(digits.startIndex, offsetBy: i)
                characters.append(CVVCharacter(value: digits[index]))

                let charIndex = i
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                    guard let self,
                          charIndex < self.characters.count else { return }
                    withAnimation(.easeInOut(duration: 0.3)) {
                        self.characters[charIndex].isMasked = true
                    }
                }
            }
        } else if newCount < oldCount {
            characters = Array(characters.prefix(newCount))
        }
    }
}
