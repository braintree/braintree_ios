import UIKit
import AuthenticationServices
import BraintreeSEPADirectDebit

class BraintreeDemoSEPADirectDebitViewController: BraintreeDemoBaseViewController, ASWebAuthenticationPresentationContextProviding {
    private let sepaDirectDebitClient: BTSEPADirectDebitClient
    private let sepaDirectDebitButton = UIButton(type: .system)
    
    override init?(authorization: String!) {
        guard let apiClient = BTAPIClient(authorization: authorization) else { return nil }
        
        sepaDirectDebitClient = BTSEPADirectDebitClient(apiClient: apiClient)

        super.init(authorization: authorization)
        
        title = "SEPA Direct Debit"
        view.backgroundColor = UIColor(red: 250.0 / 255.0, green: 253.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
        
        sepaDirectDebitButton.setTitle("SEPA Direct Debit", for: .normal)
        sepaDirectDebitButton.translatesAutoresizingMaskIntoConstraints = false
        sepaDirectDebitButton.addTarget(self, action: #selector(sepaDirectDebitButtonTapped), for: .touchUpInside)
        view.addSubview(sepaDirectDebitButton)
        
        NSLayoutConstraint.activate(
            [
                sepaDirectDebitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                sepaDirectDebitButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ]
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - ASWebAuthenticationPresentationContextProviding conformance

    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        if #available(iOS 15, *) {
            let firstScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            let window = firstScene?.windows.first { $0.isKeyWindow }
            return window ?? ASPresentationAnchor()
        } else {
            let window = UIApplication.shared.windows.first { $0.isKeyWindow }
            return window ?? ASPresentationAnchor()
        }
    }

    // MARK: - SEPA Direct Debit implementation
    
    @objc func sepaDirectDebitButtonTapped() {
        self.progressBlock("Tapped SEPA Direct Debit")

        let billingAddress = BTPostalAddress()
        billingAddress.streetAddress = "Kantstraße 70"
        billingAddress.extendedAddress = "#170"
        billingAddress.locality = "Freistaat Sachsen"
        billingAddress.region = "Annaberg-buchholz"
        billingAddress.postalCode = "09456"
        billingAddress.countryCodeAlpha2 = "FR"

        let sepaDirectDebitRequest = BTSEPADirectDebitRequest()
        sepaDirectDebitRequest.accountHolderName = "John Doe"
        sepaDirectDebitRequest.iban = "FR7630006000014829011031512"
        sepaDirectDebitRequest.customerID = generateRandomCustomerID()
        sepaDirectDebitRequest.mandateType = .oneOff
        sepaDirectDebitRequest.billingAddress = billingAddress
        sepaDirectDebitRequest.merchantAccountID = "EUR-sepa-direct-debit"

        sepaDirectDebitClient.tokenize(request: sepaDirectDebitRequest, context: self) { sepaDirectDebitNonce, error in
            if let sepaDirectDebitNonce = sepaDirectDebitNonce {
                self.completionBlock(sepaDirectDebitNonce)
            } else if let error = error {
                self.progressBlock(error.localizedDescription)
            } else {
                self.progressBlock("Canceled")
            }
        }
    }

    private func generateRandomCustomerID() -> String {
        String(UUID().uuidString.replacingOccurrences(of: "-", with: "").prefix(20))
    }
}

