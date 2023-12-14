import UIKit
import BraintreeCore
import BraintreePayPal
import BraintreeVenmo
import BraintreeShopperInsights

class ShopperInsightsViewController: PaymentButtonBaseViewController {
    
    lazy var shopperInsightsClient = BTShopperInsightsClient(apiClient: apiClient)
    lazy var paypalClient = BTPayPalClient(apiClient: apiClient)
    lazy var venmoClient = BTVenmoClient(apiClient: apiClient)
    
    lazy var shopperInsightsButton = createButton(title: "Fetch shopper insights", action: #selector(shopperInsightsButtonTapped))
    lazy var payPalCheckoutButton = createButton(title: "PayPal Checkout", action: #selector(payPalCheckoutButtonTapped))
    lazy var payPalVaultButton = createButton(title: "PayPal Vault", action: #selector(payPalVaultButtonTapped))
    lazy var venmoButton = createButton(title: "Venmo", action: #selector(venmoButtonTapped))
    
    override func createPaymentButton() -> UIView {
        let buttons = [shopperInsightsButton, payPalCheckoutButton, payPalVaultButton, venmoButton]
        buttons[1...3].forEach { $0.isEnabled = false }
        let stackView = UIStackView(arrangedSubviews: buttons)
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
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
            self.displayResultDetails(nonce: nonce, error: error)
        }
    }
    
    @objc func payPalVaultButtonTapped(_ button: UIButton) {
        self.progressBlock("Tapped PayPal Vault")
        
        button.setTitle("Processing...", for: .disabled)
        button.isEnabled = false
        
        let paypalRequest = BTPayPalVaultRequest()
        paypalClient.tokenize(paypalRequest) { (nonce, error) in
            button.isEnabled = true
            self.displayResultDetails(nonce: nonce, error: error)
        }
    }
    
    @objc func venmoButtonTapped(_ button: UIButton) {
        self.progressBlock("Tapped Venmo")
        
        button.setTitle("Processing...", for: .disabled)
        button.isEnabled = false

        let venmoRequest = BTVenmoRequest(paymentMethodUsage: .multiUse)
        venmoClient.tokenize(venmoRequest) { (nonce, error) in
            button.isEnabled = true
            self.displayResultDetails(nonce: nonce, error: error)
        }
    }
    
    private func displayResultDetails(nonce: BTPaymentMethodNonce?, error: Error?) {
        if let error {
            self.progressBlock(error.localizedDescription)
        } else if let nonce {
            self.completionBlock(nonce)
        } else {
            self.progressBlock("Canceled")
        }
    }
}

