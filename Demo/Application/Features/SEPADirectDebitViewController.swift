import UIKit
import AuthenticationServices
import BraintreeCore
import BraintreeSEPADirectDebit

class SEPADirectDebitViewController: PaymentButtonBaseViewController {

    lazy var sepaDirectDebitClient = BTSEPADirectDebitClient(apiClient: apiClient)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "SEPA Direct Debit"
    }

    override func createPaymentButton() -> UIView {
        let sepaDirectDebitButton = createButton(title: "SEPA Direct Debit", action: #selector(sepaDirectDebitButtonTapped))
        return sepaDirectDebitButton
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
        sepaDirectDebitRequest.iban = BTSEPADirectDebitTestHelper.generateValidSandboxIBAN()
        sepaDirectDebitRequest.customerID = generateRandomCustomerID()
        sepaDirectDebitRequest.mandateType = .oneOff
        sepaDirectDebitRequest.billingAddress = billingAddress
        sepaDirectDebitRequest.merchantAccountID = "EUR-sepa-direct-debit"

        sepaDirectDebitClient.tokenize(sepaDirectDebitRequest) { sepaDirectDebitNonce, error in
            if let sepaDirectDebitNonce {
                self.completionBlock(sepaDirectDebitNonce)
            } else if let error {
                if error as? BTSEPADirectDebitError == .webFlowCanceled {
                    self.progressBlock("Canceled")
                } else {
                    self.progressBlock(error.localizedDescription)
                }
            }
        }
    }

    private func generateRandomCustomerID() -> String {
        String(UUID().uuidString.replacingOccurrences(of: "-", with: "").prefix(20))
    }
}
