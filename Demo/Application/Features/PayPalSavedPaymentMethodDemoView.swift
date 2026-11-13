import SwiftUI
import BraintreeCore
import BraintreePayPal
import BraintreePayPalSavedPaymentMethod

struct PayPalSavedPaymentMethodDemoView: View {

    let authorization: String
    let onProgress: (String?) -> Void
    let onComplete: (BTPaymentMethodNonce?) -> Void

    @State private var amount = "20.00"
    @State private var isAppSwitchEnabled = true
    @State private var userAction: BTPayPalRequestUserAction = .payNow
    @State private var isStyleEditorPresented = false
    @State private var styleConfig = PayPalSavedPaymentMethodStyleConfig()
    @State private var payPalClient: BTPayPalClient?
    @State private var isVaulting = false

    // The Demo merchant's PayPal account is French, so PayPal returns no Pay Later message for USD.
    private let currencyCode = "EUR"
    private let fallbackURLScheme = "com.braintreepayments.Demo.payments"

    private var isSandbox: Bool {
        BraintreeDemoSettings.currentEnvironment == .sandbox
    }

    // swiftlint:disable:next force_unwrapping
    private let universalLink = URL(string: "https://mobile-sdk-demo-site-838cead5d3ab.herokuapp.com/braintree-payments")!

    init(
        authorization: String,
        onProgress: @escaping (String?) -> Void = { _ in },
        onComplete: @escaping (BTPaymentMethodNonce?) -> Void = { _ in }
    ) {
        self.authorization = authorization
        self.onProgress = onProgress
        self.onComplete = onComplete
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                vaultSetup
                Divider()
                configuration
                Divider()
                savedPaymentMethod
            }
            .padding(.horizontal)
        }
        .sheet(isPresented: $isStyleEditorPresented) {
            PayPalSavedPaymentMethodStyleEditor(config: $styleConfig)
        }
    }

    private var vaultSetup: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Payment Method Token")

            Button(isVaulting ? "Processing..." : "Vault PayPal Account") {
                vaultPayPalAccount()
            }
            .disabled(isVaulting || !isSandbox)

            // The Demo merchant is also used for production testing, where this would vault a real PayPal account.
            Text(isSandbox ? "Vaults a PayPal account and saves its token to Settings." : "Only available in Sandbox.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.top)
    }

    private var configuration: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 5) {
                Text("Amount")

                TextField("Amount", text: $amount)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)
            }

            SwiftUI.Toggle("PayPal App Switch", isOn: $isAppSwitchEnabled)

            HStack {
                Text("User Action")
                Spacer()
                Picker("User Action", selection: $userAction) {
                    Text("Continue").tag(BTPayPalRequestUserAction.none)
                    Text("Pay Now").tag(BTPayPalRequestUserAction.payNow)
                }
                .pickerStyle(.menu)
            }

            Button("Edit Style") {
                isStyleEditorPresented = true
            }
        }
    }

    private var savedPaymentMethod: some View {
        PayPalSavedPaymentMethodView(
            authorization: authorization,
            universalLink: universalLink,
            payPalCheckoutRequest: BTPayPalCheckoutRequest(
                amount: amount,
                enablePayPalAppSwitch: isAppSwitchEnabled,
                userAction: userAction,
                currencyCode: currencyCode
            ),
            savedPaymentMethodRequest: PayPalSavedPaymentMethodRequest(amount: amount, currencyCode: currencyCode),
            fallbackURLScheme: fallbackURLScheme,
            style: styleConfig.style
        ) { nonce, error in
            guard let nonce else {
                onProgress(error?.localizedDescription)
                return
            }

            onComplete(nonce)
        }
        // The component only fetches the credit message on appear, so turning it on needs a fresh instance.
        .id(styleConfig.showPayPalCreditMessaging)
    }

    private func vaultPayPalAccount() {
        isVaulting = true

        let client = BTPayPalClient(authorization: authorization, universalLink: universalLink, fallbackURLScheme: fallbackURLScheme)
        payPalClient = client

        client.tokenize(BTPayPalVaultRequest(enablePayPalAppSwitch: isAppSwitchEnabled)) { nonce, error in
            guard let nonce else {
                isVaulting = false
                onProgress(error?.localizedDescription)
                return
            }

            BraintreeDemoMerchantAPIClient.shared.vaultPaymentMethod(paymentMethodNonce: nonce.nonce) { paymentMethodToken, message in
                isVaulting = false

                guard let paymentMethodToken else {
                    onProgress(message)
                    return
                }

                UserDefaults.standard.set(paymentMethodToken, forKey: BraintreeDemoSettings.PaymentMethodTokenDefaultsKey)
                onProgress("Saved payment method token \(paymentMethodToken) to Settings. Tap refresh to load it.")
            }
        }
    }
}

#Preview {
    PayPalSavedPaymentMethodDemoView(authorization: "")
}
