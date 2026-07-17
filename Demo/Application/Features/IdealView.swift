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
                    await startPaymentWithBaknk()
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
    
    private func startPaymentWithBaknk() async {
        onProgress("Loading iDEAL Merchant Account...")
        
        let postalAddress = BTPostalAddress(
            streetAddress: "1 Infinite Loop",
            extendedAddress: "Suite 1000",
            locality: "Cupertino",
            countryCodeAlpha2: "US",
            postalCode: "95014",
            region: "CA"
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

@MainActor
final class LocalPaymentFlowCoordinator: NSObject, ObservableObject, BTLocalPaymentRequestDelegate {
    
    @Published var paymentID: String?
    
    func localPaymentStarted(
        _ request: BTLocalPaymentRequest,
        paymentID: String,
        start: @escaping () -> Void
    ) {
        self.paymentID = paymentID
        start()
    }
}

#Preview {
    IdealView(client: BTLocalPaymentClient(authorization: ""))
}
