import UIKit
import BraintreeCore
import BraintreePayPal
import BraintreeVenmo
import BraintreeShopperInsights

class ShopperInsightsViewController: PaymentButtonBaseViewController {
    
    private let shopperInsightsClient: BTShopperInsightsClient
    private let paypalClient: BTPayPalClient
    private let venmoClient: BTVenmoClient
    private let payPalCheckoutButton = UIButton(type: .system)
    private let payPalVaultButton = UIButton(type: .system)
    private let venmoButton = UIButton(type: .system)
    
    override init(authorization: String) {
        let apiClient = BTAPIClient(authorization: authorization)!
        
        shopperInsightsClient = BTShopperInsightsClient(apiClient: apiClient)
        paypalClient = BTPayPalClient(apiClient: apiClient)
        venmoClient = BTVenmoClient(apiClient: apiClient)

        super.init(authorization: authorization)
        
        title = "Shopper Insights"
        
        let shopperInsightsButton = UIButton(type: .system)
        shopperInsightsButton.setTitle("Fetch recommended payments", for: .normal)
        shopperInsightsButton.translatesAutoresizingMaskIntoConstraints = false
        shopperInsightsButton.addTarget(self, action: #selector(shopperInsightsButtonTapped(_:)), for: .touchUpInside)
        view.addSubview(shopperInsightsButton)
        
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
        
        view.addConstraints([shopperInsightsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                             shopperInsightsButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
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
    
    @objc func shopperInsightsButtonTapped(_ button: UIButton) {
        self.progressBlock("Fetching shopper insights...")
        
        let request = BTShopperInsightsRequest(
            email: "my-email@gmail.com",
            phone: Phone(
                countryCode: "1",
                nationalNumber: "1234567"
            )
        )
        Task {
            do {
                let result = try await shopperInsightsClient.getRecommendedPaymentMethods(request: request)
                self.progressBlock("PayPal Recommended: \(result.isPayPalRecommended)\nVenmo Recommended: \(result.isVenmoRecommended)")
                self.payPalCheckoutButton.isEnabled = result.isPayPalRecommended
                self.payPalVaultButton.isEnabled = result.isPayPalRecommended
                self.venmoButton.isEnabled = result.isVenmoRecommended
            } catch {
                self.progressBlock("Error: \(error.localizedDescription)")
            }
        }
    }
    
    @objc func payPalCheckoutButtonTapped(_ button: UIButton) {
        self.progressBlock("Tapped PayPal Checkout")
        
        button.setTitle("Processing...", for: .disabled)
        button.isEnabled = false
        
        let paypalRequest = BTPayPalCheckoutRequest(amount: "4.30")
        paypalClient.tokenize(paypalRequest) { (nonce, error) in
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
        paypalClient.tokenize(paypalRequest) { (nonce, error) in
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

        let venmoRequest = BTVenmoRequest(paymentMethodUsage: .multiUse)
        venmoClient.tokenize(venmoRequest) { (nonce, error) in
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

