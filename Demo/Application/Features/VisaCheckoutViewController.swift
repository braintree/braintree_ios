import UIKit
import BraintreeVisaCheckout
import VisaCheckoutSDK
import BraintreeCore

class VisaCheckoutViewController: PaymentButtonBaseViewController {

    lazy var visaCheckoutClient = BTVisaCheckoutClient(apiClient: apiClient)

    var launchHandler: LaunchHandle?

    let visaCheckoutButton = VisaCheckoutButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Visa Checkout"

        createVisaCheckoutButton()
        createVisaProfileAndCheckout()
    }

    /// Creates and displays the Visa Checkout button.
    func createVisaCheckoutButton() {

        visaCheckoutButton.style = .standard
        visaCheckoutButton.isAccessibilityElement = true
        visaCheckoutButton.accessibilityLabel = "Visa Checkout"
        visaCheckoutButton.accessibilityIdentifier = "visaCheckoutButton"
        visaCheckoutButton.accessibilityTraits.insert(.button)

        view.addSubview(visaCheckoutButton)

        NSLayoutConstraint.activate([
            visaCheckoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            visaCheckoutButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            visaCheckoutButton.widthAnchor.constraint(equalToConstant: 215),
            visaCheckoutButton.heightAnchor.constraint(equalToConstant: 45)
        ])
        visaCheckoutButton.translatesAutoresizingMaskIntoConstraints = false
    }

    /// Creates a Visa profile and initiates the checkout process.
    func createVisaProfileAndCheckout() {
        visaCheckoutClient.createProfile { profile, error in
            if let error {
                self.progressBlock("Failed to create Visa profile: \(error)")
                return
            }

            guard let profile else {
                self.progressBlock("Failed to create Visa profile")
                return
            }

            profile.displayName = "My App"

            let currencyAmount = CurrencyAmount(string: "22.09")
            let purchaseInfo = PurchaseInfo(total: currencyAmount, currency: .usd)
            purchaseInfo.shippingRequired = true

            self.visaCheckoutButton.onCheckout(
                profile: profile,
                purchaseInfo: purchaseInfo,
                presenting: self,
                onReady: { launchHandle in
                    self.launchHandler = launchHandle
                },
                onButtonTapped: {
                    guard let launchHandler = self.launchHandler else {
                        self.progressBlock("Error: launchHandler is not set.")
                        return
                    }
                    launchHandler()
                },
                completion: { result in
                    self.progressBlock("Tokenizing VisaCheckoutResult...")
                    self.visaCheckoutClient.tokenize(result) { tokenizedVisaCheckoutCard, error in
                        if let error {
                            self.progressBlock("Error tokenizing Visa Checkout card: \(error.localizedDescription)")
                        } else if let tokenizedVisaCheckoutCard {
                            let nonce = tokenizedVisaCheckoutCard.nonce
                            let shippingAddress = tokenizedVisaCheckoutCard.shippingAddress
                            self.completionBlock(tokenizedVisaCheckoutCard)
                        } else {
                            self.progressBlock("No error or nonce returned from the Visa Checkout flow.")
                        }
                    }
                }
            )
        }
    }
}
