import UIKit

class BraintreeDemoPreferredPaymentMethodsViewController: BraintreeDemoBaseViewController {
    private let preferredPaymentMethods: BTPreferredPaymentMethods
    private let paypalDriver: BTPayPalDriver
    private let venmoDriver: BTVenmoDriver
    private let payPalCheckoutButton = UIButton(type: .system)
    private let payPalVaultButton = UIButton(type: .system)
    private let venmoButton = UIButton(type: .system)
    
    override init?(authorization: String!) {
        guard let apiClient = BTAPIClient(authorization: authorization) else { return nil }
        
        preferredPaymentMethods = BTPreferredPaymentMethods(apiClient: apiClient)
        paypalDriver = BTPayPalDriver(apiClient: apiClient)
        venmoDriver = BTVenmoDriver(apiClient: apiClient)

        super.init(authorization: authorization)
        
        title = "Preferred Payment Methods"
        view.backgroundColor = UIColor(red: 250.0 / 255.0, green: 253.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
        
        let preferredPaymentMethodsButton = UIButton(type: .system)
        preferredPaymentMethodsButton.setTitle("Fetch Preferred Payment Methods", for: .normal)
        preferredPaymentMethodsButton.translatesAutoresizingMaskIntoConstraints = false
        preferredPaymentMethodsButton.addTarget(self, action: #selector(preferredPaymentMethodsButtonTapped(_:)), for: .touchUpInside)
        view.addSubview(preferredPaymentMethodsButton)
        
        payPalCheckoutButton.setTitle("PayPal Checkout", for: .normal)
        payPalCheckoutButton.translatesAutoresizingMaskIntoConstraints = false
        payPalCheckoutButton.addTarget(self, action: #selector(payPalCheckoutButtonTapped(_:)), for: .touchUpInside)
        payPalCheckoutButton.isEnabled = false
        view.addSubview(payPalCheckoutButton)
        
        payPalVaultButton.setTitle("PayPal Vault", for: .normal)
        payPalVaultButton.translatesAutoresizingMaskIntoConstraints = false
        payPalVaultButton.addTarget(self, action: #selector(payPalVaultButtonTapped(_:)), for: .touchUpInside)
        payPalVaultButton.isEnabled = false
        view.addSubview(payPalVaultButton)
        
        venmoButton.setTitle("Venmo", for: .normal)
        venmoButton.translatesAutoresizingMaskIntoConstraints = false
        venmoButton.addTarget(self, action: #selector(venmoButtonTapped(_:)), for: .touchUpInside)
        venmoButton.isEnabled = false
        view.addSubview(venmoButton)
        
        view.addConstraints([preferredPaymentMethodsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                             preferredPaymentMethodsButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                             payPalVaultButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                             payPalVaultButton.bottomAnchor.constraint(equalTo: payPalCheckoutButton.bottomAnchor, constant: -40),
                             payPalCheckoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                             payPalCheckoutButton.bottomAnchor.constraint(equalTo: venmoButton.bottomAnchor, constant: -40),
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
            self.payPalCheckoutButton.isEnabled = result.isPayPalPreferred
            self.payPalVaultButton.isEnabled = result.isPayPalPreferred
            self.venmoButton.isEnabled = result.isVenmoPreferred
        }
    }
    
    @objc func payPalCheckoutButtonTapped(_ button: UIButton) {
        self.progressBlock("Tapped PayPal Checkout")
        
        button.setTitle("Processing...", for: .disabled)
        button.isEnabled = false
        
        let paypalRequest = BTPayPalCheckoutRequest(amount: "4.30")
        paypalDriver.tokenizePayPalAccount(with: paypalRequest) { (nonce, error) in
            button.isEnabled = true

            if let e = error {
                self.progressBlock(e.localizedDescription)
            } else if let n = nonce {
                self.completionBlock(n)
            } else {
                self.progressBlock("Canceled")
            }
        }
    }
    
    @objc func payPalVaultButtonTapped(_ button: UIButton) {
        self.progressBlock("Tapped PayPal Vault")
        
        button.setTitle("Processing...", for: .disabled)
        button.isEnabled = false
        
        let paypalRequest = BTPayPalVaultRequest()
        paypalRequest.activeWindow = self.view.window
        paypalDriver.tokenizePayPalAccount(with: paypalRequest) { (nonce, error) in
            button.isEnabled = true
            
            if let e = error {
                self.progressBlock(e.localizedDescription)
            } else if let n = nonce {
                self.completionBlock(n)
            } else {
                self.progressBlock("Canceled")
            }
        }
    }
    
    @objc func venmoButtonTapped(_ button: UIButton) {
        self.progressBlock("Tapped Venmo")
        
        button.setTitle("Processing...", for: .disabled)
        button.isEnabled = false

        venmoDriver.tokenizeVenmoAccount(with: BTVenmoRequest()) { (nonce, error) in
            button.isEnabled = true
            
            if let e = error {
                self.progressBlock(e.localizedDescription)
            } else if let n = nonce {
                self.completionBlock(n)
            } else {
                self.progressBlock("Canceled")
            }
        }
    }
}

