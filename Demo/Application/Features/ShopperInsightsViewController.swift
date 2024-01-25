import UIKit
import BraintreeCore
import BraintreePayPal
import BraintreeVenmo
import BraintreeShopperInsights

class ShopperInsightsViewController: PaymentButtonBaseViewController {
    
    lazy var shopperInsightsClient = BTShopperInsightsClient(apiClient: apiClient)
    lazy var paypalClient = BTPayPalClient(apiClient: apiClient)
    lazy var venmoClient = BTVenmoClient(apiClient: apiClient)
    
    lazy var payPalCheckoutButton = createButton(title: "PayPal Checkout", action: #selector(payPalCheckoutButtonTapped))
    lazy var payPalVaultButton = createButton(title: "PayPal Vault", action: #selector(payPalVaultButtonTapped))
    lazy var venmoButton = createButton(title: "Venmo", action: #selector(venmoButtonTapped))
    
    lazy var emailLabel = label("Email")
    lazy var emailTextField = textField(placeholder: "Email")
    lazy var countryCodeLabel = label("Country Code")
    lazy var countryCodeTextField = textField(placeholder: "Country Code")
    lazy var nationalNumberLabel = label("National Number")
    lazy var nationalNumberTextField = textField(placeholder: "National Number")
    lazy var shopperInsightsButton = createButton(title: "Fetch Shopper Insights", action: #selector(shopperInsightsButtonTapped))
    
    lazy var shopperInsightsInputView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [
                emailLabel,
                emailTextField,
                countryCodeLabel,
                countryCodeTextField,
                nationalNumberLabel,
                nationalNumberTextField,
            ]
        )
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(
            top: 16.0,
            left: 16.0,
            bottom: 16.0,
            right: 16.0
        )
        stackView.insetsLayoutMarginsFromSafeArea = false
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(shopperInsightsInputView)
        view.addSubview(shopperInsightsButton)
        
        NSLayoutConstraint.activate(
            [
                shopperInsightsInputView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                shopperInsightsInputView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                shopperInsightsInputView.topAnchor.constraint(equalTo: view.topAnchor),
                shopperInsightsInputView.widthAnchor.constraint(equalTo: view.widthAnchor),
                shopperInsightsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
                shopperInsightsButton.topAnchor.constraint(equalTo: shopperInsightsInputView.bottomAnchor, constant: 10),
                shopperInsightsButton.widthAnchor.constraint(
                    equalTo: shopperInsightsInputView.widthAnchor,
                    multiplier: 0.8
                ),
            ]
        )
    }
    
    override func createPaymentButton() -> UIView {
        let buttons = [payPalCheckoutButton, payPalVaultButton, venmoButton]
        buttons.forEach { $0.isEnabled = false }
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
            email: emailTextField.text ?? "",
            phone: Phone(
                countryCode: countryCodeTextField.text ?? "",
                nationalNumber: nationalNumberTextField.text ?? ""
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

