import UIKit
import BraintreeSEPADirectDebit

class BraintreeDemoSEPADirectDebitViewController: BraintreeDemoBaseViewController {
    private let sepaDirectDebitClient: BTSEPADirectDebitClient
    private let sepaDirectDebitButton = UIButton(type: .system)
    
    override init?(authorization: String!) {
        guard let apiClient = BTAPIClient(authorization: authorization) else { return nil }
        
        sepaDirectDebitClient = BTSEPADirectDebitClient(apiClient: apiClient)

        super.init(authorization: authorization)
        
        title = "SEPA Debit"
        view.backgroundColor = UIColor(red: 250.0 / 255.0, green: 253.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
        
        sepaDirectDebitButton.setTitle("SEPA Debit", for: .normal)
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
    
    @objc func sepaDirectDebitButtonTapped() {
        self.progressBlock("Tapped SEPA Debit")

        let billingAddress = BTPostalAddress()
        billingAddress.streetAddress = "Kantstraße 70"
        billingAddress.extendedAddress = "#170"
        billingAddress.locality = "Freistaat Sachsen"
        billingAddress.region = "Annaberg-buchholz"
        billingAddress.postalCode = "09456"
        billingAddress.countryCodeAlpha2 = "FR"
        
        let sepaDirectDebitRequest = BTSEPADirectDebitRequest(
            accountHolderName: "John Doe",
            iban: generateRandomIBAN(),
            customerID: generateRandomCustomerID(),
            mandateType: .oneOff,
            billingAddress: billingAddress
        )
        
        sepaDirectDebitClient.tokenize(request: sepaDirectDebitRequest) { sepaDirectDebitNonce, error in
            self.sepaDirectDebitButton.setTitle("Processing...", for: .disabled)
            self.sepaDirectDebitButton.isEnabled = false

            if let sepaDirectDebitNonce = sepaDirectDebitNonce {
                let sepaDirectDebitNonce = sepaDirectDebitNonce as! BTPaymentMethodNonce
                self.completionBlock(sepaDirectDebitNonce)
            } else if let error = error {
                self.progressBlock(error.localizedDescription)
            } else {
                self.progressBlock("Canceled")
            }
        }
    }
    
    private func generateRandomCustomerID() -> String {
        return ""
    }
    
    private func generateRandomIBAN() -> String {
        return ""
    }
}

