import UIKit
import BraintreeCore

// TODO: remove @objcMembers when final VC is Swift
@objcMembers class BaseViewController: UIViewController {

    var progressBlock: ((String?) -> Void) = { _ in }
    var completionBlock: ((BTPaymentMethodNonce?) -> Void) = { _ in }
    var transactionBlock: (() -> Void) = { }

    // TODO: remove @objc when final VC is Swift
    @objc(initWithAuthorization:)
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

    func dismissKeyboard() {
        view.endEditing(true)
    }
}
