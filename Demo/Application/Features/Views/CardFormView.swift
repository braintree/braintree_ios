import UIKit

@objc public class CardFormView: UIView {

    // MARK: - Public Properties

    @objc var hidePhoneNumberField: Bool = false {
        didSet {
            phoneNumberLabel.isHidden = self.hidePhoneNumberField
            phoneNumberTextField.isHidden = self.hidePhoneNumberField
        }
    }

    @objc var hidePostalCodeField: Bool = false {
        didSet {
            postalCodeLabel.isHidden = self.hidePostalCodeField
            postalCodeTextField.isHidden = self.hidePostalCodeField
        }
    }

    @objc var hideCVVTextField: Bool = false {
        didSet {
            cvvLabel.isHidden = self.hideCVVTextField
            cvvTextField.isHidden = self.hideCVVTextField
        }
    }

    // MARK: - IBOutlets

    @IBOutlet weak var cardNumberTextField: UITextField!
    @IBOutlet weak var expirationMonthTextField: UITextField!
    @IBOutlet weak var expirationYearTextField: UITextField!
    @IBOutlet weak var cvvTextField: UITextField!
    @IBOutlet weak var postalCodeTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!

    @IBOutlet weak var cardNumberLabel: UILabel!
    @IBOutlet weak var expirationMonthLabel: UILabel!
    @IBOutlet weak var expirationYearLabel: UILabel!
    @IBOutlet weak var cvvLabel: UILabel!
    @IBOutlet weak var postalCodeLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!

}
