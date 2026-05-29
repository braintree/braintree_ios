import BraintreeCard
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

    private let cardClient: BTCardClient
    private let cardDetails: BTCard
    private let completion: (BTCardNonce?, Error?) -> Void
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initializer

    init(authorization: String, cardDetails: BTCard, completion: @escaping (BTCardNonce?, Error?) -> Void) {
        self.cardClient = BTCardClient(authorization: authorization)
        self.cardDetails = cardDetails
        self.completion = completion

        let cardValid = cardNumberViewModel.$validationState.map { $0 == .valid }
        let expValid = expirationDateViewModel.$validationState.map { $0 == .valid }
        let cvvValid = cvvViewModel.$validationState.map { $0 == .valid }

        Publishers.CombineLatest3(cardValid, expValid, cvvValid)
            .map { $0 && $1 && $2 }
            .assign(to: &$isFormValid)
    }

    // MARK: - Internal Methods

    func tokenize() {
        guard isFormValid else { return }

        let card = cardDetails.merging(
            cardNumber: cardNumberViewModel.value,
            expirationMonth: expirationDateViewModel.expirationMonth,
            expirationYear: expirationDateViewModel.expirationYear,
            cvv: cvvViewModel.value
        )

        Task {
            do {
                let nonce = try await cardClient.tokenize(card)
                completion(nonce, nil)
            } catch {
                completion(nil, error)
            }
        }
    }
}
