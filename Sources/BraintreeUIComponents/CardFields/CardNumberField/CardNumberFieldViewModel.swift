import Foundation

@MainActor
class CardNumberFieldViewModel: ObservableObject {
    
    @Published private(set) var value: String = ""
    @Published private(set) var validationState: ValidationResult = .valid
    @Published private(set) var cardBrand: CardBrand = .unknown
    @Published var isFocused: Bool = false

    // TODO: Implement auto-advance logic w/ state change
    var shouldAutoAdvance: Bool { false }

    // TODO: Implement validation and formatting
    func updateValue(_ newValue: String) {
        value = newValue
        
        // call updateCardBrand based off of value changes from validator
    }
    
    private func updateCardBrand(_ brand: CardBrand) {
        self.cardBrand = brand
    }
}
