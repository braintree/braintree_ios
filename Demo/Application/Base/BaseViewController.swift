import UIKit
import BraintreeCore

class BaseViewController: UIViewController {

    var progressBlock: ((String?) -> Void) = { _ in }
    var completionBlock: ((BTPaymentMethodNonce?) -> Void) = { _ in }

    init(authorization: String) {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        let tapToDismissKeyboard = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapToDismissKeyboard)
        super.viewDidLoad()
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
