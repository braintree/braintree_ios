import UIKit
import BraintreePayPal

class BraintreeDemoPayPalVaultViewController: BraintreeDemoPaymentButtonBaseViewController {
    
    private lazy var paypalClient = BTPayPalClient(apiClient: apiClient)
    
    override func createPaymentButton() -> UIView! {
        lazy var payPalVaultButton: UIButton = {
            let payPalVaultButton = UIButton(type: .system)
            payPalVaultButton.setTitle("PayPal Vault", for: .normal)
            payPalVaultButton.setTitleColor(.blue, for: .normal)
            payPalVaultButton.setTitleColor(.lightGray, for: .highlighted)
            payPalVaultButton.setTitleColor(.lightGray, for: .disabled)
            payPalVaultButton.addTarget(self, action: #selector(tappedPayPalVault), for: .touchUpInside)
            return payPalVaultButton
        }()
        
        return payPalVaultButton
    }
    
    @objc func tappedPayPalVault(_ sender: UIButton) {
        progressBlock("Tapped PayPal - Vault using BTPayPalClient")
        sender.setTitle("Processing...", for: .disabled)
        sender.isEnabled = false
        
        let request = BTPayPalVaultRequest()
        
        paypalClient.tokenize(request) { nonce, error in
            sender.isEnabled = true
            
            guard let nonce = nonce else {
                self.progressBlock(error?.localizedDescription)
                return
            }
            self.nonceStringCompletionBlock(nonce.nonce)
        }
    }
}
