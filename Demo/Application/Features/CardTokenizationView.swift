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
    @State private var postalCode = ""
    @State private var phoneNumber = ""
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
            CardFormView(
                cardNumber: $cardNumber,
                expirationDate: $expirationDate,
                cvv: $cvv,
                postalCode: $postalCode,
                phoneNumber: $phoneNumber,
                hidePostalCodeField: true,
                hidePhoneNumberField: true,
                fieldsEnabled: fieldsEnabled
            )
            
            Button {
                Task { await tappedSubmit() }
            } label: {
                Text("Submit")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .background(fieldsEnabled ? Color.black : Color.black.opacity(0.3))
            .clipShape(Capsule())
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
    
    private func makeCard() -> BTCard? {
        guard !cardNumber.isEmpty, !cvv.isEmpty else { return nil }
        
        let parts = expirationDate.split(separator: "/")
        guard parts.count == 2, let month = parts.first,let year = parts.last,
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
