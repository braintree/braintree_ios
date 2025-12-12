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

    // swiftlint:disable:next implicitly_unwrapped_optional
    private var buttonsStackView: UIStackView!
    private var payPalStackView: UIStackView?
    private var venmoStackView: UIStackView?

    override func viewDidLoad() {
        title = "Payment Buttons"
        
        super.heightConstraint = 250
        super.viewDidLoad()
    }

    // MARK: - Setup PayPal Payment Button

    private func setupPayPalButton() -> UIView {
        let payPalRequest = BTPayPalCheckoutRequest(amount: "10.00")

        let payPalButtonView = PayPalButton(
            authorization: authorization,
            request: payPalRequest,
            color: selectedPayPalColor,
            width: 300,
            completion: payPalCompletionHandler(nonce:error:)
        )

        return setupPaymentButtonSection(for: .payPal, buttonView: payPalButtonView)
    }

    private func payPalCompletionHandler(nonce: BTPayPalAccountNonce?, error: Error?) {
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

    // MARK: - Setup Venmo Payment Button

    private func setupVenmoButton() -> UIView {
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

        return setupPaymentButtonSection(for: .venmo, buttonView: venmoButtonView)
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

    // MARK: - UI Setup

    @objc
    func tappedColorSegment(_ sender: UISegmentedControl) {
        guard let buttonType = PaymentButtonType(rawValue: sender.tag) else { return }
        switch buttonType {
        case .venmo:
            selectedVenmoColor = switch sender.selectedSegmentIndex {
            case 0: .blue
            case 1: .black
            case 2: .white
            default: .blue
            }
            updateButtonSection(for: .venmo)
        case .payPal:
            selectedPayPalColor = switch sender.selectedSegmentIndex {
            case 0: .blue
            case 1: .black
            case 2: .white
            default: .blue
            }
            updateButtonSection(for: .payPal)
        }
    }
    
    private func updateButtonSection(for buttonType: PaymentButtonType) {
        guard let mainStackView = buttonsStackView else { return }
        
        // Remove old button section
        switch buttonType {
        case .venmo:
            if let oldStackView = venmoStackView {
                mainStackView.removeArrangedSubview(oldStackView)
                oldStackView.removeFromSuperview()
            }
        case .payPal:
            if let oldStackView = payPalStackView {
                mainStackView.removeArrangedSubview(oldStackView)
                oldStackView.removeFromSuperview()
            }
        }
        
        // Create new button section
        let newStackView: UIView
        switch buttonType {
        case .venmo:
            newStackView = setupVenmoButton()
            venmoStackView = newStackView as? UIStackView
            mainStackView.insertArrangedSubview(newStackView, at: 0)
        case .payPal:
            newStackView = setupPayPalButton()
            payPalStackView = newStackView as? UIStackView
            mainStackView.insertArrangedSubview(newStackView, at: 1)
        }
    }

    private func setupPaymentButtonSection<Content: View>(
        for buttonType: PaymentButtonType,
        buttonView: Content
    ) -> UIView {
        switch buttonType {
        case .venmo:
            if let existing = hostingVenmoController {
                existing.willMove(toParent: nil)
                existing.view.removeFromSuperview()
                existing.removeFromParent()
            }
        case .payPal:
            if let existing = hostingPayPalController {
                existing.willMove(toParent: nil)
                existing.view.removeFromSuperview()
                existing.removeFromParent()
            }
        }

        let segmentedControl = UISegmentedControl(items: ["Blue", "Black", "White"])
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.tag = buttonType.rawValue
        
        switch buttonType {
        case .venmo:
            segmentedControl.selectedSegmentIndex = switch selectedVenmoColor {
            case .blue: 0
            case .black: 1
            case .white: 2
            default: 0
            }
        case .payPal:
            segmentedControl.selectedSegmentIndex = switch selectedPayPalColor {
            case .blue: 0
            case .black: 1
            case .white: 2
            default: 0
            }
        }
        
        segmentedControl.addTarget(self, action: #selector(tappedColorSegment(_:)), for: .valueChanged)

        let hostingController = UIHostingController(rootView: buttonView)
        addChild(hostingController)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController.didMove(toParent: self)

        let stackView = UIStackView(arrangedSubviews: [segmentedControl, hostingController.view])
        stackView.axis = .vertical
        stackView.spacing = 15
        return stackView
    }

    override func createPaymentButton() -> UIView {
        venmoStackView = setupVenmoButton() as? UIStackView
        payPalStackView = setupPayPalButton() as? UIStackView
        
        let stackView = UIStackView(arrangedSubviews: [venmoStackView, payPalStackView].compactMap { $0 })
        stackView.axis = .vertical
        stackView.spacing = 30
        stackView.distribution = .fillProportionally
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        buttonsStackView = stackView
        
        return buttonsStackView
    }
}
