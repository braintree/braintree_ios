import Foundation
import UIKit
import BraintreePayPalNativeCheckout

class PayPalNativeCheckoutViewController: PaymentButtonBaseViewController {

	lazy var payPalNativeCheckoutClient = BTPayPalNativeCheckoutClient(apiClient: apiClient)

	override func createPaymentButton() -> UIView {
		let payPalCheckoutButton = createButton(title: "One Time Checkout", action: #selector(tappedPayPalCheckout))

		// Buyers are shown a billing agreement without purchase
		// For more information: https://developer.paypal.com/braintree/docs/guides/paypal/vault/ios/v6
		let vaultCheckoutButton = createButton(title: "Vault Checkout", action: #selector(tappedVaultCheckout))

		// Buyers are shown a billing agreement with purchase
		// For more information: https://developer.paypal.com/braintree/docs/guides/paypal/checkout-with-vault/ios/v6
		let checkoutWithVaultButton = createButton(title: "Checkout With Vault", action: #selector(tappedCheckoutWithVault))

		let stackView = UIStackView(arrangedSubviews: [payPalCheckoutButton, vaultCheckoutButton, checkoutWithVaultButton])
		stackView.axis = .vertical
		stackView.alignment = .center
		stackView.distribution = .fillEqually
		stackView.translatesAutoresizingMaskIntoConstraints = false
		return stackView
	}

	@objc func tappedPayPalCheckout(_ sender: UIButton) {
		progressBlock("Tapped PayPal - Native Checkout using BTPayPalNativeCheckout")
		sender.setTitle("Processing...", for: .disabled)
		sender.isEnabled = false

		let request = BTPayPalNativeCheckoutRequest(amount: "4.30")
		payPalNativeCheckoutClient.tokenize(request) { nonce, error in
			sender.isEnabled = true

			guard let nonce else {
				self.progressBlock(error?.localizedDescription)
				return
			}
			self.completionBlock(nonce)
		}
	}

	@objc func tappedVaultCheckout(_ sender: UIButton) {
		progressBlock("Tapped PayPal - Vault using BTPayPalNativeCheckout")
		sender.setTitle("Processing...", for: .disabled)
		sender.isEnabled = false

		let request = BTPayPalNativeVaultRequest()

		payPalNativeCheckoutClient.tokenize(request) { nonce, error in
			sender.isEnabled = true

			guard let nonce else {
				self.progressBlock(error?.localizedDescription)
				return
			}
			self.completionBlock(nonce)
		}
	}

	@objc func tappedCheckoutWithVault(_ sender: UIButton) {
		progressBlock("Tapped PayPal - Checkout With Vault using BTPayPalNativeCheckout")
		sender.setTitle("Processing...", for: .disabled)
		sender.isEnabled = false

		let request = BTPayPalNativeCheckoutRequest(amount: "4.30", requestBillingAgreement: true)

		payPalNativeCheckoutClient.tokenize(request) { nonce, error in
			sender.isEnabled = true

			guard let nonce else {
				self.progressBlock(error?.localizedDescription)
				return
			}
			self.completionBlock(nonce)
		}
	}
}
