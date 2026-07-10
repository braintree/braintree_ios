//
//  SEPADirectDebitView.swift
//  Demo
//
//  Created by Brent Busby on 7/10/26.
//  Copyright © 2026 braintree. All rights reserved.
//

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
            Button(action: requestTokenization) {
                Text("SEPA Direct Debit")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
            .controlSize(.large)
            .padding(.horizontal)
        }
    }

    private func requestTokenization() {
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

        sepaDirectDebitClient.tokenize(sepaDirectDebitRequest) { sepaDirectDebitNonce, error in
            if let sepaDirectDebitNonce {
                onComplete(sepaDirectDebitNonce)
            } else if let error {
                if error as? BTSEPADirectDebitError == .webFlowCanceled {
                    onProgress("Canceled")
                } else {
                    onProgress(error.localizedDescription)
                }
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
