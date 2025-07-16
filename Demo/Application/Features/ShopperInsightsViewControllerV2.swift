import UIKit
import BraintreeCore
import BraintreePayPal
import BraintreeVenmo
import BraintreeShopperInsights
import CryptoKit

// swiftlint:disable:next type_body_length
class ShopperInsightsViewControllerV2: PaymentButtonBaseViewController {
    
    lazy var shopperInsightsClient = BTShopperInsightsClientV2(apiClient: apiClient)
    lazy var payPalClient = BTPayPalClient(apiClient: apiClient)
    lazy var venmoClient = BTVenmoClient(apiClient: apiClient)
    
    lazy var payPalVaultButton = createButton(title: "PayPal Vault", action: #selector(payPalVaultButtonTapped))
    lazy var venmoButton = createButton(title: "Venmo", action: #selector(venmoButtonTapped))
    
    lazy var paymentOptions: [BTPaymentOptions]? = nil
    
    lazy var emailView: TextFieldWithLabel = {
        let view = TextFieldWithLabel()
        view.label.text = "Email"
        view.textField.placeholder = "Email"
        view.textField.text = "sandbox1@pp.com"
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
        view.textField.text = "4085005005"
        return view
    }()
    
    lazy var sessionIDView: TextFieldWithLabel = {
        let view = TextFieldWithLabel()
        view.label.text = "SessionID"
        view.textField.placeholder = "SessionID"
        view.textField.text = "94f0b2db-5323-4d86-add3-paypalmsg000"
        return view
    }()
    
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
        let stackView = UIStackView(arrangedSubviews: [emailView, countryCodeView, nationalNumberView, sessionIDView])
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
        let buttons = [
            createCustomerSessionButton,
            updateCustomerSessionButton,
            getCustomerRecommendationsButton,
            payPalVaultButton,
            venmoButton
        ]

        payPalVaultButton.isEnabled = false
        venmoButton.isEnabled = false

        let stackView = UIStackView(arrangedSubviews: buttons)
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }
    
    @objc func createCustomerSessionButtonTapped(_ button: UIButton) {
        Task {
            self.progressBlock("Create Customer Session...")

            let request = BTCustomerSessionRequest(
                hashedEmail: sha256Hash(emailView.textField.text ?? ""),
                hashedPhoneNumber: sha256Hash(nationalNumberView.textField.text ?? ""),
                payPalAppInstalled: shopperInsightsClient.isPayPalAppInstalled(),
                venmoAppInstalled: shopperInsightsClient.isVenmoAppInstalled(),
                purchaseUnits: [
                    BTPurchaseUnit(amount: "42.00", currencyCode: "USD")
                ]
            )

            do {
                let sessionID = try await shopperInsightsClient.createCustomerSession(request: request)
                sessionIDView.textField.text = sessionID
                self.progressBlock("SessionID: \(String(describing: sessionID))")
            } catch {
                self.progressBlock("Error: \(error.localizedDescription))")
            }
        }
    }

    @objc func updateCustomerSessionButtonTapped(_ button: UIButton) {
        self.progressBlock("Update Customer Session...")

        let request = BTCustomerSessionRequest(
            hashedEmail: sha256Hash(emailView.textField.text ?? ""),
            hashedPhoneNumber: sha256Hash(nationalNumberView.textField.text ?? ""),
            payPalAppInstalled: shopperInsightsClient.isPayPalAppInstalled(),
            venmoAppInstalled: shopperInsightsClient.isVenmoAppInstalled(),
            purchaseUnits: [
                BTPurchaseUnit(amount: "42.00", currencyCode: "USD")
            ]
        )

        Task {
            do {
                let sessionID = try await shopperInsightsClient.updateCustomerSession(
                    request: request,
                    sessionID: sessionIDView.textField.text ?? ""
                )
                
                sessionIDView.textField.text = sessionID
                self.progressBlock("SessionID: \(String(describing: sessionID))")
                
                self.progressBlock("SessionID: \(String(describing: sessionID))")
            } catch {
                self.progressBlock("Error: \(error.localizedDescription))")
            }
        }
    }
    
    @objc func getCustomerRecommendationsButtonTapped(_ button: UIButton) {
        self.progressBlock("Get Customer Recommendations...")
        
        let request = BTCustomerSessionRequest(
            hashedEmail: sha256Hash(emailView.textField.text ?? ""),
            hashedPhoneNumber: sha256Hash(nationalNumberView.textField.text ?? ""),
            payPalAppInstalled: shopperInsightsClient.isPayPalAppInstalled(),
            venmoAppInstalled: shopperInsightsClient.isVenmoAppInstalled(),
            purchaseUnits: [
                BTPurchaseUnit(amount: "42.00", currencyCode: "USD")
            ]
        )

        Task {
            do {
                let result = try await shopperInsightsClient.generateCustomerRecommendations(
                    request: request,
                    sessionID: sessionIDView.textField.text
                )
                
                self.paymentOptions = result.paymentRecommendations
                
                if let recommendations = result.paymentRecommendations {
                    if let payPalOption = recommendations.first(where: { $0.paymentOption.uppercased() == "PAYPAL" }) {
                        togglePayPalVaultButton(enabled: true)
                    }

                    if let venmoOption = recommendations.first(where: { $0.paymentOption.uppercased() == "VENMO" }) {
                        toggleVenmoButton(enabled: true)
                    }
                }

                sessionIDView.textField.text = result.sessionID
                
                self.progressBlock(
                    """
                    SessionID: \(String(describing: result.sessionID))
                    InPayPalNetwork: \(result.isInPayPalNetwork?.description ?? "nil")
                    PaymentRecommendations:
                    \(result.paymentRecommendations?.map {
                        "- Option: \($0.paymentOption), Priority: \($0.recommendedPriority)"
                    }.joined(separator: "\n") ?? "nil")
                    """
                )
            } catch {
                self.progressBlock("Error: \(error.localizedDescription))")
            }
        }
    }
    
    private func mapPriorityToButtonOrder(_ priority: Int) -> BTButtonOrder {
        switch priority {
        case 0: return .first
        case 1: return .second
        case 2: return .third
        case 3: return .fourth
        default: return .other
        }
    }

    
    private func sha256Hash(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.map { String(format: "%02x", $0) }.joined()
    }
    
    private func togglePayPalVaultButton(enabled: Bool) {
        payPalVaultButton.isEnabled = enabled
        
        guard enabled else { return }
        
        if let payPalOption = self.paymentOptions?
            .filter({ $0.paymentOption.uppercased() == "PAYPAL" })
            .sorted(by: { $0.recommendedPriority < $1.recommendedPriority })
            .first {

            let presentmentDetails = BTPresentmentDetails(
                buttonOrder: mapPriorityToButtonOrder(payPalOption.recommendedPriority),
                experimentType: .control,
                pageType: .about
            )

            shopperInsightsClient.sendPresentedEvent(
                for: .payPal,
                presentmentDetails: presentmentDetails,
                sessionID: sessionIDView.textField.text ?? ""
            )
        }
    }
    
    private func toggleVenmoButton(enabled: Bool) {
        venmoButton.isEnabled = enabled
        
        guard enabled else { return }
        
        if let venmoOption = self.paymentOptions?
            .filter({ $0.paymentOption.uppercased() == "VENMO" })
            .sorted(by: { $0.recommendedPriority < $1.recommendedPriority })
            .first {

            let presentmentDetails = BTPresentmentDetails(
                buttonOrder: mapPriorityToButtonOrder(venmoOption.recommendedPriority),
                experimentType: .control,
                pageType: .about
            )

            shopperInsightsClient.sendPresentedEvent(
                for: .payPal,
                presentmentDetails: presentmentDetails,
                sessionID: sessionIDView.textField.text ?? ""
            )
        }
    }
    
    @objc func payPalVaultButtonTapped(_ button: UIButton) {
        progressBlock("Tapped PayPal Vault")
        
        if let sessionID = sessionIDView.textField.text {
            shopperInsightsClient.sendSelectedEvent(for: .payPal, sessionID: sessionID)
        }
        
        button.setTitle("Processing...", for: .disabled)
        button.isEnabled = false
        
        let paypalRequest = BTPayPalVaultRequest()
        paypalRequest.shopperSessionID = "94f0b2db-5323-4d86-add3-paypalmsg000"
        paypalRequest.userAuthenticationEmail = emailView.textField.text
        
        payPalClient.tokenize(paypalRequest) { nonce, error in
            button.isEnabled = true
            self.displayResultDetails(nonce: nonce, error: error)
        }
    }
    
    @objc func venmoButtonTapped(_ button: UIButton) {
        progressBlock("Tapped Venmo")

        if let sessionID = sessionIDView.textField.text {
            shopperInsightsClient.sendSelectedEvent(for: .venmo, sessionID: sessionID)
        }

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
