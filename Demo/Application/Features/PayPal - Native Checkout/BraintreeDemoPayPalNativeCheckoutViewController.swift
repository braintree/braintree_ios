import Foundation
import UIKit
import BraintreePayPalNativeCheckout

class BraintreeDemoPayPalNativeCheckoutViewController: BraintreeDemoPaymentButtonBaseViewController {
	lazy var payPalNativeCheckoutClient = BTPayPalNativeCheckoutClient(apiClient: apiClient)

	func checkoutPaymentButton(title: String, action: Selector) -> UIButton {
		let button = UIButton(type: .system)
		button.setTitle(title, for: .normal)
		button.setTitleColor(.blue, for: .normal)
		button.setTitleColor(.lightGray, for: .highlighted)
		button.setTitleColor(.lightGray, for: .disabled)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.addTarget(self, action: action, for: .touchUpInside)
		return button
	}

	override func createPaymentButton() -> UIView! {
		let payPalCheckoutButton = checkoutPaymentButton(title: "One Time Checkout", action: #selector(tappedPayPalCheckout))

		// Buyers are shown a billing agreement without purchase
		// For more information: https://developer.paypal.com/braintree/docs/guides/paypal/vault/ios/v5
		let vaultCheckoutButton = checkoutPaymentButton(title: "Vault Checkout", action: #selector(tappedVaultCheckout))

		// Buyers are shown a billing agreement with purchase
		// For more information: https://developer.paypal.com/braintree/docs/guides/paypal/checkout-with-vault/ios/v5
		let checkoutWithVaultButton = checkoutPaymentButton(title: "Checkout With Vault", action: #selector(tappedCheckoutWithVault))

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

		let request =  BTPayPalNativeCheckoutRequest(amount: "4.30", requestBillingAgreement: true)

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
