import SwiftUI
import BraintreeAmericanExpress
import BraintreeCard
import BraintreeCore

struct AmexView: View {
    
    let amexClient: BTAmericanExpressClient
    let cardClient: BTCardClient
    let onProgress: (String?) -> Void
    let onComplete: (BTPaymentMethodNonce?) -> Void
    
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
                Task { await getRewards(for: "371260714673002") }
            }
            Button("Insufficient Points Card") {
                Task { await getRewards(for: "371544868764018") }
            }
            Button("Ineligible card") {
                Task { await getRewards(for: "378267515471109") }
            }
        }
        .padding(.horizontal)
    }
    
    private func getRewards(for cardNumber: String) async {
        let card = BTCard(
            number: cardNumber,
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
