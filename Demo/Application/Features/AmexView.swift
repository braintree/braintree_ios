import SwiftUI
import BraintreeAmericanExpress
import BraintreeCard
import BraintreeCore

private enum TestCardNumber: String {
    case valid = "371260714673002"
    case insufficientPoints = "371544868764018"
    case ineligible = "378267515471109"
}

struct AmexView: View {

    let amexClient: BTAmericanExpressClient
    let cardClient: BTCardClient
    let onProgress: (String?) -> Void
    let onComplete: (BTPaymentMethodNonce?) -> Void

    @State private var loadingCardNumber: TestCardNumber?

    init(
        amexClient: BTAmericanExpressClient,
        cardClient: BTCardClient,
        onProgress: @escaping (String?) -> Void = { _ in },
        onComplete: @escaping (BTPaymentMethodNonce?) -> Void = { _ in }
    ) {
        self.amexClient = amexClient
        self.cardClient = cardClient
        self.onProgress = onProgress
        self.onComplete = onComplete
    }

    var body: some View {
        VStack(spacing: 10) {
            Button("Valid Card") {
                Task { await getRewards(for: .valid) }
            }
            .opacity(loadingCardNumber == .valid ? 0.5 : 1.0)
            .allowsHitTesting(loadingCardNumber == nil)

            Button("Insufficient Points Card") {
                Task { await getRewards(for: .insufficientPoints) }
            }
            .opacity(loadingCardNumber == .insufficientPoints ? 0.5 : 1.0)
            .allowsHitTesting(loadingCardNumber == nil)

            Button("Ineligible Card") {
                Task { await getRewards(for: .ineligible) }
            }
            .foregroundColor(.red)
            .opacity(loadingCardNumber == .ineligible ? 0.5 : 1.0)
            .allowsHitTesting(loadingCardNumber == nil)
        }
        .padding(.horizontal)
    }

    private func getRewards(for cardNumber: TestCardNumber) async {
        guard loadingCardNumber == nil else { return }
        loadingCardNumber = cardNumber
        defer { loadingCardNumber = nil }

        let card = BTCard(
            number: cardNumber.rawValue,
            expirationMonth: "12",
            expirationYear: CardHelpers.generateFuture(.year),
            cvv: "1234"
        )

        onProgress("Tokenizing Card")

        do {
            let tokenizedCard = try await cardClient.tokenize(card)
            onProgress("Amex - getting rewards balance")

            let rewardsBalance = try await amexClient.getRewardsBalance(
                forNonce: tokenizedCard.nonce,
                currencyISOCode: "USD"
            )

            if let errorMessage = rewardsBalance.errorMessage {
                onProgress("Error: \(errorMessage)")
                return
            }

            if
                let rewardsAmount = rewardsBalance.rewardsAmount,
                let rewardsUnit = rewardsBalance.rewardsUnit,
                let currencyAmount = rewardsBalance.currencyAmount,
                let currencyIsoCode = rewardsBalance.currencyIsoCode {
                onProgress("\(rewardsAmount) \(rewardsUnit), \(currencyAmount) \(currencyIsoCode)")
            } else {
                onProgress("Unexpected response from rewards balance")
            }

            onComplete(tokenizedCard)
        } catch {
            onProgress(error.localizedDescription)
        }
    }
}

#Preview {
    AmexView(
        amexClient: BTAmericanExpressClient(authorization: "sandbox_tokenization_key"),
        cardClient: BTCardClient(authorization: "sandbox_tokenization_key")
    )
}
