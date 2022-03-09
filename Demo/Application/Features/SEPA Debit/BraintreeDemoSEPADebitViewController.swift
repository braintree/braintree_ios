import UIKit
import BraintreeSEPADebit

class BraintreeDemoSEPADebitViewController: BraintreeDemoBaseViewController {
    private let sepaDebitClient: BTSEPADebitClient
    private let sepaDebitButton = UIButton(type: .system)
    
    override init?(authorization: String!) {
        guard let apiClient = BTAPIClient(authorization: authorization) else { return nil }
        
        sepaDebitClient = BTSEPADebitClient(apiClient: apiClient)

        super.init(authorization: authorization)
        
        title = "SEPA Debit"
        view.backgroundColor = UIColor(red: 250.0 / 255.0, green: 253.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
        
        sepaDebitButton.setTitle("SEPA Debit", for: .normal)
        sepaDebitButton.translatesAutoresizingMaskIntoConstraints = false
        sepaDebitButton.addTarget(self, action: #selector(preferredPaymentMethodsButtonTapped), for: .touchUpInside)
        view.addSubview(sepaDebitButton)
        
        NSLayoutConstraint.activate(
            [
                sepaDebitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                sepaDebitButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ]
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func preferredPaymentMethodsButtonTapped() {
        let billingAddress = BTPostalAddress()
        billingAddress.streetAddress = "Kantstraße 70"
        billingAddress.extendedAddress = "#170"
        billingAddress.locality = "Freistaat Sachsen"
        billingAddress.region = "Annaberg-buchholz"
        billingAddress.postalCode = "09456"
        billingAddress.countryCodeAlpha2 = "FR"
        
        let sepaDebitRequest = BTSEPADebitRequest(
            accountHolderName: "John Doe",
            customerID: generateRandomCustomerID(),
            iban: generateRandomIBAN(),
            mandateType: .oneOff,
            billingAddress: billingAddress
        )
        
        sepaDebitClient.tokenize(request: sepaDebitRequest) { sepaDebitNonce, error in
            self.progressBlock("Tapped SEPA Debit")
            
            self.sepaDebitButton.setTitle("Processing...", for: .disabled)
            self.sepaDebitButton.isEnabled = false

            if let sepaDebitNonce = sepaDebitNonce {
                sepaDebitNonce as BTPaymentMethodNonce
                self.completionBlock(sepaDebitNonce)
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

