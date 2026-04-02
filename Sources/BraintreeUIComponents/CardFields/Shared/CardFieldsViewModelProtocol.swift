import Foundation

protocol CardFieldsViewModelProtocol: ObservableObject {
    
    var value: String { get }
    var validationState: ValidationResult { get }
    var isFocused: Bool { get set }
    var shouldAutoAdvance: Bool { get }
    
    func updateValue(_ newValue: String)
}
