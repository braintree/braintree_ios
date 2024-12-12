//import UIKit
//import BraintreeCard
//
//class CardTokenizationViewController: PaymentButtonBaseViewController {
//
//    private let cardFormView = BTCardFormView()
//    private var autofillButton = UIButton(type: .system)
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        createSubviews()
//        layoutConstraints()
//    }
//
//    override func createPaymentButton() -> UIView {
//        let submitButton = createButton(title: "Submit", action: #selector(tappedSubmit))
//        return submitButton
//    }
//
//    @objc func tappedSubmit() {
//        progressBlock("Tokenizing card details!")
//
//        let cardClient = BTCardClient(apiClient: apiClient)
//        let card = CardHelpers.newCard(from: cardFormView)
//
//        setFieldsEnabled(false)
//        cardClient.tokenize(card) { nonce, error in
//            self.setFieldsEnabled(true)
//
//            guard let nonce else {
//                self.progressBlock(error?.localizedDescription)
//                return
//            }
//
//            self.completionBlock(nonce)
//        }
//    }
//
//    @objc func tappedAutofill() {
//        cardFormView.cardNumberTextField.text = "4111111111111111"
//        cardFormView.cvvTextField.text = "123"
//        cardFormView.expirationTextField.text = CardHelpers.generateFuture(.date)
//    }
//
//    private func setFieldsEnabled(_ isEnabled: Bool) {
//        cardFormView.cardNumberTextField.isEnabled = isEnabled
//        cardFormView.expirationTextField.isEnabled = isEnabled
//        cardFormView.cvvTextField.isEnabled = isEnabled
//        autofillButton.isEnabled = isEnabled
//    }
//
//    private func createSubviews() {
//        cardFormView.translatesAutoresizingMaskIntoConstraints = false
//        cardFormView.hidePhoneNumberField = true
//        cardFormView.hidePostalCodeField = true
//        setFieldsEnabled(true)
//
//        autofillButton = createButton(title: "Autofill", action: #selector(tappedAutofill))
//
//        view.addSubview(cardFormView)
//        view.addSubview(autofillButton)
//    }
//
//    private func layoutConstraints() {
//        NSLayoutConstraint.activate([
//            cardFormView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            cardFormView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
//            cardFormView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
//            cardFormView.heightAnchor.constraint(equalToConstant: 200),
//
//            autofillButton.topAnchor.constraint(equalTo: cardFormView.bottomAnchor, constant: 10),
//            autofillButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
//            autofillButton.heightAnchor.constraint(equalToConstant: 30)
//        ])
//    }
//}
