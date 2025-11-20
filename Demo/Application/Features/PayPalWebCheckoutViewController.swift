import Foundation
import UIKit
import BraintreePayPal
import BraintreeCore

// swiftlint:disable type_body_length
class PayPalWebCheckoutViewController: PaymentButtonBaseViewController {

    lazy var payPalClient = BTPayPalClient(
        authorization: authorization,
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
    
    let rbaDataToggle = Toggle(title: "Recurring Billing (RBA) Data")
    let contactInformationToggle = Toggle(title: "Add Contact Information")
    let amountBreakdownToggle = Toggle(title: "Amount Breakdown")

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
        
        let payPalAppSwitchForCreditButton = createButton(
            title: "PayPal Credit",
            action: #selector(tappedPayPalAppSwitchForCredit)
        )
        
        let payPalAppSwitchForVaultButton = createButton(
            title: "PayPal App Switch - Vault",
            action: #selector(tappedPayPalAppSwitchForVault)
        )
        
        let payPalAppSwitchForCheckoutPayLaterButton = createButton(
            title: "Pay Later App Switch - Checkout",
            action: #selector(tappedPayLaterForCheckout)
        )

        let oneTimeCheckoutStackView = buttonsStackView(label: "1-Time Checkout", views: [
            contactInformationToggle,
            amountBreakdownToggle,
            payPalCheckoutButton,
            payPalAppSwitchForCheckoutButton,
            payPalAppSwitchForCheckoutPayLaterButton,
            payPalAppSwitchForCreditButton
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

    // swiftlint:disable function_body_length
    @objc func tappedPayPalCheckout(_ sender: UIButton) {
        progressBlock("Tapped PayPal - Checkout using BTPayPalClient")
        sender.setTitle("Processing...", for: .disabled)
        sender.isEnabled = false
        
        var lineItem = BTPayPalLineItem(
            quantity: "1",
            unitAmount: "5.00",
            name: "item one 1234567",
            kind: .debit,
            imageURL: URL(string: "https://www.example.com/example.jpg"),
            upcCode: "123456789",
            upcType: .UPC_A
        )

        let contactInformation = BTContactInformation(
            recipientEmail: "some@email.com",
            recipientPhoneNumber: .init(countryCode: "52", nationalNumber: "123456789")
        )
        
        let amount = "5.00"
        var request = BTPayPalCheckoutRequest(
            amount: amount,
            contactInformation: contactInformationToggle.isOn ? contactInformation : nil,
            contactPreference: .updateContactInformation,
            lineItems: [lineItem],
            userAuthenticationEmail: emailTextField.text,
            userPhoneNumber: BTPayPalPhoneNumber(
                countryCode: countryCodeTextField.text ?? "",
                nationalNumber: nationalNumberTextField.text ?? ""
            )
        )

        if amountBreakdownToggle.isOn {
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

            let amountBreakdown = BTAmountBreakdown(
                itemTotal: "9.99",
                taxTotal: "0.50",
                shippingTotal: "0.50"
            )

            let recurringBillingDetails = BTPayPalRecurringBillingDetails(
                billingCycles: [billingCycle],
                currencyISOCode: "USD",
                totalAmount: "9.99",
                productName: "Vogue Magazine",
                productDescription: "Home delivery to Chicago, IL",
                productQuantity: 1,
                oneTimeFeeAmount: "9.99"
            )

            lineItem = BTPayPalLineItem(quantity: "1", unitAmount: "20.98", name: "Subscription Setup + First Cycle", kind: .credit)

            request = BTPayPalCheckoutRequest(
                amount: "10.99",
                amountBreakdown: amountBreakdown,
                lineItems: [lineItem],
                merchantAccountID: "quantumleapsandboxtesting-1",
                recurringBillingDetails: recurringBillingDetails,
                recurringBillingPlanType: .subscription,
                requestBillingAgreement: true
            )
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

        var request = BTPayPalVaultRequest(
            userAuthenticationEmail: emailTextField.text,
            userPhoneNumber: BTPayPalPhoneNumber(
                countryCode: countryCodeTextField.text ?? "",
                nationalNumber: nationalNumberTextField.text ?? ""
            )
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
        
        let amount = "10.00"
        let request = BTPayPalCheckoutRequest(
            amount: amount,
            enablePayPalAppSwitch: true,
            userAuthenticationEmail: emailTextField.text,
            userAction: .payNow
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

    @objc func tappedPayPalAppSwitchForCredit(_ sender: UIButton) {
        sender.setTitle("Processing...", for: .disabled)
        sender.isEnabled = false

        let request = BTPayPalCheckoutRequest(
            amount: "10.00",
            enablePayPalAppSwitch: true,
            userAuthenticationEmail: emailTextField.text,
            userAction: .payNow,
            offerCredit: true
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
            enablePayPalAppSwitch: true,
            userAuthenticationEmail: emailTextField.text
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
    
    @objc func tappedPayLaterForCheckout(_ sender: UIButton) {
        sender.setTitle("Processing...", for: .disabled)
        sender.isEnabled = false
        
        let amount = "35.00"
        let request = BTPayPalCheckoutRequest(
            amount: amount,
            enablePayPalAppSwitch: true,
            userAuthenticationEmail: emailTextField.text,
            userAction: .payNow,
            offerPayLater: true
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
}
