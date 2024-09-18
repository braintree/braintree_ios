import UIKit
import BraintreeCore

class PaymentButtonBaseViewController: BaseViewController {

    let apiClient: BTAPIClient
    
    private var paymentButton = UIView()

    override init(authorization: String) {
        // swiftlint:disable:next force_unwrapping
        apiClient = BTAPIClient(authorization: authorization)!
        super.init(authorization: authorization)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Payment Button"
        view.backgroundColor = .systemBackground

        paymentButton = createPaymentButton()
        view.addSubview(paymentButton)

        NSLayoutConstraint.activate([
            paymentButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            paymentButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            paymentButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            paymentButton.heightAnchor.constraint(equalToConstant: 100)
        ])
    }

    /// A factory method that subclasses must implement to return a payment button view.
    func createPaymentButton() -> UIView {
        UIView()
    }

    func createButton(title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.setTitleColor(.lightGray, for: .highlighted)
        button.setTitleColor(.lightGray, for: .disabled)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
}
