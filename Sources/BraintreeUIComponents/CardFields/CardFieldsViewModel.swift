import BraintreeCard
import BraintreeCore
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

    var apiClient: BTAPIClient
    private let cardClient: BTCardClient
    private let card: BTCard
    private let completion: (BTCardNonce?, Error?) -> Void
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initializer

    init(
        authorization: String,
        card: BTCard,
        completion: @escaping (BTCardNonce?, Error?) -> Void
    ) {
        self.apiClient = BTAPIClient(authorization: authorization)
        self.cardClient = BTCardClient(authorization: authorization)
        self.card = card
        self.completion = completion

        let cardValid = Publishers.CombineLatest(cardNumberViewModel.$validationState, cardNumberViewModel.$value)
            .map { state, value in state == .valid && !value.isEmpty }
        let expValid = Publishers.CombineLatest(expirationDateViewModel.$validationState, expirationDateViewModel.$value)
            .map { state, value in state == .valid && !value.isEmpty }
        let cvvValid = Publishers.CombineLatest(cvvViewModel.$validationState, cvvViewModel.$value)
            .map { state, value in state == .valid && !value.isEmpty }

        Publishers.CombineLatest3(cardValid, expValid, cvvValid)
            .map { $0 && $1 && $2 }
            .assign(to: &$isFormValid)
    }

    // MARK: - Internal Methods

    func sendAnalyticsEvent(_ event: String) {
        apiClient.sendAnalyticsEvent(event)
    }

    func tokenize() {
        guard isFormValid else { return }

        sendAnalyticsEvent(UIComponentsAnalytics.cardFieldsSelected)

        let card = card.merging(
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
