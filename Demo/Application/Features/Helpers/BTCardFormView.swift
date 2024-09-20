import UIKit

class BTCardFormView: UIView {

    // MARK: - Public Card Form Input Values

    var cardNumber: String? {
        cardNumberTextField.text?.isEmpty == false ? cardNumberTextField.text : nil
    }

    var expirationMonth: String? {
        parseExpirationDate()?.month
    }

    var expirationYear: String? {
        parseExpirationDate()?.year
    }

    var cvv: String? {
        cvvTextField.text?.isEmpty == false ? cvvTextField.text : nil
    }

    var postalCode: String? {
        postalCodeTextField.text?.isEmpty == false ? postalCodeTextField.text : nil
    }

    var phoneNumber: String? {
        phoneNumberTextField.text?.isEmpty == false ? phoneNumberTextField.text : nil
    }

    // MARK: - Public Card Form Config Options

    var hidePhoneNumberField: Bool = false {
        didSet {
            phoneNumberTextField.isHidden = self.hidePhoneNumberField
        }
    }

    var hidePostalCodeField: Bool = false {
        didSet {
            postalCodeTextField.isHidden = self.hidePostalCodeField
        }
    }

    var hideCVVField: Bool = false {
        didSet {
            cvvTextField.isHidden = self.hideCVVField
        }
    }

    // MARK: - Internal UI Properties

    var cardNumberTextField = UITextField() // exposed for 3DS demo
    var expirationTextField = UITextField() // exposed for 3DS demo
    var cvvTextField = UITextField() // exposed for 3DS demo
    var postalCodeTextField = UITextField() // exposed for 3DS demo
    var phoneNumberTextField = UITextField()
    var stackView = UIStackView()

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

    // MARK: - Layout UI

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
            stackView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -padding)
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
        guard let expirationDate = expirationTextField.text, expirationTextField.text?.isEmpty == false else {
            return nil
        }

        let dateComponents = expirationDate.components(separatedBy: "/")
        if dateComponents.count != 2 {
            return nil
        } else {
            return (dateComponents.first ?? "12", dateComponents.last ?? "2052")
        }
    }
}
