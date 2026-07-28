import SwiftUI
import BraintreeCore
import BraintreeCard

struct CardTokenizationView: View {
    
    let cardClient: BTCardClient
    let onProgress: (String?) -> Void
    let onComplete: (BTPaymentMethodNonce?) -> Void
    
    @State private var cardNumber = ""
    @State private var expirationDate = ""
    @State private var cvv = ""
    @State private var fieldsEnabled = true
    
    init(
        client: BTCardClient,
        onProgress: @escaping (String?) -> Void = { _ in },
        onComplete: @escaping (BTPaymentMethodNonce?) -> Void = { _ in }
    ) {
        self.cardClient = client
        self.onProgress = onProgress
        self.onComplete = onComplete
    }
    
    var body: some View {
        VStack(spacing: 10) {
            TextField("Card Number", text: $cardNumber)
                .keyboardType(.numberPad)
                .textFieldStyle(.roundedBorder)
                .disabled(!fieldsEnabled)
            
            TextField("MM/YYYY", text: $expirationDate)
                .keyboardType(.numberPad)
                .textFieldStyle(.roundedBorder)
                .disabled(!fieldsEnabled)
            
            TextField("CVV", text: $cvv)
                .keyboardType(.numberPad)
                .textFieldStyle(.roundedBorder)
                .disabled(!fieldsEnabled)
            
            Button {
                Task {
                    await tappedSubmit()
                }
            } label: {
                Text("Submit")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
            .controlSize(.large)
            .disabled(!fieldsEnabled)
            
            Button {
                tappedAutoFill()
            } label: {
                Text("Autofill")
            }
            .disabled(!fieldsEnabled)
        }
        .padding(.horizontal)
    }
    
    private func tappedAutoFill() {
        cardNumber = "4111111111111111"
        cvv = "123"
        expirationDate = CardHelpers.generateFuture(.date)
    }
    
    private func tappedSubmit() async {
        onProgress("Tokenizing Card Details")
        
        guard let card = makeCard() else {
            onProgress("Fill in all the card fields.")
            return
        }
        
        fieldsEnabled = false
        
        cardClient.tokenize(card) { nonce, error in
            fieldsEnabled = true
            
            guard let nonce else {
                onProgress(error?.localizedDescription)
                return
            }
            
            onComplete(nonce)
        }
    }
    
    // Note: CardHelpers.newCard(from:) took a `BTCardFormView` which no longer exists in this SwiftUI version.
    // This builds the BTCard directly from local state instead - adjust the expiration-date split below if
    // CardHelpers used a different MM/YYYY format.
    
    private func makeCard() -> BTCard? {
        guard !cardNumber.isEmpty, !cvv.isEmpty else { return nil }
        
        let parts = expirationDate.split(separator: "/")
        guard parts.count == 2,
            let month = parts.first,
            let year = parts.last,
            !month.isEmpty, !year.isEmpty else {
            return nil
        }
        
        return BTCard(
            number: cardNumber,
            expirationMonth: String(month),
            expirationYear: String(year),
            cvv: cvv
        )
    }
}

#Preview {
    CardTokenizationView(client: BTCardClient(authorization: "sandbox_tokenization_key"))
}
