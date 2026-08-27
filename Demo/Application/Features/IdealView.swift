import SwiftUI
import BraintreeCore
import BraintreeLocalPayment

struct IdealView: View {
    
    let localPaymentClient: BTLocalPaymentClient
    let onProgress: (String?) -> Void
    let onComplete: (BTPaymentMethodNonce?) -> Void
    
    @StateObject private var flowCoordinator = LocalPaymentFlowCoordinator()
    
    init(
        client: BTLocalPaymentClient,
        onProgress: @escaping (String?) -> Void = { _ in },
        onComplete: @escaping (BTPaymentMethodNonce?) -> Void = { _ in }
    ) {
        self.localPaymentClient = client
        self.onProgress = onProgress
        self.onComplete = onComplete
    }
    
    var body: some View {
        VStack(spacing: 5) {
            Button {
                flowCoordinator.paymentID = nil
                Task {
                    await startPaymentWithBank()
                }
            } label: {
                Text("Pay with iDEAL")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
            .controlSize(.large)
            .padding(.horizontal)
            
            if let paymentID = flowCoordinator.paymentID {
                Text("Local Payment ID: \(paymentID)")
                    .font(.footnote)
            }
        }
    }

    private func startPaymentWithBank() async {
        onProgress("Loading iDEAL Merchant Account...")
        
        let postalAddress = BTPostalAddress(
            streetAddress: "836486 of 22321 Park Lake",
            locality: "Den Haag",
            countryCodeAlpha2: "NL",
            postalCode: "2585 GJ"
        )
        
        let request = BTLocalPaymentRequest(
            paymentType: "ideal",
            amount: "1.01",
            currencyCode: "EUR",
            paymentTypeCountryCode: "NL",
            merchantAccountID: "altpay_eur",
            address: postalAddress,
            email: "lingo-buyer@paypal.com",
            givenName: "Linh",
            surname: "Ngo",
            phone: "639847934"
        )
        
        request.localPaymentFlowDelegate = flowCoordinator
        
        do {
            let result = try await localPaymentClient.start(request)
            onComplete(BTPaymentMethodNonce(nonce: result.nonce))
        } catch {
            if error as? BTLocalPaymentError == .canceled("") {
                onProgress("Canceled 🎲")
            } else {
                onProgress("Error: \(error.localizedDescription)")
            }
        }
    }
}


final class LocalPaymentFlowCoordinator: NSObject, ObservableObject, BTLocalPaymentRequestDelegate {
    
    @Published var paymentID: String?

    nonisolated func localPaymentStarted(
        _ request: BTLocalPaymentRequest,
        paymentID: String,
        start: @escaping () -> Void
    ) {
        Task { @MainActor in
            self.paymentID = paymentID
        }
        start()
    }
}

#Preview {
    IdealView(client: BTLocalPaymentClient(authorization: "sandbox_d54x7ckf_hh4cpc39zq4rgjcg"))
}
