import UIKit

class CardFormViewCustom: UIView {

    // MARK: - Public Properties

    @objc var cardNumber: String? {
        return cardNumberTextField.text != "" ? cardNumberTextField.text : nil
    }
    @objc var expirationMonth: String? {
        return parseExpirationDate()?.month
    }
    @objc var expirationYear: String? {
        return parseExpirationDate()?.year
    }
    @objc var cvv: String? {
        return cvvTextField.text != "" ? cvvTextField.text : nil
    }
    @objc var postalCode: String? {
        return postalCodeTextField.text != "" ? postalCodeTextField.text : nil
    }
    @objc var phoneNumber: String? {
        return phoneNumberTextField.text != "" ? phoneNumberTextField.text : nil
    }

    // MARK: - Internal Properties

    var cardNumberTextField: UITextField = UITextField()
    var expirationTextField: UITextField = UITextField()
    var cvvTextField: UITextField = UITextField()
    var postalCodeTextField: UITextField = UITextField()
    var phoneNumberTextField: UITextField = UITextField()
    var stackView: UIStackView = UIStackView()

    let padding: CGFloat = 10

    // MARK: Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureStackView()
        configureStackViewComponents()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI Setup

    func configureStackView() {
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .leading
        stackView.spacing = 10

        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: padding),
            stackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -padding),
            stackView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: padding),
            stackView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -padding),
        ])
    }

    func configureStackViewComponents() {
        cardNumberTextField.placeholder = "Card Number"
        expirationTextField.placeholder = "MM/YY"
        cvvTextField.placeholder = "CVV"
        postalCodeTextField.placeholder = "Postal Code"
        phoneNumberTextField.placeholder = "Phone Number"

        cardNumberTextField.translatesAutoresizingMaskIntoConstraints = false
        expirationTextField.translatesAutoresizingMaskIntoConstraints = false
        cvvTextField.translatesAutoresizingMaskIntoConstraints = false
        postalCodeTextField.translatesAutoresizingMaskIntoConstraints = false
        phoneNumberTextField.translatesAutoresizingMaskIntoConstraints = false

        stackView.addArrangedSubview(cardNumberTextField)
        stackView.addArrangedSubview(expirationTextField)
        stackView.addArrangedSubview(cvvTextField)
        stackView.addArrangedSubview(postalCodeTextField)
        stackView.addArrangedSubview(phoneNumberTextField)

        NSLayoutConstraint.activate([
            cardNumberTextField.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            expirationTextField.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            cvvTextField.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            postalCodeTextField.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            phoneNumberTextField.widthAnchor.constraint(equalTo: stackView.widthAnchor)
        ])
    }

    // MARK: - Helpers

    func parseExpirationDate() -> (month: String, year: String)? {
        guard let expirationDate = expirationTextField.text, expirationTextField.text != "" else {
            return nil
        }

        let dateComponents = expirationDate.components(separatedBy: "/")
        if dateComponents.count != 2 {
            return nil
        } else {
            return (dateComponents.first!, dateComponents.last!)
        }
    }

}
