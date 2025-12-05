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

        setupColorSelector(for: .paypal, verticalOffset: -30)
        setupColorSelector(for: .venmo, verticalOffset: -160)
        setupVenmoButton()
        setupPayPalButton()
    }

    enum PaymentButtonType {
        case venmo
        case paypal
    }

    private func setupColorSelector(for buttonType: PaymentButtonType, verticalOffset: CGFloat) {
        let segmentedControl = UISegmentedControl(items: ["Blue", "Black", "White"])
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false

        segmentedControl.addAction(
            UIAction { [weak self] action in
                guard let self = self, let sender = action.sender as? UISegmentedControl else { return }
                self.colorChange(for: buttonType, selectedIndex: sender.selectedSegmentIndex)
            }, for: .valueChanged)

        view.addSubview(segmentedControl)
        NSLayoutConstraint.activate([
            segmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            segmentedControl.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: verticalOffset),
            segmentedControl.widthAnchor.constraint(equalToConstant: 250)
        ])
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

    private func setupVenmoButton() {
        let venmoRequest = BTVenmoRequest(paymentMethodUsage: .singleUse)

        let venmoButtonView = VenmoButton(
            authentication: authorization,
            // swiftlint:disable:next force_unwrapping
            universalLink: URL(string: "https://mobile-sdk-demo-site-838cead5d3ab.herokuapp.com/braintree-payments")!,
            request: venmoRequest,
            color: selectedVenmoColor,
            width: 300,
            completion: venmoCompletionHandler
        )

        if let existingHostingController = hostingVenmoController {
            existingHostingController.willMove(toParent: nil)
            existingHostingController.view.removeFromSuperview()
            existingHostingController.removeFromParent()
        }

        hostingVenmoController = UIHostingController(rootView: venmoButtonView)
        guard let hostingVenmoController else { return }

        addChild(hostingVenmoController)

        hostingVenmoController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingVenmoController.view.backgroundColor = .clear
        view.addSubview(hostingVenmoController.view)

        NSLayoutConstraint.activate([
            hostingVenmoController.view.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            hostingVenmoController.view.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 20),
            hostingVenmoController.view.widthAnchor.constraint(equalToConstant: 300),
            hostingVenmoController.view.heightAnchor.constraint(equalToConstant: 45)
        ])

        hostingVenmoController.didMove(toParent: self)
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

    private func setupPayPalButton() {
        let paypalRequest = BTPayPalCheckoutRequest(amount: "10.00")

        let paypalButtonView = PayPalButton(
            authorization: authorization,
            request: paypalRequest,
            color: selectedPayPalColor,
            width: 300,
            completion: paypalCompletionHandler(nonce:error:)
        )

        if let existingHostingController = hostingPayPalController {
            existingHostingController.willMove(toParent: nil)
            existingHostingController.view.removeFromSuperview()
            existingHostingController.removeFromParent()
        }

        hostingPayPalController = UIHostingController(rootView: paypalButtonView)
        guard let hostingPayPalController else { return }

        addChild(hostingPayPalController)

        hostingPayPalController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingPayPalController.view.backgroundColor = .clear
        view.addSubview(hostingPayPalController.view)

        NSLayoutConstraint.activate([
            hostingPayPalController.view.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            hostingPayPalController.view.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -120),
            hostingPayPalController.view.widthAnchor.constraint(equalToConstant: 300),
            hostingPayPalController.view.heightAnchor.constraint(equalToConstant: 45)
        ])

        hostingPayPalController.didMove(toParent: self)
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
