import UIKit
import SwiftUI
import BraintreeUIComponents
import BraintreeVenmo
import BraintreePayPal

class PaymentButtonViewController: PaymentButtonBaseViewController {

    private var hostingVenmoController: UIHostingController<VenmoButton>?
    private var hostingPayPalController: UIHostingController<PayPalButton>?
    private var selectedVenmoColor: VenmoButtonColor = .blue
    private var selectedPayPalColor: PayPalButtonColor = .blue

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Payment Buttons"
        view.backgroundColor = .systemBackground

        setupVenmoButton()
        setupPayPalButton()
    }

    private func colorChange(for buttonType: PaymentButtonType, selectedIndex: Int) {
        switch buttonType {
        case .venmo:
            switch selectedIndex {
            case 0: selectedVenmoColor = .blue
            case 1: selectedVenmoColor = .black
            case 2: selectedVenmoColor = .white
            default: selectedVenmoColor = .blue
            }
            setupVenmoButton()
        case .paypal:
            switch selectedIndex {
            case 0: selectedPayPalColor = .blue
            case 1: selectedPayPalColor = .black
            case 2: selectedPayPalColor = .white
            default: selectedPayPalColor = .blue
            }
            setupPayPalButton()
        }
    }

    private func setupPaymentButtonSection<Content: View>(
        for buttonType: PaymentButtonType,
        colorSelectorOffset: CGFloat,
        buttonView: Content
    ) {
        // Remove existing hosting controller for the button type
        switch buttonType {
        case .venmo:
            if let existing = hostingVenmoController {
                existing.willMove(toParent: nil)
                existing.view.removeFromSuperview()
                existing.removeFromParent()
            }
        case .paypal:
            if let existing = hostingPayPalController {
                existing.willMove(toParent: nil)
                existing.view.removeFromSuperview()
                existing.removeFromParent()
            }
        }

        // Setup color selector
        let segmentedControl = UISegmentedControl(items: ["Blue", "Black", "White"])
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.addAction(
            UIAction { [weak self] action in
                guard let self = self, let sender = action.sender as? UISegmentedControl else { return }
                self.colorChange(for: buttonType, selectedIndex: sender.selectedSegmentIndex)
            }, for: .valueChanged)
        view.addSubview(segmentedControl)
        NSLayoutConstraint.activate([
            segmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            segmentedControl.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: colorSelectorOffset),
            segmentedControl.widthAnchor.constraint(equalToConstant: 250)
        ])

        // Setup hosting controller for the button
        let hostingController = UIHostingController(rootView: buttonView)
        switch buttonType {
        case .venmo:
            hostingVenmoController = hostingController as? UIHostingController<VenmoButton>
        case .paypal:
            hostingPayPalController = hostingController as? UIHostingController<PayPalButton>
        }
        addChild(hostingController)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController.view.backgroundColor = .clear
        view.addSubview(hostingController.view)
        NSLayoutConstraint.activate([
            hostingController.view.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            hostingController.view.centerYAnchor.constraint(equalTo: segmentedControl.centerYAnchor, constant: 50),
            hostingController.view.widthAnchor.constraint(equalToConstant: 300),
            hostingController.view.heightAnchor.constraint(equalToConstant: 45)
        ])
        hostingController.didMove(toParent: self)
    }

    // MARK: - Setup Venmo Payment Button

    private func setupVenmoButton() {
        let venmoRequest = BTVenmoRequest(paymentMethodUsage: .singleUse)

        let venmoButtonView = VenmoButton(
            authorization: authorization,
            // swiftlint:disable:next force_unwrapping
            universalLink: URL(string: "https://mobile-sdk-demo-site-838cead5d3ab.herokuapp.com/braintree-payments")!,
            request: venmoRequest,
            color: selectedVenmoColor,
            width: 300,
            completion: venmoCompletionHandler
        )

        setupPaymentButtonSection(for: .venmo, colorSelectorOffset: -160, buttonView: venmoButtonView)
    }

    private func venmoCompletionHandler(nonce: BTVenmoAccountNonce?, error: Error?) {
        DispatchQueue.main.async { [weak self] in
            if let nonce {
                self?.progressBlock("Got a nonce 💎!")
                self?.completionBlock(nonce)
            } else if let error {
                if error as? BTVenmoError == .canceled {
                    self?.progressBlock("Canceled 🔰")
                } else {
                    self?.progressBlock(error.localizedDescription)
                }
            }
        }
    }

    // MARK: - Setup PayPal Payment Button

    private func setupPayPalButton() {
        let paypalRequest = BTPayPalCheckoutRequest(amount: "10.00")

        let paypalButtonView = PayPalButton(
            authorization: authorization,
            request: paypalRequest,
            color: selectedPayPalColor,
            width: 300,
            completion: paypalCompletionHandler(nonce:error:)
        )

        setupPaymentButtonSection(for: .paypal, colorSelectorOffset: -30, buttonView: paypalButtonView)
    }

    private func paypalCompletionHandler(nonce: BTPayPalAccountNonce?, error: Error?) {
        DispatchQueue.main.async { [weak self] in
            if let nonce {
                self?.progressBlock("Got a nonce 💎!")
                self?.completionBlock(nonce)
            } else if let error {
                if error as? BTPayPalError == .canceled {
                    self?.progressBlock("Canceled 🔰")
                } else {
                    self?.progressBlock(error.localizedDescription)
                }
            }
        }
    }
}
