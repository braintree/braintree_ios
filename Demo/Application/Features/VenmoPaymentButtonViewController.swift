import UIKit
import BraintreeUIComponents
import BraintreeVenmo
import SwiftUI

class VenmoPaymentButtonViewController: BaseViewController {

    let authorization: String
    private var hostingController: UIHostingController<VenmoButton>?
    private var currentColor: VenmoButtonColor = .blue

    override init(authorization: String) {
        self.authorization = authorization
        super.init(authorization: authorization)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Venmo Payment Button"
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

        let colorLabel = UILabel()
        colorLabel.text = "Button Color:"
        colorLabel.textAlignment = .center
        colorLabel.font = .systemFont(ofSize: 16, weight: .medium)
        colorLabel.textColor = .label
        colorLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(colorLabel)
        
        NSLayoutConstraint.activate([
            colorLabel.centerXAnchor.constraint(equalTo: colorSegmentedControl.centerXAnchor),
            colorLabel.bottomAnchor.constraint(equalTo: colorSegmentedControl.topAnchor, constant: -10)
        ])
    }
    
    @objc private func colorChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            currentColor = .blue
        case 1:
            currentColor = .black
        case 2:
            currentColor = .white
        default:
            currentColor = .blue
        }

        createVenmoButton()
    }
    
    private func setupVenmoButton() {
        let descriptionLabel = UILabel()
        descriptionLabel.text = "VenmoButton from BraintreeUIComponents"
        descriptionLabel.textAlignment = .center
        descriptionLabel.font = .systemFont(ofSize: 16, weight: .medium)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            descriptionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            descriptionLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20)
        ])
        
        createVenmoButton()
    }
    
    private func createVenmoButton() {
        let venmoRequest = BTVenmoRequest(paymentMethodUsage: .singleUse)

        let venmoButtonView = VenmoButton(
            authentication: authorization,
            // swiftlint:disable:next force_unwrapping
            universalLink: URL(string: "https://mobile-sdk-demo-site-838cead5d3ab.herokuapp.com/braintree-payments")!,
            request: venmoRequest,
            color: currentColor,
            width: 300
        ) { [weak self] nonce, error in
            DispatchQueue.main.async {
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

        if let existingHostingController = hostingController {
            existingHostingController.willMove(toParent: nil)
            existingHostingController.view.removeFromSuperview()
            existingHostingController.removeFromParent()
        }

        hostingController = UIHostingController(rootView: venmoButtonView)
        guard let hostingController = hostingController else { return }
        
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
}
