import UIKit
import BraintreeCard
import BraintreeThreeDSecure

class ThreeDSecureViewController: PaymentButtonBaseViewController {

    private let cardFormView = BTCardFormView()
    private let autofillButton = UIButton(type: .system)

    var callbackCountLabel = UILabel()
    var callbackCount: Int = 0
    
    lazy var threeDSecureClient = BTThreeDSecureClient(apiClient: apiClient)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "3D Secure - Payment Flow"

        createSubviews()
        layoutConstraints()
    }

    override func createPaymentButton() -> UIView {
        let verifyNewCardButton = createButton(title: "Tokenize and Verify New Card", action: #selector(tappedToVerifyNewCard))

        callbackCountLabel.translatesAutoresizingMaskIntoConstraints = false
        callbackCountLabel.textAlignment = .center
        callbackCountLabel.font = .systemFont(ofSize: UIFont.smallSystemFontSize)

        callbackCount = 0
        updateCallbackCount()

        let stackView = UIStackView(arrangedSubviews: [verifyNewCardButton, callbackCountLabel])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false

        return stackView
    }

    @objc func tappedToVerifyNewCard() {
        callbackCount = 0
        updateCallbackCount()

        let card = CardHelpers.newCard(from: cardFormView)
        let cardClient = BTCardClient(apiClient: apiClient)

        cardClient.tokenize(card) { tokenizedCard, error in
            guard let tokenizedCard else {
                self.progressBlock(error?.localizedDescription)
                return
            }

            self.progressBlock("Tokenized card, now verifying with 3DS")
            let threeDSecureRequest = self.createThreeDSecureRequest(with: tokenizedCard.nonce)

            self.threeDSecureClient.startPaymentFlow(threeDSecureRequest) { threeDSecureResult, error in
                self.callbackCount += 1
                self.updateCallbackCount()

                guard let threeDSecureResult else {
                    if (error as? NSError)?.code == 5 {
                        self.progressBlock("Canceled 🎲")
                    } else {
                        self.progressBlock(error?.localizedDescription)
                    }
                    return
                }

                self.completionBlock(threeDSecureResult.tokenizedCard)

                let threeDSecureInfo = threeDSecureResult.tokenizedCard?.threeDSecureInfo
                if threeDSecureInfo?.liabilityShiftPossible == true && threeDSecureInfo?.liabilityShifted == true {
                    self.progressBlock("Liability shift possible and liability shifted")
                    return
                } else {
                    self.progressBlock("3D Secure authentication was attempted but liability shift is not possible")
                    return
                }
            }
        }
    }

    @objc func tappedToAutofill3DSCard() {
        cardFormView.cardNumberTextField.text = "4000000000001091"
        cardFormView.expirationTextField.text = CardHelpers.generateFuture(.date)
        cardFormView.cvvTextField.text = "123"
        cardFormView.postalCodeTextField.text = "12345"
    }

    private func createThreeDSecureRequest(with nonce: String) -> BTThreeDSecureRequest {
        let request = BTThreeDSecureRequest()
        request.threeDSecureRequestDelegate = self
        request.amount = 10.32
        request.nonce = nonce
        request.accountType = .credit
        request.requestedExemptionType = .lowValue
        request.email = "test@example.com"
        request.shippingMethod = .sameDay

        let billingAddress = BTThreeDSecurePostalAddress()
        billingAddress.givenName = "Jill"
        billingAddress.surname = "Doe"
        billingAddress.streetAddress = "555 Smith St."
        billingAddress.extendedAddress = "#5"
        billingAddress.locality = "Oakland"
        billingAddress.region = "CA"
        billingAddress.countryCodeAlpha2 = "US"
        billingAddress.postalCode = "12345"
        billingAddress.phoneNumber = "8101234567"

        request.billingAddress = billingAddress
        request.v2UICustomization = createUICustomization()

        return request
    }

    private func createUICustomization() -> BTThreeDSecureV2UICustomization {
        let toolbarCustomization = BTThreeDSecureV2ToolbarCustomization()
        toolbarCustomization.headerText = "Braintree 3DS Checkout"
        toolbarCustomization.backgroundColor = "#FF5A5F"
        toolbarCustomization.buttonText = "Close"
        toolbarCustomization.textColor = "#222222"
        toolbarCustomization.textFontSize = 18
        toolbarCustomization.textFontName = "AmericanTypewriter"

        let buttonCustomization = BTThreeDSecureV2ButtonCustomization()
        buttonCustomization.backgroundColor = "#FFC0CB"
        buttonCustomization.cornerRadius = 20

        let textBoxCustomization = BTThreeDSecureV2TextBoxCustomization()
        textBoxCustomization.borderColor = "#ADD8E6"
        textBoxCustomization.cornerRadius = 10
        textBoxCustomization.borderWidth = 5

        let labelCustomization = BTThreeDSecureV2LabelCustomization()
        labelCustomization.headingTextColor = "#A020F0"
        labelCustomization.headingTextFontSize = 24
        labelCustomization.headingTextFontName = "AmericanTypewriter"

        let uiCustomization = BTThreeDSecureV2UICustomization()
        uiCustomization.toolbarCustomization = toolbarCustomization
        uiCustomization.textBoxCustomization = textBoxCustomization
        uiCustomization.labelCustomization = labelCustomization
        uiCustomization.setButton(buttonCustomization, buttonType: .verify)

        return uiCustomization
    }

    private func updateCallbackCount() {
        callbackCountLabel.text = "Callback Count: \(callbackCount)"
    }

    private func createSubviews() {
        cardFormView.translatesAutoresizingMaskIntoConstraints = false
        cardFormView.hidePhoneNumberField = true

        autofillButton.setTitle("Autofill 3DS Card", for: .normal)
        autofillButton.setTitleColor(.blue, for: .normal)
        autofillButton.addTarget(self, action: #selector(tappedToAutofill3DSCard), for: .touchUpInside)
        autofillButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(cardFormView)
        view.addSubview(autofillButton)
    }

    private func layoutConstraints() {
        NSLayoutConstraint.activate([
            cardFormView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            cardFormView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            cardFormView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            cardFormView.heightAnchor.constraint(equalToConstant: 200),

            autofillButton.topAnchor.constraint(equalTo: cardFormView.bottomAnchor, constant: 10),
            autofillButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            autofillButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
}

// MARK: - BTThreeDSecureRequestDelegate Conformance

extension ThreeDSecureViewController: BTThreeDSecureRequestDelegate {

    func onLookupComplete(
        _ request: BTThreeDSecureRequest,
        lookupResult: BTThreeDSecureResult,
        next: @escaping () -> Void
    ) {
        // Optionally inspect the result and prepare UI if a challenge is required
        next()
    }
}
