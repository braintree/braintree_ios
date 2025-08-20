import Foundation
import UIKit
import BraintreePayPal
import BraintreeCore

class PayPalWebCheckoutViewController: PaymentButtonBaseViewController {

    lazy var payPalClient = BTPayPalClient(
        apiClient: apiClient,
        // swiftlint:disable:next force_unwrapping
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
        textField.textAlignment = .right
        textField.backgroundColor = .systemBackground
        textField.keyboardType = .emailAddress
        return textField
    }()
    
    lazy var emailStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [emailLabel, emailTextField])
        stackView.distribution = .fillProportionally
        return stackView
    }()
    
    lazy var countryCodeLabel: UILabel = {
        let label = UILabel()
        label.text = "Country Code:"
        return label
    }()
    
    lazy var countryCodeTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "1"
        textField.textAlignment = .right
        textField.backgroundColor = .systemBackground
        textField.keyboardType = .phonePad
        return textField
    }()
    
    lazy var countryCodeStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [countryCodeLabel, countryCodeTextField])
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    lazy var nationalNumberLabel: UILabel = {
        let label = UILabel()
        label.text = "National Number:"
        return label
    }()
    
    lazy var nationalNumberTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "000-000-000"
        textField.textAlignment = .right
        textField.backgroundColor = .systemBackground
        textField.keyboardType = .phonePad
        return textField
    }()
    
    lazy var nationalNumberStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [nationalNumberLabel, nationalNumberTextField])
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    let payLaterToggle = Toggle(title: "Offer Pay Later")
    let rbaDataToggle = Toggle(title: "Recurring Billing (RBA) Data")
    let contactInformationToggle = Toggle(title: "Add Contact Information")

    override func viewDidLoad() {
        super.heightConstraint = 500
        super.viewDidLoad()
    }

    override func createPaymentButton() -> UIView {
        let payPalCheckoutButton = createButton(title: "PayPal Checkout", action: #selector(tappedPayPalCheckout))
        
        let payPalVaultButton = createButton(title: "PayPal Vault", action: #selector(tappedPayPalVault))
        
        let payPalAppSwitchForCheckoutButton = createButton(
            title: "PayPal App Switch - Checkout",
            action: #selector(tappedPayPalAppSwitchForCheckout)
        )
        
        let payPalAppSwitchForVaultButton = createButton(
            title: "PayPal App Switch - Vault",
            action: #selector(tappedPayPalAppSwitchForVault)
        )

        let oneTimeCheckoutStackView = buttonsStackView(label: "1-Time Checkout", views: [
            payLaterToggle,
            contactInformationToggle,
            payPalCheckoutButton,
            payPalAppSwitchForCheckoutButton
        ])
        oneTimeCheckoutStackView.spacing = 12
        
        let vaultStackView = buttonsStackView(label: "Vault", views: [
            rbaDataToggle,
            payPalVaultButton,
            payPalAppSwitchForVaultButton
        ])
        vaultStackView.spacing = 12

        let stackView = UIStackView(arrangedSubviews: [
            emailStackView,
            countryCodeStackView,
            nationalNumberStackView,
            oneTimeCheckoutStackView,
            vaultStackView
        ])

        NSLayoutConstraint.activate(
            [
                oneTimeCheckoutStackView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
                oneTimeCheckoutStackView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),

                vaultStackView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
                vaultStackView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor)
            ]
        )

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

        let request = BTPayPalCheckoutRequest(amount: "5.00", offerPayLater: payLaterToggle.isOn)
        request.userAuthenticationEmail = emailTextField.text
        request.userPhoneNumber = BTPayPalPhoneNumber(
            countryCode: countryCodeTextField.text ?? "",
            nationalNumber: nationalNumberTextField.text ?? ""
        )
        
        let lineItem = BTPayPalLineItem(quantity: "1", unitAmount: "5.00", name: "item one 1234567", kind: .debit)
        lineItem.upcCode = "123456789"
        lineItem.upcType = .UPC_A
        lineItem.imageURL = URL(string: "https://www.example.com/example.jpg")

        request.lineItems = [lineItem]
        request.offerPayLater = payLaterToggle.isOn

        if contactInformationToggle.isOn {
            request.contactInformation = BTContactInformation(
                recipientEmail: "some@email.com",
                recipientPhoneNumber: .init(countryCode: "52", nationalNumber: "123456789")
            )

            request.contactPreference = .updateContactInformation
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
    
    // MARK: - Vault Flows
    
    @objc func tappedPayPalVault(_ sender: UIButton) {
        progressBlock("Tapped PayPal - Vault using BTPayPalClient")
        sender.setTitle("Processing...", for: .disabled)
        sender.isEnabled = false

        var request = BTPayPalVaultRequest()
        request.userAuthenticationEmail = emailTextField.text
        request.userPhoneNumber = BTPayPalPhoneNumber(
            countryCode: countryCodeTextField.text ?? "",
            nationalNumber: nationalNumberTextField.text ?? ""
        )
        
        if rbaDataToggle.isOn {
            let billingPricing = BTPayPalBillingPricing(
                pricingModel: .fixed,
                amount: "9.99"
            )
            
            let billingCycle = BTPayPalBillingCycle(
                isTrial: false,
                numberOfExecutions: 1,
                interval: .month,
                intervalCount: 1,
                sequence: 1,
                startDate: "2024-08-01",
                pricing: billingPricing
            )
            
            let recurringBillingDetails = BTPayPalRecurringBillingDetails(
                billingCycles: [billingCycle],
                currencyISOCode: "USD",
                totalAmount: "32.56",
                productName: "Vogue Magazine Subscription",
                productDescription: "Home delivery to Chicago, IL",
                productQuantity: 1,
                oneTimeFeeAmount: "9.99",
                shippingAmount: "1.99",
                productAmount: "19.99",
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
    
    @objc func tappedPayPalAppSwitchForCheckout(_ sender: UIButton) {
        sender.setTitle("Processing...", for: .disabled)
        sender.isEnabled = false
        
        let request = BTPayPalCheckoutRequest(
            userAuthenticationEmail: emailTextField.text,
            enablePayPalAppSwitch: true,
            amount: "10.00",
            userAction: .payNow,
            offerPayLater: payLaterToggle.isOn
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

    @objc func tappedPayPalAppSwitchForVault(_ sender: UIButton) {
        sender.setTitle("Processing...", for: .disabled)
        sender.isEnabled = false

        let request = BTPayPalVaultRequest(
            userAuthenticationEmail: emailTextField.text,
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
