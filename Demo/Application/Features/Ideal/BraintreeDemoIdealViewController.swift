import Foundation
import BraintreeLocalPayment
import BraintreeCore

class BraintreeDemoIdealViewController: BraintreeDemoPaymentButtonBaseViewController {

    var localPaymentClient: BTLocalPaymentClient!
    var paymentIDLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        progressBlock("Loading iDEAL Merchant Account...")
        paymentButton.isHidden = false
        setUpPaymentIDField()
        progressBlock("Ready!")
        title = "iDEAL"
    }

    override func createPaymentButton() -> UIView! {
        var button = UIButton(type: .custom)
        button.setTitle("Pay with iDEAL", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.setTitleColor(.lightGray, for: .highlighted)
        button.setTitleColor(.lightGray, for: .disabled)
        button.addTarget(self, action: #selector(iDEALButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    @objc func iDEALButtonTapped() {
        paymentIDLabel.text = nil
        startPaymentWithBank()
    }

    private func setUpPaymentIDField() {
        var paymentIDLabel = UILabel()
        paymentIDLabel.numberOfLines = 0
        paymentIDLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(paymentIDLabel)

        NSLayoutConstraint.activate([
            paymentIDLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 8),
            paymentIDLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: 8),
            paymentIDLabel.topAnchor.constraint(equalTo: paymentButton.bottomAnchor, constant: 8),
            paymentIDLabel.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: 8)
        ])

        self.paymentIDLabel = paymentIDLabel
    }

    private func startPaymentWithBank() {
        let apiClient = BTAPIClient(authorization: "sandbox_f252zhq7_hh4cpc39zq4rgjcg")!
        localPaymentClient = BTLocalPaymentClient(apiClient: apiClient)

        var request = BTLocalPaymentRequest()
        request.paymentType = "ideal"
        request.paymentTypeCountryCode = "NL"
        request.currencyCode = "EUR"
        request.amount = "1.01"
        request.givenName = "Linh"
        request.surname = "Ngo"
        request.phone = "639847934"
        request.email = "lingo-buyer@paypal.com"
        request.isShippingAddressRequired = false

        var postalAddress = BTPostalAddress()
        postalAddress.countryCodeAlpha2 = "NL"
        postalAddress.postalCode = "2585 GJ"
        postalAddress.streetAddress = "836486 of 22321 Park Lake"
        postalAddress.locality = "Den Haag"

        request.address = postalAddress
        request.localPaymentFlowDelegate = self

        localPaymentClient.startPaymentFlow(request) { result, error in
            guard let result else {
                if (error as? NSError)?.code == 5 {
                    self.progressBlock("Canceled 🎲")
                } else {
                    self.progressBlock("Error: \(error?.localizedDescription ?? "")")
                }
                return
            }

            let nonce = BTPaymentMethodNonce(nonce: result.nonce)
            self.completionBlock(nonce)
        }
    }
}

// MARK: - BTLocalPaymentRequestDelegate Conformance

extension BraintreeDemoIdealViewController: BTLocalPaymentRequestDelegate {

    func localPaymentStarted(_ request: BraintreeLocalPayment.BTLocalPaymentRequest, paymentID: String, start: @escaping () -> Void) {
        paymentIDLabel.text = "LocalPayment ID: \(paymentID)"
        start()
    }
}
