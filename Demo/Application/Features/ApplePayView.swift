import SwiftUI
import BraintreeApplePay
import BraintreeCore
import PassKit

struct ApplePayView: View {

    let applePayClient: BTApplePayClient
    let onProgress: (String?) -> Void
    let onComplete: (BTPaymentMethodNonce?) -> Void
    let onPaymentRequestCreated: (PKPaymentRequest) -> Void

    @State private var isApplePaySupported = false

    // swiftlint:disable:next force_unwrapping
    private let managementURL = URL(string: "https://www.merchant.com/update-payment")!

    init(
        client: BTApplePayClient,
        onProgress: @escaping (String?) -> Void = { _ in },
        onComplete: @escaping (BTPaymentMethodNonce?) -> Void = { _ in },
        onPaymentRequestCreated: @escaping (PKPaymentRequest) -> Void = { _ in }
    ) {
        self.applePayClient = client
        self.onProgress = onProgress
        self.onComplete = onComplete
        self.onPaymentRequestCreated = onPaymentRequestCreated
    }

    var body: some View {
        VStack {
            if isApplePaySupported {
                ApplePayButtonRepresentable {
                    Task {
                        await requestApplePayPayment()
                    }
                }
                .frame(height: 50)
                .padding(.horizontal)
            }
        }
        .onAppear {
            Task {
                let isSupported = await applePayClient.isApplePaySupported()
                if !isSupported {
                    onProgress("canMakePayments returned false, hiding Apple Pay button")
                }
                isApplePaySupported = isSupported
            }
        }
    }

    private func requestApplePayPayment() async {
        onProgress("Constructing PKPaymentRequest")

        do {
            let request = try await applePayClient.makePaymentRequest()
            let paymentRequest = constructPaymentRequest(with: request)

            // NEXT_MAJOR_VERSION: remove the #available check when minimum target moved to iOS 16 or higher
            if #available(iOS 16, *) {
                paymentRequest.recurringPaymentRequest = recurringPaymentRequest()
            }

            onProgress("Presenting Apple Pay Sheet")
            onPaymentRequestCreated(paymentRequest)
        } catch {
            onProgress(error.localizedDescription)
        }
    }

    @available(iOS 16, *)
    private func recurringPaymentRequest() -> PKRecurringPaymentRequest {
        PKRecurringPaymentRequest(
            paymentDescription: "Payment description.",
            regularBilling: PKRecurringPaymentSummaryItem(label: "Payment label", amount: 10.99),
            managementURL: managementURL
        )
    }

    private func constructPaymentRequest(with paymentRequest: PKPaymentRequest) -> PKPaymentRequest {
        paymentRequest.requiredBillingContactFields = [PKContactField.name]

        let shippingMethod1 = PKShippingMethod(label: "✈️ Fast Shipping", amount: 4.99)
        shippingMethod1.detail = "Fast but expensive"
        shippingMethod1.identifier = "fast"

        let shippingMethod2 = PKShippingMethod(label: "🐢 Slow Shipping", amount: 0.00)
        shippingMethod2.detail = "Slow but free"
        shippingMethod2.identifier = "slow"

        let shippingMethod3 = PKShippingMethod(label: "💣 Unavailable Shipping", amount: NSDecimalNumber(string: "0xdeadbeef"))
        shippingMethod3.detail = "It will make Apple Pay fail"
        shippingMethod3.identifier = "fail"

        paymentRequest.shippingMethods = [shippingMethod1, shippingMethod2, shippingMethod3]
        paymentRequest.requiredShippingContactFields = [PKContactField.name, PKContactField.phoneNumber, PKContactField.emailAddress]

        paymentRequest.paymentSummaryItems = [
            PKPaymentSummaryItem(label: "SOME ITEM", amount: 10),
            PKPaymentSummaryItem(label: "SHIPPING", amount: shippingMethod1.amount),
            PKPaymentSummaryItem(label: "BRAINTREE", amount: 14.99)
        ]

        paymentRequest.merchantCapabilities = .capability3DS
        return paymentRequest
    }
}

#Preview {
    ApplePayView(client: BTApplePayClient(authorization: ""))
}

/// UIKit-backed Apple Pay button, used so we can set a square `cornerRadius` (not exposed by the SwiftUI `PayWithApplePayButton`)
private struct ApplePayButtonRepresentable: UIViewRepresentable {

    let action: () -> Void

    func makeUIView(context: Context) -> PKPaymentButton {
        let button = PKPaymentButton(paymentButtonType: .plain, paymentButtonStyle: .automatic)
        button.cornerRadius = 0
        button.addTarget(context.coordinator, action: #selector(Coordinator.didTap), for: .touchUpInside)
        return button
    }

    func updateUIView(_ uiView: PKPaymentButton, context: Context) { }

    func makeCoordinator() -> Coordinator {
        Coordinator(action: action)
    }

    final class Coordinator: NSObject {

        private let action: () -> Void

        init(action: @escaping () -> Void) {
            self.action = action
        }

        @objc func didTap() {
            action()
        }
    }
}
