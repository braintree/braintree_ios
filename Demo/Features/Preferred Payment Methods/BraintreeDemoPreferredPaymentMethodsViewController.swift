import UIKit

class BraintreeDemoPreferredPaymentMethodsViewController: BraintreeDemoBaseViewController {
    
    private let preferredPaymentMethods: BTPreferredPaymentMethods
    private let paypalDriver: BTPayPalDriver
    
    private var oneTimePaymentButton: UIButton!
    private var billingAgreementButton: UIButton!
    
    override init?(authorization: String!) {
        guard let apiClient = BTAPIClient(authorization: authorization) else { return nil }
        self.preferredPaymentMethods = BTPreferredPaymentMethods(apiClient: apiClient)
        self.paypalDriver = BTPayPalDriver(apiClient: apiClient)
        
        super.init(authorization: authorization)
        
        self.paypalDriver.appSwitchDelegate = self
        self.paypalDriver.viewControllerPresentingDelegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Preferred Payment Methods"
        view.backgroundColor = UIColor(red: 250.0 / 255.0, green: 253.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
        
        let preferredPaymentMethodsButton = UIButton(type: .system)
        preferredPaymentMethodsButton.setTitle("Fetch Preferred Payment Methods", for: .normal)
        preferredPaymentMethodsButton.sizeToFit()
        preferredPaymentMethodsButton.translatesAutoresizingMaskIntoConstraints = false
        preferredPaymentMethodsButton.addTarget(self, action: #selector(preferredPaymentMethodsButtonTapped(_:)), for: .touchUpInside)
        view.addSubview(preferredPaymentMethodsButton)
        
        view.addConstraint(NSLayoutConstraint(item: preferredPaymentMethodsButton,
                                              attribute: .centerX,
                                              relatedBy: .equal,
                                              toItem: view,
                                              attribute: .centerX,
                                              multiplier: 1.0,
                                              constant: 0))
        
        view.addConstraint(NSLayoutConstraint(item: preferredPaymentMethodsButton,
                                              attribute: .centerY,
                                              relatedBy: .equal,
                                              toItem: view,
                                              attribute: .centerY,
                                              multiplier: 1.0,
                                              constant: 0))
        
        oneTimePaymentButton = UIButton(type: .system)
        oneTimePaymentButton.setTitle("PayPal One-Time Payment", for: .normal)
        oneTimePaymentButton.sizeToFit()
        oneTimePaymentButton.translatesAutoresizingMaskIntoConstraints = false
        oneTimePaymentButton.addTarget(self, action: #selector(oneTimePaymentButtonTapped(_:)), for: .touchUpInside)
        oneTimePaymentButton.isEnabled = false
        view.addSubview(oneTimePaymentButton)
        
        view.addConstraint(NSLayoutConstraint(item: oneTimePaymentButton!,
                                              attribute: .centerX,
                                              relatedBy: .equal,
                                              toItem: view,
                                              attribute: .centerX,
                                              multiplier: 1.0,
                                              constant: 0))
        
        view.addConstraint(NSLayoutConstraint(item: oneTimePaymentButton!,
                                              attribute: .bottom,
                                              relatedBy: .equal,
                                              toItem: view,
                                              attribute: .bottom,
                                              multiplier: 1.0,
                                              constant: -40))
        
        billingAgreementButton = UIButton(type: .system)
        billingAgreementButton.setTitle("PayPal Billing Agreement", for: .normal)
        billingAgreementButton.sizeToFit()
        billingAgreementButton.translatesAutoresizingMaskIntoConstraints = false
        billingAgreementButton.addTarget(self, action: #selector(billingAgreementButtonTapped(_:)), for: .touchUpInside)
        billingAgreementButton.isEnabled = false
        view.addSubview(billingAgreementButton)
        
        view.addConstraint(NSLayoutConstraint(item: billingAgreementButton!,
                                              attribute: .centerX,
                                              relatedBy: .equal,
                                              toItem: view,
                                              attribute: .centerX,
                                              multiplier: 1.0,
                                              constant: 0))
        
        view.addConstraint(NSLayoutConstraint(item: billingAgreementButton!,
                                              attribute: .bottom,
                                              relatedBy: .equal,
                                              toItem: oneTimePaymentButton,
                                              attribute: .bottom,
                                              multiplier: 1.0,
                                              constant: -40))
    }
    
    @objc func preferredPaymentMethodsButtonTapped(_ button: UIButton) {
        self.progressBlock("Fetching preferred payment methods...")
        preferredPaymentMethods.fetch { (result) in
            self.progressBlock("PayPal Preferred: \(result.isPayPalPreferred)")
            self.oneTimePaymentButton.isEnabled = result.isPayPalPreferred
            self.billingAgreementButton.isEnabled = result.isPayPalPreferred
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
}

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

extension BraintreeDemoPreferredPaymentMethodsViewController: BTViewControllerPresentingDelegate {
    func paymentDriver(_ driver: Any, requestsPresentationOf viewController: UIViewController) {
        self.present(viewController, animated: true)
    }
    
    func paymentDriver(_ driver: Any, requestsDismissalOf viewController: UIViewController) {
        viewController.dismiss(animated: true)
    }
}
