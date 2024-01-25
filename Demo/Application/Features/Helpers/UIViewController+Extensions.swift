import UIKit

extension UIViewController {
    
    func label(_ text: String, _ font: UIFont = .boldSystemFont(ofSize: 15)) -> UILabel {
        let label = UILabel()
        label.font = font
        label.text = text
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        return label
    }
    
    func textField(
        placeholder: String? = nil,
        text: String? = nil,
        clearButton: UITextField.ViewMode = .never
    ) -> UITextField {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderStyle = .roundedRect
        textField.placeholder = placeholder
        textField.text = text
        textField.clearButtonMode = clearButton
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        return textField
    }
}
