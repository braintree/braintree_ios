import SwiftUI
import BraintreeCore
import BraintreePayPal
import BraintreePayPalSavedPaymentMethod

struct PayPalSavedPaymentMethodDemoView: View {

    let authorization: String
    let onProgress: (String?) -> Void
    let onComplete: (BTPaymentMethodNonce?) -> Void

    @State private var amount = "10.00"
    @State private var amountInput = "10.00"
    @State private var isAppSwitchEnabled = true
    @State private var isStyleEditorPresented = false
    @State private var styleConfig = PayPalSavedPaymentMethodStyleConfig()

    @FocusState private var isAmountFocused: Bool

    private let currencyCode = "USD"

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

    private var configuration: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 5) {
                Text("Amount")

                TextField("Amount", text: $amountInput)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)
                    .focused($isAmountFocused)
                    .onChange(of: isAmountFocused) { isFocused in
                        if !isFocused {
                            amount = amountInput
                        }
                    }
            }

            SwiftUI.Toggle("PayPal App Switch", isOn: $isAppSwitchEnabled)

            Button("Edit Style") {
                isStyleEditorPresented = true
            }
        }
        .padding(.top)
    }

    private var savedPaymentMethod: some View {
        PayPalSavedPaymentMethodView(
            authorization: authorization,
            universalLink: universalLink,
            payPalCheckoutRequest: BTPayPalCheckoutRequest(
                amount: amount,
                enablePayPalAppSwitch: isAppSwitchEnabled,
                currencyCode: currencyCode
            ),
            request: PayPalSavedPaymentMethodRequest(amount: amount, currencyCode: currencyCode),
            fallbackURLScheme: "com.braintreepayments.Demo.payments",
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
}

#Preview {
    PayPalSavedPaymentMethodDemoView(authorization: "")
}
