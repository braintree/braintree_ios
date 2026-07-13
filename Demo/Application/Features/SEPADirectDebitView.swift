import SwiftUI
import AuthenticationServices
import BraintreeCore
import BraintreeSEPADirectDebit

struct SEPADirectDebitView: View {

    let sepaDirectDebitClient: BTSEPADirectDebitClient
    let onProgress: (String?) -> Void
    let onComplete: (BTPaymentMethodNonce?) -> Void

    init(
        authorization: String,
        onProgress: @escaping (String?) -> Void = { _ in },
        onComplete: @escaping (BTPaymentMethodNonce?) -> Void = { _ in }
    ) {
        self.sepaDirectDebitClient = BTSEPADirectDebitClient(authorization: authorization)
        self.onProgress = onProgress
        self.onComplete = onComplete
    }


    var body: some View {
        VStack {
            Button {
                Task {
                    await requestTokenization()
                }
            } label: {
                Text("SEPA Direct Debit")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
            .controlSize(.large)
            .padding(.horizontal)
        }
    }

    private func requestTokenization() async {
        onProgress("Tapped SEPA Direct Debit")

        let billingAddress = BTPostalAddress(
            streetAddress: "Kantstraße 70",
            extendedAddress: "#170",
            locality: "Freistaat Sachsen",
            countryCodeAlpha2: "FR",
            postalCode: "09456",
            region: "Annaberg-buchholz"
        )

        let sepaDirectDebitRequest = BTSEPADirectDebitRequest(
            accountHolderName: "John Doe",
            iban: BTSEPADirectDebitTestHelper.generateValidSandboxIBAN(),
            customerID: generateRandomCustomerID(),
            billingAddress: billingAddress,
            mandateType: .oneOff,
            merchantAccountID: "EUR-sepa-direct-debit"
        )

        do {
            let sepaDirectDebitNonce = try await sepaDirectDebitClient.tokenize(sepaDirectDebitRequest)
            onComplete(sepaDirectDebitNonce)
        } catch {
            if error as? BTSEPADirectDebitError == .webFlowCanceled {
                onProgress("Canceled")
            } else {
                onProgress(error.localizedDescription)
            }
        }
    }

    private func generateRandomCustomerID() -> String {
        String(UUID().uuidString.replacingOccurrences(of: "-", with: "").prefix(20))
    }
}

#Preview {
    SEPADirectDebitView(authorization: "")
}
