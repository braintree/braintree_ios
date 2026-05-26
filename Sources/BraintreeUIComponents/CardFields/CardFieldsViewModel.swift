import Combine
import Foundation

@MainActor
final class CardFieldsViewModel: ObservableObject {

    // MARK: - Internal Properties

    let cardNumberViewModel = CardNumberFieldViewModel()
    let expirationDateViewModel = ExpirationDateFieldViewModel()
    let cvvViewModel = CVVFieldViewModel()

    @Published private(set) var isFormValid: Bool = false

    // MARK: - Private Properties

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initializer

    init() {
        let cardValid = cardNumberViewModel.$validationState.map { $0 == .valid }
        let expValid = expirationDateViewModel.$validationState.map { $0 == .valid }
        let cvvValid = cvvViewModel.$validationState.map { $0 == .valid }

        Publishers.CombineLatest3(cardValid, expValid, cvvValid)
            .map { $0 && $1 && $2 }
            .assign(to: &$isFormValid)
    }
}
