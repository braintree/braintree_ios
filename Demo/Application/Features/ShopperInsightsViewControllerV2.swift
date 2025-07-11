import UIKit
import BraintreeCore
import BraintreePayPal
import BraintreeVenmo
import BraintreeShopperInsights
import CryptoKit

class ShopperInsightsViewControllerV2: PaymentButtonBaseViewController {
    
    lazy var shopperInsightsClient = BTShopperInsightsClientV2(apiClient: apiClient)
    lazy var payPalClient = BTPayPalClient(apiClient: apiClient)
    lazy var venmoClient = BTVenmoClient(apiClient: apiClient)
    
    lazy var payPalVaultButton = createButton(title: "PayPal Vault", action: #selector(payPalVaultButtonTapped))
    lazy var venmoButton = createButton(title: "Venmo", action: #selector(venmoButtonTapped))
    
    private var shopperSessionID = "test-shopper-session-id"
    
    lazy var emailView: TextFieldWithLabel = {
        let view = TextFieldWithLabel()
        view.label.text = "Email"
        view.textField.placeholder = "Email"
        view.textField.text = "PR1_merchantname@personal.example.com"
        return view
    }()
    
    lazy var countryCodeView: TextFieldWithLabel = {
        let view = TextFieldWithLabel()
        view.label.text = "Country Code"
        view.textField.placeholder = "Country Code"
        view.textField.text = "1"
        return view
    }()
    
    lazy var nationalNumberView: TextFieldWithLabel = {
        let view = TextFieldWithLabel()
        view.label.text = "National Number"
        view.textField.placeholder = "National Number"
        view.textField.text = "4082321001"
        return view
    }()
    
    lazy var shopperInsightsButton = createButton(title: "Fetch Shopper Insights", action: #selector(shopperInsightsButtonTapped))
    
    lazy var createCustomerSessionButton = createButton(
        title: "Create Customer Session Button",
        action: #selector(createCustomerSessionButtonTapped)
    )
    
    lazy var updateCustomerSessionButton = createButton(
        title: "Update Customer Session Button",
        action: #selector(updateCustomerSessionButtonTapped)
    )
    
    lazy var getCustomerRecommendationsButton = createButton(
        title: "Get Customer Recommendations Button",
        action: #selector(getCustomerRecommendationsButtonTapped)
    )
    
    lazy var shopperInsightsInputView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [emailView, countryCodeView, nationalNumberView])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        createSubviews()
        layoutConstraints()
    }
    
    override func createPaymentButton() -> UIView {
        let buttons = [createCustomerSessionButton, updateCustomerSessionButton, getCustomerRecommendationsButton, shopperInsightsButton, payPalVaultButton, venmoButton]
        shopperInsightsButton.isEnabled = true
        payPalVaultButton.isEnabled = false
        venmoButton.isEnabled = false

        let stackView = UIStackView(arrangedSubviews: buttons)
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }
    
    @objc func shopperInsightsButtonTapped(_ button: UIButton) {
        self.progressBlock("Fetching shopper insights...")
        
        let request = BTCustomerSessionRequest(hashedEmail: emailView.textField.text ?? "")
        
        
//        (
//            email: emailView.textField.text ?? "",
//            phone: Phone(
//                countryCode: countryCodeView.textField.text ?? "",
//                nationalNumber: nationalNumberView.textField.text ?? ""
//            )
//        )
//        Task {
//            do {
//                let result = try await shopperInsightsClient.generateCustomerRecommendations(
//                    request: request,
//                    sessionID: "94f0b2db-5323-4d86-add3-paypal000000"
//                )
//
//                // swiftlint:disable:next line_length
//                progressBlock("PayPal Recommended: \(result.isPayPalRecommended)\nVenmo Recommended: \(result.isVenmoRecommended)\nEligible in PayPal Network: \(result.isEligibleInPayPalNetwork)")
//                
//                togglePayPalVaultButton(enabled: result.isPayPalRecommended)
//                toggleVenmoButton(enabled: result.isVenmoRecommended)
//            } catch {
//                progressBlock("Error: \(error.localizedDescription)")
//            }
//        }
    }
    
    @objc func createCustomerSessionButtonTapped(_ button: UIButton) {
        Task {
            self.progressBlock("Create Customer Session...")

            let request = BTCustomerSessionRequest(
                hashedEmail: sha256Hash("test@example.com"),
                hashedPhoneNumber: sha256Hash("5551234567"),
                payPalAppInstalled: true,
                venmoAppInstalled: false,
                purchaseUnits: [
                    BTPurchaseUnit(amount: "42.00", currencyCode: "USD")
                ]
            )

            do {
                let result = try await shopperInsightsClient.createCustomerSession(request: request)
                print("Customer session created: \(result)")
            } catch {
                print("Failed to create customer session: \(error.localizedDescription)")
            }
        }
    }
    
    @objc func updateCustomerSessionButtonTapped(_ button: UIButton) {
        self.progressBlock("Update Customer Session...")

        let request = BTCustomerSessionRequest(
            hashedEmail: sha256Hash("test@example.com"),
            hashedPhoneNumber: sha256Hash("5551234567"),
            payPalAppInstalled: true,
            venmoAppInstalled: false,
            purchaseUnits: [
                BTPurchaseUnit(amount: "42.00", currencyCode: "USD")
            ]
        )

        Task {
            do {
                let result = try await shopperInsightsClient.updateCustomerSession(request: request, sessionID: shopperSessionID)
                print("Customer session created: \(result)")
            } catch {
                print("Failed to create customer session: \(error.localizedDescription)")
            }
        }
    }
    
    @objc func getCustomerRecommendationsButtonTapped(_ button: UIButton) {
        self.progressBlock("Get Customer Recommendations...")

    }
    
    private func sha256Hash(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.map { String(format: "%02x", $0) }.joined()
    }
    
    private func togglePayPalVaultButton(enabled: Bool) {
        payPalVaultButton.isEnabled = enabled
        
        guard enabled else { return }
        
        let presentmentDetails = BTPresentmentDetails(
            buttonOrder: .first,
            experimentType: .control,
            pageType: .about
        )
        
        shopperInsightsClient.sendPresentedEvent(
            for: .payPal,
            presentmentDetails: presentmentDetails,
            sessionID: shopperSessionID
        )
    }
    
    private func toggleVenmoButton(enabled: Bool) {
        venmoButton.isEnabled = enabled
        
        guard enabled else { return }
        
        let presentmentDetails = BTPresentmentDetails(
            buttonOrder: .second,
            experimentType: .control,
            pageType: .about
        )
        
        shopperInsightsClient.sendPresentedEvent(
            for: .venmo,
            presentmentDetails: presentmentDetails,
            sessionID: shopperSessionID
        )
    }
    
    @objc func payPalVaultButtonTapped(_ button: UIButton) {
        progressBlock("Tapped PayPal Vault")
        shopperInsightsClient.sendSelectedEvent(for: .payPal, sessionID: shopperSessionID)
        
        button.setTitle("Processing...", for: .disabled)
        button.isEnabled = false
        
        let paypalRequest = BTPayPalVaultRequest()
        paypalRequest.shopperSessionID = shopperSessionID
        paypalRequest.userAuthenticationEmail = emailView.textField.text
        
        payPalClient.tokenize(paypalRequest) { nonce, error in
            button.isEnabled = true
            self.displayResultDetails(nonce: nonce, error: error)
        }
    }
    
    @objc func venmoButtonTapped(_ button: UIButton) {
        progressBlock("Tapped Venmo")
        shopperInsightsClient.sendSelectedEvent(for: .venmo, sessionID: shopperSessionID)
        
        button.setTitle("Processing...", for: .disabled)
        button.isEnabled = false

        let venmoRequest = BTVenmoRequest(paymentMethodUsage: .multiUse)
        venmoClient.tokenize(venmoRequest) { nonce, error in
            button.isEnabled = true
            self.displayResultDetails(nonce: nonce, error: error)
        }
    }
    
    private func displayResultDetails(nonce: BTPaymentMethodNonce?, error: Error?) {
        if let error {
            progressBlock(error.localizedDescription)
        } else if let nonce {
            completionBlock(nonce)
        } else {
            progressBlock("Canceled")
        }
    }

    private func createSubviews() {
        shopperInsightsInputView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(shopperInsightsInputView)
    }

    private func layoutConstraints() {
        NSLayoutConstraint.activate(
            [
                shopperInsightsInputView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                shopperInsightsInputView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
                shopperInsightsInputView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
                shopperInsightsInputView.heightAnchor.constraint(equalToConstant: 200)
            ]
        )
    }
}
