import Foundation
import UIKit
import BraintreePayPal
import BraintreeCore

class PayPalWebCheckoutViewController: PaymentButtonBaseViewController {

    lazy var payPalClient = BTPayPalClient(
        apiClient: apiClient,
        universalLink: URL(string: "https://mobile-sdk-demo-site-838cead5d3ab.herokuapp.com/braintree-payments")!
    )
    
    lazy var emailLabel: UILabel = {
        let label = UILabel()
        label.text = "Buyer email:"
        return label
    }()
    
    lazy var emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "placeholder@email.com"
        textField.backgroundColor = .systemBackground
        return textField
    }()
    
    lazy var payLaterToggleLabel: UILabel = {
        let label = UILabel()
        label.text = "Offer Pay Later"
        label.font = .preferredFont(forTextStyle: .footnote)
        return label
    }()
    
    let payLaterToggle = UISwitch()

    lazy var newPayPalCheckoutToggleLabel: UILabel = {
        let label = UILabel()
        label.text = "New PayPal Checkout Experience"
        label.font = .preferredFont(forTextStyle: .footnote)
        return label
    }()
    
    let newPayPalCheckoutToggle = UISwitch()
    
    lazy var rbaDataToggleLabel: UILabel = {
        let label = UILabel()
        label.text = "Recurring Billing (RBA) Data"
        label.font = .preferredFont(forTextStyle: .footnote)
        return label
    }()
    
    let rbaDataToggle = UISwitch()

    override func viewDidLoad() {
        super.heightConstraint = 350
        super.viewDidLoad()
    }

    override func createPaymentButton() -> UIView {
        let payPalCheckoutButton = createButton(title: "PayPal Checkout", action: #selector(tappedPayPalCheckout))
        let payPalVaultButton = createButton(title: "PayPal Vault", action: #selector(tappedPayPalVault))
        let payPalAppSwitchButton = createButton(title: "PayPal App Switch", action: #selector(tappedPayPalAppSwitch))
        let oneTimeCheckoutStackView = buttonsStackView(label: "1-Time Checkout", views: [
            UIStackView(arrangedSubviews: [payLaterToggleLabel, payLaterToggle]),
            UIStackView(arrangedSubviews: [newPayPalCheckoutToggleLabel, newPayPalCheckoutToggle]),
            payPalCheckoutButton
        ])
        let vaultStackView = buttonsStackView(label: "Vault", views: [
            UIStackView(arrangedSubviews: [rbaDataToggleLabel, rbaDataToggle]),
            payPalVaultButton,
            payPalAppSwitchButton
        ])


        let stackView = UIStackView(arrangedSubviews: [
            UIStackView(arrangedSubviews: [emailLabel, emailTextField]),
            oneTimeCheckoutStackView,
            vaultStackView
        ])

        NSLayoutConstraint.activate([
            oneTimeCheckoutStackView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            oneTimeCheckoutStackView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),

            vaultStackView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            vaultStackView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor)
          ])

        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.spacing = 25
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
    
    // MARK: - 1-Time Checkout Flows

    @objc func tappedPayPalCheckout(_ sender: UIButton) {
        progressBlock("Tapped PayPal - Checkout using BTPayPalClient")
        sender.setTitle("Processing...", for: .disabled)
        sender.isEnabled = false

        let request = BTPayPalCheckoutRequest(amount: "5.00")
        request.userAuthenticationEmail = emailTextField.text
        
        let lineItem = BTPayPalLineItem(quantity: "1", unitAmount: "5.00", name: "item one 1234567", kind: .debit)
        lineItem.upcCode = "123456789"
        lineItem.upcType = .UPC_A
        lineItem.imageURL = URL(string: "https://www.example.com/example.jpg")

        request.lineItems = [lineItem]        
        request.offerPayLater = payLaterToggle.isOn
        request.intent = newPayPalCheckoutToggle.isOn ? .sale : .authorize

        payPalClient.tokenize(request) { nonce, error in
            sender.isEnabled = true

            guard let nonce else {
                self.progressBlock(error?.localizedDescription)
                return
            }

            self.completionBlock(nonce)
        }
    }
    
    // MARK: - Vault Flows
    
    @objc func tappedPayPalVault(_ sender: UIButton) {
        progressBlock("Tapped PayPal - Vault using BTPayPalClient")
        sender.setTitle("Processing...", for: .disabled)
        sender.isEnabled = false

        var request = BTPayPalVaultRequest()
        request.userAuthenticationEmail = emailTextField.text
        
        if rbaDataToggle.isOn {
            let billingPricing = BTPayPalBillingPricing(
                pricingModel: .autoReload,
                amount: "9.99",
                reloadThresholdAmount: "100.00"
            )
            
            let billingCycle = BTPayPalBillingCycle(
                interval: .month,
                intervalCount: 1,
                numberOfExecutions: 12,
                sequence: 9,
                startDate: "2024-04-06T00:00:00Z",
                isTrial: false,
                pricing: billingPricing
            )
            
            let recurringBillingDetails = BTPayPalRecurringBillingDetails(
                billingCycles: [billingCycle],
                currencyISOCode: "USD",
                totalAmount: "35.99",
                productName: "Vogue Magazine Subscription",
                productDescription: "Home delivery to Chicago, IL",
                productQuantity: 1,
                oneTimeFeeAmount: "5.99",
                shippingAmount: "1.99",
                productAmount: "9.99",
                taxAmount: "0.59"
            )
            
            request = BTPayPalVaultRequest(recurringBillingDetails: recurringBillingDetails, recurringBillingPlanType: .subscription)
        }

        payPalClient.tokenize(request) { nonce, error in
            sender.isEnabled = true

            guard let nonce else {
                self.progressBlock(error?.localizedDescription)
                return
            }

            self.completionBlock(nonce)
        }
    }

    @objc func tappedPayPalAppSwitch(_ sender: UIButton) {
        sender.setTitle("Processing...", for: .disabled)
        sender.isEnabled = false
        
        guard let userEmail = emailTextField.text, !userEmail.isEmpty else {
            self.progressBlock("Email cannot be nil for App Switch flow")
            sender.isEnabled = true
            return
        }

        let request = BTPayPalVaultRequest(
            userAuthenticationEmail: userEmail,
            enablePayPalAppSwitch: true
        )

        payPalClient.tokenize(request) { nonce, error in
            sender.isEnabled = true
            
            guard let nonce else {
                self.progressBlock(error?.localizedDescription)
                return

            }
            
            self.completionBlock(nonce)
        }
    }
    
    // MARK: - Helpers
    
    private func buttonsStackView(label: String, views: [UIView]) -> UIStackView {
        let titleLabel = UILabel()
        titleLabel.text = label
        
        let buttonsStackView = UIStackView(arrangedSubviews: [titleLabel] + views)
        buttonsStackView.axis = .vertical
        buttonsStackView.distribution = .fillProportionally
        buttonsStackView.backgroundColor = .systemGray6
        buttonsStackView.layoutMargins = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        buttonsStackView.isLayoutMarginsRelativeArrangement = true
        
        return buttonsStackView
    }
}
