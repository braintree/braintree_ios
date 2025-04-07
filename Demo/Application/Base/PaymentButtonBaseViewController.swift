import UIKit
import BraintreeCore

class PaymentButtonBaseViewController: BaseViewController {

    // TODO: remove API client in final PR
    let apiClient: BTAPIClient
    let authorization: String

    var heightConstraint: CGFloat?

    private var paymentButton = UIView()

    override init(authorization: String) {
        apiClient = BTAPIClient(authorization: authorization)
        self.authorization = authorization
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
            paymentButton.heightAnchor.constraint(equalToConstant: heightConstraint ?? 100)
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

    // MARK: - Helpers

    func buttonsStackView(label: String, views: [UIView]) -> UIStackView {
        let titleLabel = UILabel()
        titleLabel.text = label

        let buttonsStackView = UIStackView(arrangedSubviews: [titleLabel] + views)
        buttonsStackView.axis = .vertical
        buttonsStackView.distribution = .fillProportionally
        buttonsStackView.backgroundColor = .systemGray6
        buttonsStackView.layoutMargins = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        buttonsStackView.isLayoutMarginsRelativeArrangement = true

        return buttonsStackView
    }
}
