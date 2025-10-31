import UIKit
import BraintreeLocalPayment
import BraintreeCore

class IdealViewController: PaymentButtonBaseViewController {

    // swiftlint:disable:next implicitly_unwrapped_optional
    var localPaymentClient: BTLocalPaymentClient!
    var paymentIDLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()

        progressBlock("Loading iDEAL Merchant Account...")
        progressBlock("Ready!")
        title = "iDEAL"
    }

    override func createPaymentButton() -> UIView {
        let iDEALButton = createButton(title: "Pay with iDEAL", action: #selector(tappedIDEAL))
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false

        self.paymentIDLabel = label

        let stackView = UIStackView(arrangedSubviews: [iDEALButton, label])
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            iDEALButton.topAnchor.constraint(equalTo: stackView.topAnchor),
            iDEALButton.heightAnchor.constraint(equalToConstant: 19.5),

            label.topAnchor.constraint(equalTo: iDEALButton.bottomAnchor, constant: 5),
            label.heightAnchor.constraint(equalToConstant: 19.5)
        ])

        return stackView
    }

    @objc func tappedIDEAL() {
        paymentIDLabel.text = nil
        startPaymentWithBank()
    }

    private func startPaymentWithBank() {
        localPaymentClient = BTLocalPaymentClient(authorization: "sandbox_f252zhq7_hh4cpc39zq4rgjcg")

        let postalAddress = BTPostalAddress(
            streetAddress: "836486 of 22321 Park Lake",
            locality: "Den Haag",
            countryCodeAlpha2: "NL",
            postalCode: "2585 GJ"
        )
        
        let request = BTLocalPaymentRequest(
            paymentType: "ideal",
            amount: "1.01",
            currencyCode: "EUR",
            paymentTypeCountryCode: "NL",
            address: postalAddress,
            email: "lingo-buyer@paypal.com",
            givenName: "Linh",
            surname: "Ngo",
            phone: "639847934"
        )
        request.localPaymentFlowDelegate = self

        localPaymentClient.start(request) { result, error in
            guard let result else {
                if error as? BTLocalPaymentError == .canceled("") {
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

extension IdealViewController: BTLocalPaymentRequestDelegate {

    func localPaymentStarted(
        _ request: BraintreeLocalPayment.BTLocalPaymentRequest,
        paymentID: String,
        start: @escaping () -> Void
    ) {
        paymentIDLabel.text = "LocalPayment ID: \(paymentID)"
        start()
    }
}
