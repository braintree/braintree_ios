import UIKit
import SwiftUI
import BraintreeUIComponents
import BraintreeVenmo

class PaymentButtonViewController: PaymentButtonBaseViewController {

    private var hostingController: UIHostingController<VenmoButton>?
    private var selectedColor: VenmoButtonColor = .blue

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Payment Buttons"
        view.backgroundColor = .systemBackground

        setupColorSelector()
        setupVenmoButton()
    }
    
    private func setupColorSelector() {
        let colorSegmentedControl = UISegmentedControl(items: ["Blue", "Black", "White"])
        colorSegmentedControl.selectedSegmentIndex = 0
        colorSegmentedControl.addTarget(self, action: #selector(colorChanged(_:)), for: .valueChanged)
        colorSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(colorSegmentedControl)
        
        NSLayoutConstraint.activate([
            colorSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            colorSegmentedControl.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -80),
            colorSegmentedControl.widthAnchor.constraint(equalToConstant: 250)
        ])
    }
    
    @objc private func colorChanged(_ sender: UISegmentedControl) {
        selectedColor = switch sender.selectedSegmentIndex {
        case 0:
            .blue
        case 1:
            .black
        case 2:
            .white
        default:
            .blue
        }

        setupVenmoButton()
    }
    
    private func setupVenmoButton() {
        let venmoRequest = BTVenmoRequest(paymentMethodUsage: .singleUse)

        let venmoButtonView = VenmoButton(
            authentication: authorization,
            // swiftlint:disable:next force_unwrapping
            universalLink: URL(string: "https://mobile-sdk-demo-site-838cead5d3ab.herokuapp.com/braintree-payments")!,
            request: venmoRequest,
            color: selectedColor,
            width: 300,
            completion: venmoCompletionHandler
        )
        if let existingHostingController = hostingController {
            existingHostingController.willMove(toParent: nil)
            existingHostingController.view.removeFromSuperview()
            existingHostingController.removeFromParent()
        }

        hostingController = UIHostingController(rootView: venmoButtonView)
        guard let hostingController else { return }
        
        addChild(hostingController)

        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController.view.backgroundColor = .clear
        view.addSubview(hostingController.view)

        NSLayoutConstraint.activate([
            hostingController.view.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            hostingController.view.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 20),
            hostingController.view.widthAnchor.constraint(equalToConstant: 300),
            hostingController.view.heightAnchor.constraint(equalToConstant: 45)
        ])
        
        hostingController.didMove(toParent: self)
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
}
