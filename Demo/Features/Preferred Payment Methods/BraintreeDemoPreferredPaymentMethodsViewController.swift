import UIKit

class BraintreeDemoPreferredPaymentMethodsViewController: BraintreeDemoBaseViewController {
    
    private let preferredPaymentMethods: BTPreferredPaymentMethods
    private let paypalDriver: BTPayPalDriver
    private let venmoDriver: BTVenmoDriver
    private let oneTimePaymentButton = UIButton(type: .system)
    private let billingAgreementButton = UIButton(type: .system)
    private let venmoButton = UIButton(type: .system)
    
    override init?(authorization: String!) {
        guard let apiClient = BTAPIClient(authorization: authorization) else { return nil }
        
        preferredPaymentMethods = BTPreferredPaymentMethods(apiClient: apiClient)
        paypalDriver = BTPayPalDriver(apiClient: apiClient)
        venmoDriver = BTVenmoDriver(apiClient: apiClient)

        super.init(authorization: authorization)
        
        paypalDriver.appSwitchDelegate = self
        paypalDriver.viewControllerPresentingDelegate = self
        
        title = "Preferred Payment Methods"
        view.backgroundColor = UIColor(red: 250.0 / 255.0, green: 253.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
        
        let preferredPaymentMethodsButton = UIButton(type: .system)
        preferredPaymentMethodsButton.setTitle("Fetch Preferred Payment Methods", for: .normal)
        preferredPaymentMethodsButton.translatesAutoresizingMaskIntoConstraints = false
        preferredPaymentMethodsButton.addTarget(self, action: #selector(preferredPaymentMethodsButtonTapped(_:)), for: .touchUpInside)
        view.addSubview(preferredPaymentMethodsButton)
        
        oneTimePaymentButton.setTitle("PayPal One-Time Payment", for: .normal)
        oneTimePaymentButton.translatesAutoresizingMaskIntoConstraints = false
        oneTimePaymentButton.addTarget(self, action: #selector(oneTimePaymentButtonTapped(_:)), for: .touchUpInside)
        oneTimePaymentButton.isEnabled = false
        view.addSubview(oneTimePaymentButton)
        
        billingAgreementButton.setTitle("PayPal Billing Agreement", for: .normal)
        billingAgreementButton.translatesAutoresizingMaskIntoConstraints = false
        billingAgreementButton.addTarget(self, action: #selector(billingAgreementButtonTapped(_:)), for: .touchUpInside)
        billingAgreementButton.isEnabled = false
        view.addSubview(billingAgreementButton)
        
        venmoButton.setTitle("Venmo", for: .normal)
        venmoButton.translatesAutoresizingMaskIntoConstraints = false
        venmoButton.addTarget(self, action: #selector(venmoButtonTapped(_:)), for: .touchUpInside)
        venmoButton.isEnabled = false
        view.addSubview(venmoButton)
        
        view.addConstraints([preferredPaymentMethodsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                             preferredPaymentMethodsButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                             billingAgreementButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                             billingAgreementButton.bottomAnchor.constraint(equalTo: oneTimePaymentButton.bottomAnchor, constant: -40),
                             oneTimePaymentButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                             oneTimePaymentButton.bottomAnchor.constraint(equalTo: venmoButton.bottomAnchor, constant: -40),
                             venmoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                             venmoButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40)])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func preferredPaymentMethodsButtonTapped(_ button: UIButton) {
        self.progressBlock("Fetching preferred payment methods...")
        preferredPaymentMethods.fetch { (result) in
            self.progressBlock("PayPal Preferred: \(result.isPayPalPreferred)\nVenmo Preferred: \(result.isVenmoPreferred)")
            self.oneTimePaymentButton.isEnabled = result.isPayPalPreferred
            self.billingAgreementButton.isEnabled = result.isPayPalPreferred
            self.venmoButton.isEnabled = result.isVenmoPreferred
        }
    }
    
    @objc func oneTimePaymentButtonTapped(_ button: UIButton) {
        self.progressBlock("Tapped PayPal One-Time Payment")
        
        button.setTitle("Processing...", for: .disabled)
        button.isEnabled = false
        
        let paypalRequest = BTPayPalRequest(amount: "4.30")
        paypalDriver.requestOneTimePayment(paypalRequest) { (nonce, error) in
            button.isEnabled = true
            
            if let e = error {
                self.progressBlock(e.localizedDescription)
            } else if let n = nonce {
                self.completionBlock(n)
            } else {
                self.progressBlock("Cancelled")
            }
        }
    }
    
    @objc func billingAgreementButtonTapped(_ button: UIButton) {
        self.progressBlock("Tapped PayPal Billing Agreement")
        
        button.setTitle("Processing...", for: .disabled)
        button.isEnabled = false
        
        let paypalRequest = BTPayPalRequest()
        paypalDriver.requestBillingAgreement(paypalRequest) { (nonce, error) in
            button.isEnabled = true
            
            if let e = error {
                self.progressBlock(e.localizedDescription)
            } else if let n = nonce {
                self.completionBlock(n)
            } else {
                self.progressBlock("Cancelled")
            }
        }
    }
    
    @objc func venmoButtonTapped(_ button: UIButton) {
        self.progressBlock("Tapped Venmo")
        
        button.setTitle("Processing...", for: .disabled)
        button.isEnabled = false
        
        venmoDriver.authorizeAccountAndVault(false) { (nonce, error) in
            button.isEnabled = true
            
            if let e = error {
                self.progressBlock(e.localizedDescription)
            } else if let n = nonce {
                self.completionBlock(n)
            } else {
                self.progressBlock("Cancelled")
            }
        }
    }
}

// MARK: - BTAppSwitchDelegate
extension BraintreeDemoPreferredPaymentMethodsViewController: BTAppSwitchDelegate {
    func appSwitcherWillPerformAppSwitch(_ appSwitcher: Any) {
        self.progressBlock("paymentDriverWillPerformAppSwitch:")
    }
    
    func appSwitcher(_ appSwitcher: Any, didPerformSwitchTo target: BTAppSwitchTarget) {
        switch (target) {
        case .webBrowser:
            self.progressBlock("appSwitcher:didPerformSwitchToTarget: browser")
            break
        case .nativeApp:
            self.progressBlock("appSwitcher:didPerformSwitchToTarget: app")
            break
        case .unknown:
            self.progressBlock("appSwitcher:didPerformSwitchToTarget: unknown")
            break
        default:
            break
        }
    }
    
    func appSwitcherWillProcessPaymentInfo(_ appSwitcher: Any) {
        self.progressBlock("paymentDriverWillProcessPaymentInfo:")
    }
}

// MARK: - BTViewControllerPresentingDelegate
extension BraintreeDemoPreferredPaymentMethodsViewController: BTViewControllerPresentingDelegate {
    func paymentDriver(_ driver: Any, requestsPresentationOf viewController: UIViewController) {
        self.present(viewController, animated: true)
    }
    
    func paymentDriver(_ driver: Any, requestsDismissalOf viewController: UIViewController) {
        viewController.dismiss(animated: true)
    }
}
