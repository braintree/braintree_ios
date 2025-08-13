import UIKit
import BraintreeVisaCheckout
import VisaCheckoutSDK

#if canImport(BraintreeCore)
import BraintreeCore
#endif

class VisaCheckoutViewController: PaymentButtonBaseViewController {

    // swiftlint:disable:next implicitly_unwrapped_optional
    var visaCheckoutClient: BTVisaCheckoutClient!
    var launchHandler: LaunchHandle?
    let visaCheckoutButton = VisaCheckoutButton()

    // MARK: - Public Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        visaCheckoutClient = BTVisaCheckoutClient(apiClient: apiClient)
        title = "Visa Checkout Button"

        createVisaCheckoutButton()
        createVisaProfileAndCheckout()
    }

    /// Creates and displays the Visa Checkout button.
    func createVisaCheckoutButton() {
        visaCheckoutButton.translatesAutoresizingMaskIntoConstraints = false
        visaCheckoutButton.style = .standard
        view.addSubview(visaCheckoutButton)
        NSLayoutConstraint.activate([
            visaCheckoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            visaCheckoutButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            visaCheckoutButton.widthAnchor.constraint(equalToConstant: 215),
            visaCheckoutButton.heightAnchor.constraint(equalToConstant: 45)
        ])
    }

    /// Creates a Visa profile and initiates the checkout process.
    func createVisaProfileAndCheckout() {
        visaCheckoutClient.createProfile { profile, error in
            if let error = error {
                print("Failed to create Visa profile: \(error)")
                return
            }
            guard let profile = profile else { return }

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
                        return
                    }
                    launchHandler()
                },
                completion: { result in
                    print("Tokenizing VisaCheckoutResult...")
                    self.visaCheckoutClient.tokenize(result) { tokenizedVisaCheckoutCard, error in
                        if let error = error {
                            self.progressBlock("Error tokenizing Visa Checkout card: \(error.localizedDescription)")
                        } else if let tokenizedVisaCheckoutCard = tokenizedVisaCheckoutCard {
                            self.completionBlock(tokenizedVisaCheckoutCard)
                        } else {
                            self.progressBlock("User canceled.")
                        }
                    }
                }
            )
        }
    }
}
