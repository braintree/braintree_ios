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
        
        let paymentType = "ideal"
        let amount = "1.01"
        let currencyCode = "EUR"
        let paymentTypeCountryCode = "NL"
        let merchantAccountID = "ideal_eur"

        let request = BTLocalPaymentRequest(
            paymentType: paymentType,
            amount: amount,
            currencyCode: currencyCode,
            paymentTypeCountryCode: paymentTypeCountryCode,
            merchantAccountID: merchantAccountID,
            address: postalAddress,
            email: "lingo-buyer@paypal.com",
            givenName: "Linh",
            surname: "Ngo",
            phone: "639847934"
        )

        request.localPaymentFlowDelegate = flowCoordinator

        NSLog(
            "[iDEAL] Starting request — paymentType: %@, merchantAccountID: %@, amount: %@, currency: %@, country: %@",
            paymentType,
            merchantAccountID,
            amount,
            currencyCode,
            paymentTypeCountryCode
        )

        do {
            let result = try await localPaymentClient.start(request)
            NSLog("[iDEAL] Local payment succeeded — nonce: %@", result.nonce)
            onComplete(BTPaymentMethodNonce(nonce: result.nonce))
        } catch {
            if error as? BTLocalPaymentError == .canceled("") {
                onProgress("Canceled 🎲")
            } else {
                logAndReportFailure(error)
            }
        }
    }

    private func logAndReportFailure(_ error: Error) {
        let nsError = error as NSError
        NSLog("iDEAL payment failed: %@ userInfo: %@", nsError, nsError.userInfo)

        let httpResponse = nsError.userInfo[BTCoreConstants.urlResponseKey] as? HTTPURLResponse
        let debugID = httpResponse?.value(forHTTPHeaderField: "Paypal-Debug-Id")

        let json = nsError.userInfo[BTCoreConstants.jsonResponseBodyKey] as? BTJSON
        let correlationID = json?["correlationId"].asString()

        if let debugID {
            NSLog("iDEAL PayPal-Debug-Id: %@", debugID)
        }
        if let correlationID {
            NSLog("iDEAL correlationId: %@", correlationID)
        }
        if let json {
            NSLog("iDEAL error response body: %@", json.asDictionary() ?? [:])
        } else {
            NSLog("iDEAL error response body: <unparsed or missing>")
        }

        let supportID = debugID ?? correlationID
        if let supportID {
            onProgress("Error: \(error.localizedDescription) (Debug ID: \(supportID))")
        } else {
            onProgress("Error: \(error.localizedDescription)")
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
        NSLog("[iDEAL] localPaymentStarted — paymentID: %@", paymentID)
        Task { @MainActor in
            self.paymentID = paymentID
        }
        start()
    }
}

#Preview {
    IdealView(client: BTLocalPaymentClient(authorization: "sandbox_d54x7ckf_hh4cpc39zq4rgjcg"))
}
