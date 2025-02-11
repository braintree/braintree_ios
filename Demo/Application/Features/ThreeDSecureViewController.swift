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

        guard let card = CardHelpers.newCard(from: cardFormView) else {
            progressBlock("Fill in all the card fields.")
            return
        }
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
                    if error as? BTThreeDSecureError == .canceled {
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

    //TODO 
    private func createBTThreeDSecureAdditionalInformation() -> BTThreeDSecureAdditionalInformation {
    
        let additionalInformation = BTThreeDSecureAdditionalInformation()
        
        additionalInformation.shippingMethodIndicator = "01"
        additionalInformation.productCode = "AIR"
        additionalInformation.deliveryTimeframe = "01"
        additionalInformation.deliveryEmail = "deliver@email.com"
        additionalInformation.reorderIndicator = "01"
        additionalInformation.preorderIndicator = "01"
        additionalInformation.preorderDate = "20250211"
        additionalInformation.giftCardAmount = "10.00"
        additionalInformation.giftCardCurrencyCode = "USD"
        additionalInformation.giftCardCount = "1"
        additionalInformation.accountAgeIndicator = "01"
        additionalInformation.accountCreateDate = "20000211"
        additionalInformation.accountChangeIndicator = "01"
        additionalInformation.accountChangeDate = "20150211"
        additionalInformation.accountPwdChangeIndicator = "01"
        additionalInformation.accountPwdChangeDate = "20150211"
        additionalInformation.shippingAddressUsageIndicator = "01"
        additionalInformation.shippingAddressUsageDate = "20000211"
        additionalInformation.transactionCountDay = "1"
        additionalInformation.transactionCountYear = "1"
        additionalInformation.addCardAttempts = "0"
        additionalInformation.accountPurchases = "20"
        additionalInformation.fraudActivity = "01"
        additionalInformation.shippingNameIndicator = "01"
        additionalInformation.paymentAccountIndicator = "01"
        additionalInformation.paymentAccountAge = "20000211"
        additionalInformation.addressMatch = "Y"
        additionalInformation.accountID = "abcd123"
        additionalInformation.ipAddress = "193.23.222"
        additionalInformation.orderDescription = "JapanGiftCard"
        additionalInformation.taxAmount = "12367"
        additionalInformation.userAgent = "Safari"
        additionalInformation.authenticationIndicator = "01"
        additionalInformation.installment = "2"
        additionalInformation.purchaseDate = "20250211"
        additionalInformation.recurringEnd = "20300211"
        additionalInformation.recurringFrequency = "28"
        additionalInformation.sdkMaxTimeout = "28"
        additionalInformation.workPhoneNumber = "12223334444"
        
        
        let shippingAddress = BTThreeDSecurePostalAddress()
        
        shippingAddress.givenName = "Jill"
        shippingAddress.surname = "Doe"
        shippingAddress.streetAddress = "555 Smith St."
        shippingAddress.extendedAddress = "#5"
        shippingAddress.line3 = "Suit 2"
        shippingAddress.locality = "Oakland"
        shippingAddress.region = "CA"
        shippingAddress.countryCodeAlpha2 = "US"
        shippingAddress.postalCode = "12345"
        shippingAddress.phoneNumber = "8101234567"
        
        additionalInformation.shippingAddress = shippingAddress
        
        return additionalInformation
    }
    
    private func createThreeDSecureRequest(with nonce: String) -> BTThreeDSecureRequest {
        
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
        
        let request = BTThreeDSecureRequest(
            amount: "10.32",
            nonce: nonce,
            accountType: .credit,
            billingAddress: billingAddress,
            email: "test@example.com",
            renderTypes: [.otp, .singleSelect, .multiSelect, .oob, .html],
            requestedExemptionType: .lowValue,
            shippingMethod: .sameDay,
            uiType: .both,
            v2UICustomization: createUICustomization()
        )
        
        request.threeDSecureRequestDelegate = self
        
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
