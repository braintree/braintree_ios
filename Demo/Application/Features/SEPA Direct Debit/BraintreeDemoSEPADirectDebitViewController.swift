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
        sepaDirectDebitRequest.iban = generateRandomIBAN()
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

    // MARK: - Helper functions for IBAN generation

    private func generateRandomIBAN() -> String {
        let countryCode: String = "FR"
        let bankCode: String = "30006"
        let branchCode: String = "00001"
        let accountNumber = Int.random(in: 10_000_000_000...100_000_000_000)

        let accountNumberWithChecksum = accountNumberWithChecksum(bankCode: Int(bankCode) ?? 0, branchCode: Int(branchCode) ?? 0, accountNumber: accountNumber)
        let checksum = checksum(bankCode: bankCode, branchCode: branchCode, accountNumber: Int(accountNumberWithChecksum) ?? 0)

        return countryCode + "\(checksum)\(bankCode)\(branchCode)\(accountNumberWithChecksum)"
    }

    private func accountNumberWithChecksum(bankCode: Int, branchCode: Int, accountNumber: Int) -> String {
        let sum: Int = 89 * bankCode + 15 * branchCode + 3 * accountNumber
        let checksum = 97 - calculateMod97(from: sum)

        return "\(accountNumber)\(checksum)"
    }

    private func checksum(bankCode: String, branchCode: String, accountNumber: Int) -> String {
        // 152700 is taken from the conversion table here: https://community.appway.com/screen/kb/article/generating-and-validating-an-iban-1683400256881#conversion-table
        // and is representative of the characters "FR" with 00 being added to the end for all bban's to calculate the checksum
        let bbanString: String = bankCode + branchCode + "\(accountNumber)" + "152700"
        let modResult = (Decimal(string: bbanString) ?? 0) % 97
        let result = 98 - modResult
        return "\(result)"
    }

    private func calculateMod97(from accountNumber: Int) -> Int {
        var mod: Int = 0
        let accountNumberArray = String(accountNumber).map { String($0) }

        for digit in accountNumberArray {
            mod = ((mod * 10) + (Int(digit) ?? 0)) % 97
        }

        return mod
    }
}

// We need this to calculate the mod result on a large integer since Int cannot handle the calculation of an number of this size
public extension Decimal {
    // Allows us to divide by a large integer for use in calculating a checksum
    static func % (lhs: Decimal, rhs: Decimal) -> Decimal {
        precondition(lhs > 0 && rhs > 0)

        if lhs < rhs {
            return lhs
        } else if lhs == rhs {
            return 0
        }

        var quotient = lhs / rhs
        var rounded = Decimal()
        NSDecimalRound(&rounded, &quotient, 0, .down)

        return lhs - (rounded * rhs)
    }
}
