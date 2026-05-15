import Foundation

@MainActor
final class CardFieldsViewModel: ObservableObject {

    // MARK: - Internal Properties

    let cardNumberViewModel = CardNumberFieldViewModel()
    let expirationDateViewModel = ExpirationDateFieldViewModel()
    // TODO: Pass card brand-derived CVV length to cvvViewModel once brand detection
    // is wired up to this container (requires CVVFieldViewModel to accept a mutable expectedLength)
    let cvvViewModel = CVVFieldViewModel()
}
