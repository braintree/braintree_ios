import UIKit
import SwiftUI
import BraintreeCard
import BraintreeCore
import BraintreeUIComponents
import BraintreeVenmo
import BraintreePayPal

class UIComponentsViewController: PaymentButtonBaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "UI Components"

        let demoView = UIComponentsDemoView(
            authorization: authorization,
            onProgress: { [weak self] message in self?.progressBlock(message) },
            onComplete: { [weak self] nonce in self?.completionBlock(nonce) }
        )

        let hostingController = UIHostingController(rootView: demoView)
        addChild(hostingController)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hostingController.view)

        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        hostingController.didMove(toParent: self)
    }
}

private struct UIComponentsDemoView: View {

    let authorization: String
    let onProgress: (String?) -> Void
    let onComplete: (BTPaymentMethodNonce?) -> Void

    @State private var isFormValid = false
    @State private var submit: (() -> Void)?
    @State private var venmoColorIndex: Int = 0
    @State private var payPalColorIndex: Int = 0

    private var selectedVenmoColor: VenmoButtonColor {
        switch venmoColorIndex {
        case 1: return .black
        case 2: return .white
        default: return .blue
        }
    }

    private var selectedPayPalColor: PayPalButtonColor {
        switch payPalColorIndex {
        case 1: return .black
        case 2: return .white
        default: return .blue
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // Color toggles
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Venmo")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Picker("Venmo Color", selection: $venmoColorIndex) {
                            Text("Blue").tag(0)
                            Text("Black").tag(1)
                            Text("White").tag(2)
                        }
                        .pickerStyle(.segmented)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("PayPal")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Picker("PayPal Color", selection: $payPalColorIndex) {
                            Text("Blue").tag(0)
                            Text("Black").tag(1)
                            Text("White").tag(2)
                        }
                        .pickerStyle(.segmented)
                    }
                }

                // Card fields
                CardFields(
                    authorization: authorization,
                    card: BTCard()
                ) { nonce, error in
                    if let error {
                        onProgress(error.localizedDescription)
                    } else if let nonce {
                        onComplete(nonce)
                    }
                }
                .onValidityChange { valid, tokenize in
                    isFormValid = valid
                    submit = tokenize
                }

                // Pay button for card fields
                Button("Pay") {
                    onProgress("Tokenizing card...")
                    submit?()
                }
                .disabled(!isFormValid)
                .frame(maxWidth: .infinity, alignment: .center)

                // Venmo + PayPal buttons side by side
                GeometryReader { geo in
                    let buttonWidth = (geo.size.width - 12) / 2
                    HStack(spacing: 12) {
                        VenmoButton(
                            authorization: authorization,
                            // swiftlint:disable:next force_unwrapping
                            universalLink: URL(string: "https://mobile-sdk-demo-site-838cead5d3ab.herokuapp.com/braintree-payments")!,
                            request: BTVenmoRequest(paymentMethodUsage: .singleUse),
                            color: selectedVenmoColor,
                            width: buttonWidth
                        ) { nonce, error in
                            DispatchQueue.main.async {
                                if let nonce {
                                    onProgress("Got a nonce 💎!")
                                    onComplete(nonce)
                                } else if let error {
                                    onProgress((error as? BTVenmoError) == .canceled ? "Canceled 🔰" : error.localizedDescription)
                                }
                            }
                        }

                        PayPalButton(
                            authorization: authorization,
                            // swiftlint:disable:next force_unwrapping
                            universalLink: URL(string: "https://mobile-sdk-demo-site-838cead5d3ab.herokuapp.com/braintree-payments")!,
                            request: BTPayPalCheckoutRequest(
                                amount: "10.00",
                                enablePayPalAppSwitch: true,
                                userAuthenticationEmail: nil,
                                userAction: .payNow
                            ),
                            color: selectedPayPalColor,
                            width: buttonWidth
                        ) { nonce, error in
                            DispatchQueue.main.async {
                                if let nonce {
                                    onProgress("Got a nonce 💎!")
                                    onComplete(nonce)
                                } else if let error {
                                    onProgress((error as? BTPayPalError) == .canceled ? "Canceled 🔰" : error.localizedDescription)
                                }
                            }
                        }
                    }
                }
                .frame(height: 48)
            }
            .padding()
        }
    }
}
